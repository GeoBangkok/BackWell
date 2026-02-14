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
        print("🛒 SuperwallPurchaseController: purchase() called")
        print("🛒 Product identifier: \(product.productIdentifier)")

        do {
            // Get the StoreKit 2 product using the product identifier
            print("🛒 Fetching StoreKit product...")
            let products = try await Product.products(for: [product.productIdentifier])
            print("🛒 Found \(products.count) products")

            guard let storeKitProduct = products.first else {
                print("❌ Product not found in App Store")
                return .failed(StoreError.productNotFound)
            }

            print("🛒 Initiating purchase for: \(storeKitProduct.displayName)")
            let result = try await storeKitProduct.purchase()

            switch result {
            case .success(let verification):
                print("✅ Purchase successful, verifying...")
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    await StoreManager.shared.checkSubscriptionStatus()
                    print("✅ Transaction verified and finished")
                    return .purchased
                case .unverified:
                    print("❌ Transaction unverified")
                    return .failed(StoreError.verificationFailed)
                }

            case .userCancelled:
                print("🚫 User cancelled purchase")
                return .cancelled

            case .pending:
                print("⏳ Purchase pending")
                return .pending

            @unknown default:
                print("❓ Unknown purchase result")
                return .failed(StoreError.purchaseFailed)
            }
        } catch {
            print("❌ Purchase error: \(error.localizedDescription)")
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
