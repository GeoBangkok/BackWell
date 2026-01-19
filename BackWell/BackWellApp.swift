//
//  BackWellApp.swift
//  BackWell
//
//  Created by standard on 1/17/26.
//

import SwiftUI
import SwiftData
import SuperwallKit

@main
struct BackWellApp: App {

    private let superwallDelegate = DiagnosticSuperwallDelegate()

    init() {
        Superwall.configure(
            apiKey: "pk_RFmV5ZDuvTQSuZgr_mIDf",
            purchaseController: SuperwallPurchaseController()
        )

        // Checkpoint 1: Verify Superwall initialized with correct bundle
        let bundleID = Bundle.main.bundleIdentifier ?? "unknown"
        print("SW_INIT_OK – bundle: \(bundleID)")

        // Set delegate for paywall presentation events
        Superwall.shared.delegate = superwallDelegate

        // Set initial subscription status - required when using PurchaseController
        Superwall.shared.subscriptionStatus = .inactive
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .modelContainer(sharedModelContainer)
        }
    }
}

// MARK: - Diagnostic Superwall Delegate

final class DiagnosticSuperwallDelegate: SuperwallDelegate {

    func didPresentPaywall(withInfo paywallInfo: PaywallInfo) {
        // Checkpoint 3a: Paywall presented successfully with products
        let productCount = paywallInfo.products.count
        print("SW_PAYWALL_PRESENTED – product_count: \(productCount)")

        // Log product IDs for additional verification
        for product in paywallInfo.products {
            print("SW_PRODUCT – id: \(product.id)")
        }
    }

    func didFailToPresent(paywallInfo: PaywallInfo?, error: Error) {
        // Checkpoint 3b: Paywall failed to present
        print("SW_PAYWALL_FAILED – \(error.localizedDescription)")
    }
}
