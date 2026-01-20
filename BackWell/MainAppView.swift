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
        // StartTrial tracking moved to Superwall callback in AppRootView.swift
        // Fires on system confirmation (Superwall callback), not UI state
    }
}

#Preview {
    MainAppView()
}
