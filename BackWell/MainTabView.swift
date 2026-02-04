//
//  MainTabView.swift
//  SkinGlowing
//
//  Main tab navigation with four tabs

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

            ArisaAIView()
                .tabItem {
                    Label("Arisa AI", systemImage: "message.fill")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .accentColor(Color(hex: "FF91A4"))
    }
}

#Preview {
    MainTabView()
}