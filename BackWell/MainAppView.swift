//
//  MainAppView.swift
//  SkinWell
//
//  Main tab navigation for SkinWell app
//

import SwiftUI

struct MainAppView: View {
    @State private var selectedTab = 0
    @StateObject private var skinService = SkinAnalysisService.shared

    var body: some View {
        ZStack {
            // Purple gradient background
            Theme.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom header
                HStack {
                    Spacer()
                    Text("SkinWell")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.vertical, 15)
                .background(
                    LinearGradient(
                        colors: [Theme.purple, Theme.purpleDark],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

                // Tab content
                TabView(selection: $selectedTab) {
                    SkinScanView()
                        .tabItem {
                            Label("Scan", systemImage: "camera.fill")
                        }
                        .tag(0)

                    RoutineMakerView()
                        .tabItem {
                            Label("Routine", systemImage: "sparkles")
                        }
                        .tag(1)

                    ArisaChatView()
                        .tabItem {
                            Label("Arisa AI", systemImage: "message.fill")
                        }
                        .tag(2)

                    ArchiveView()
                        .tabItem {
                            Label("Archive", systemImage: "clock.fill")
                        }
                        .tag(3)

                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gearshape.fill")
                        }
                        .tag(4)
                }
                .accentColor(Theme.purple)
            }
        }
        .environmentObject(skinService)
    }
}

#Preview {
    MainAppView()
}