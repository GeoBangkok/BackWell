//
//  StoreManager.swift
//  BackWell
//
//  Created by standard on 1/18/26.
//

import Foundation
import Combine
import StoreKit

class StoreManager: ObservableObject {
    static let shared = StoreManager()

    @Published var isSubscribed: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let productID = "backwell_unlimited_weekly_9_99"
    private var updateListenerTask: Task<Void, Error>?

    private init() {
        updateListenerTask = listenForTransactions()
        Task {
            await checkSubscriptionStatus()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Purchase Methods

    func purchase() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }

        do {
            guard let product = try await fetchProduct() else {
                throw StoreError.productNotFound
            }

            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await checkSubscriptionStatus()

            case .userCancelled:
                break

            case .pending:
                await MainActor.run {
                    errorMessage = "Purchase is pending approval"
                }

            @unknown default:
                break
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }

        await MainActor.run {
            isLoading = false
        }
    }

    func restorePurchases() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }

        do {
            try await AppStore.sync()
            await checkSubscriptionStatus()

            await MainActor.run {
                if !isSubscribed {
                    errorMessage = "No purchases found to restore"
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to restore purchases"
            }
        }

        await MainActor.run {
            isLoading = false
        }
    }

    // MARK: - Subscription Status

    func checkSubscriptionStatus() async {
        var validSubscription = false

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                if transaction.productID == productID {
                    if let expirationDate = transaction.expirationDate,
                       expirationDate > Date() {
                        validSubscription = true
                    } else if transaction.expirationDate == nil {
                        // Non-renewing or lifetime, treat as valid
                        validSubscription = true
                    }
                }
            } catch {
                print("Transaction verification failed: \(error)")
            }
        }

        await MainActor.run {
            isSubscribed = validSubscription
        }
    }

    func hasAccessToDay(_ day: Int) -> Bool {
        // Days 1-3 are free during trial or always
        if day <= 3 {
            return true
        }

        // Days 4+ require subscription
        return isSubscribed
    }

    // MARK: - Private Helpers

    private func fetchProduct() async throws -> StoreKit.Product? {
        let products = try await StoreKit.Product.products(for: [productID])
        return products.first
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }

    private func listenForTransactions() -> Task<Void, Error> {
        return Task {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await transaction.finish()
                    await self.checkSubscriptionStatus()
                } catch {
                    print("Transaction failed verification: \(error)")
                }
            }
        }
    }
}

// MARK: - Store Errors

enum StoreError: LocalizedError {
    case productNotFound
    case verificationFailed
    case purchaseFailed

    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "Product not found in App Store"
        case .verificationFailed:
            return "Purchase verification failed"
        case .purchaseFailed:
            return "Purchase failed"
        }
    }
}
