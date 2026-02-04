//
//  MainTabView.swift
//  SkinGlowing
//
//  Main tab navigation with three tabs

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Analysis", systemImage: "camera.metering.multispot")
                }
                .tag(0)

            RoutinesView()
                .tabItem {
                    Label("Routines", systemImage: "sparkles")
                }
                .tag(1)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .accentColor(Color(hex: "FF91A4"))
    }
}

#Preview {
    MainTabView()
}