//
//  SuperwallPurchaseController.swift
//  BackWell
//
//  Created by standard on 1/19/26.
//

import Foundation
import SuperwallKit
import StoreKit

final class SuperwallPurchaseController: PurchaseController {

    // MARK: - PurchaseController Protocol

    @MainActor
    func purchase(product: StoreProduct) async -> PurchaseResult {
        do {
            // Get the StoreKit 2 product using the product identifier
            let products = try await Product.products(for: [product.productIdentifier])

            guard let storeKitProduct = products.first else {
                return .failed(StoreError.productNotFound)
            }

            let result = try await storeKitProduct.purchase()

            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    await StoreManager.shared.checkSubscriptionStatus()
                    return .purchased
                case .unverified:
                    return .failed(StoreError.verificationFailed)
                }

            case .userCancelled:
                return .cancelled

            case .pending:
                return .pending

            @unknown default:
                return .failed(StoreError.purchaseFailed)
            }
        } catch {
            return .failed(error)
        }
    }

    @MainActor
    func restorePurchases() async -> RestorationResult {
        do {
            try await AppStore.sync()
            await StoreManager.shared.checkSubscriptionStatus()

            if StoreManager.shared.isSubscribed {
                return .restored
            } else {
                return .failed(nil)
            }
        } catch {
            return .failed(error)
        }
    }
}
