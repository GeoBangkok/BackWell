//
//  MainAppView.swift
//  BackWell
//
//  Created by standard on 1/17/26.
//

import SwiftUI

struct MainAppView: View {
    @State private var selectedTab = 0
    @ObservedObject private var storeManager = StoreManager.shared
    @AppStorage("has_tracked_trial_start") private var hasTrackedTrialStart = false

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(1)
        }
        .accentColor(Theme.teal)
        .onAppear {
            // Track StartTrial when user successfully enters app in trial mode
            // Gated paywall: user chose "Start Trial" → granted Days 1-3 access
            // Fires ONCE on first app access (after StoreKit processing completes)
            // Only fires if user is NOT subscribed (trial status confirmed)
            if !hasTrackedTrialStart && !storeManager.isSubscribed {
                FacebookEventTracker.shared.trackStartTrial()
                hasTrackedTrialStart = true
                print("📊 Trial activated - user entered app with free access")
            }
        }
    }
}

#Preview {
    MainAppView()
}
