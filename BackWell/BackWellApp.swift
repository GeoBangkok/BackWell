//
//  BackWellApp.swift
//  BackWell
//
//  Created by standard on 1/17/26.
//

import SwiftUI
import SwiftData
import SuperwallKit
import FacebookCore

@main
struct BackWellApp: App {

    private let superwallDelegate = DiagnosticSuperwallDelegate()

    init() {
        // Initialize Facebook SDK for event tracking
        ApplicationDelegate.shared.application(
            UIApplication.shared,
            didFinishLaunchingWithOptions: nil
        )
        print("📊 Facebook SDK initialized")

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

    // Guard against duplicate PaywallViewed events (paywall re-renders)
    private var lastTrackedPaywallID: String?
    private var lastTrackedPaywallTime: Date?

    func didPresentPaywall(withInfo paywallInfo: PaywallInfo) {
        // Checkpoint 3a: Paywall presented successfully with products
        let productCount = paywallInfo.products.count
        print("SW_PAYWALL_PRESENTED – product_count: \(productCount)")

        // Log product IDs for additional verification
        for product in paywallInfo.products {
            print("SW_PRODUCT – id: \(product.id)")
        }

        // Track Facebook event when paywall ACTUALLY shows (not just when register() is called)
        // Guard: Only fire once per unique paywall session (prevent re-render spam)
        let shouldTrack: Bool
        if let lastID = lastTrackedPaywallID,
           let lastTime = lastTrackedPaywallTime,
           lastID == paywallInfo.identifier,
           Date().timeIntervalSince(lastTime) < 60 {
            // Same paywall within 60 seconds = re-render, don't track
            shouldTrack = false
            print("⚠️ Skipping duplicate PaywallViewed (re-render)")
        } else {
            shouldTrack = true
        }

        if shouldTrack {
            FacebookEventTracker.shared.trackPaywallViewed(
                placement: paywallInfo.name,
                paywallID: paywallInfo.identifier
            )
            lastTrackedPaywallID = paywallInfo.identifier
            lastTrackedPaywallTime = Date()
            print("📊 FB Event: PaywallViewed - placement: \(paywallInfo.name)")
        }
    }

    func didFailToPresent(paywallInfo: PaywallInfo?, error: Error) {
        // Checkpoint 3b: Paywall failed to present
        print("SW_PAYWALL_FAILED – \(error.localizedDescription)")
    }
}
