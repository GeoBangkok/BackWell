//
//  StoreManager.swift
//  BackWell
//
//  Created by standard on 1/18/26.
//

import Foundation
import Combine
import StoreKit
import SuperwallKit

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

    @MainActor
    func purchase() async {
        isLoading = true
        errorMessage = nil

        print("🛒 Starting purchase flow...")

        do {
            print("🔍 Fetching product: \(productID)")
            guard let product = try await fetchProduct() else {
                print("❌ Product not found: \(productID)")
                throw StoreError.productNotFound
            }

            print("✅ Product found: \(product.displayName) - \(product.displayPrice)")
            print("🛍️ Initiating purchase...")

            let result = try await product.purchase()

            print("📋 Purchase result received: \(result)")

            switch result {
            case .success(let verification):
                print("✅ Purchase successful, verifying...")
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await checkSubscriptionStatus()
                print("✅ Transaction finished and status updated")

            case .userCancelled:
                print("🚫 User cancelled purchase")
                break

            case .pending:
                print("⏳ Purchase pending approval")
                errorMessage = "Purchase is pending approval"

            @unknown default:
                print("❓ Unknown purchase result")
                break
            }
        } catch {
            print("❌ Purchase error: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }

        isLoading = false
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
            // Sync subscription status with Superwall for tracking
            Superwall.shared.subscriptionStatus = validSubscription ? .active(Set()) : .inactive
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
        print("📦 Requesting products from App Store for: [\(productID)]")
        let products = try await StoreKit.Product.products(for: [productID])
        print("📦 Received \(products.count) products from App Store")
        for product in products {
            print("   - \(product.id): \(product.displayName) (\(product.displayPrice))")
        }
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
