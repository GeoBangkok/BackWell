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

    init() {
        Superwall.configure(
            apiKey: "pk_RFmV5ZDuvTQSuZgr_mIDf",
            purchaseController: SuperwallPurchaseController()
        )
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
