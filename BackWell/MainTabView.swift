//
//  MainTabView.swift
//  SkinGlowing
//
//  3-tab layout: Face Scan + Product Scan + Settings
//  Top bar: SkinGlowing logo left, History icon right
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showingHistory = false
    @ObservedObject private var historyManager = ScanHistoryManager.shared

    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                Text("SkinGlowing")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Theme.headline)

                Spacer()

                Button(action: {
                    hapticFeedback(.light)
                    showingHistory = true
                }) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(Theme.accent)
                        .frame(width: 44, height: 44)
                        .background(Theme.accentSoft)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 12)

            // Content
            TabView(selection: $selectedTab) {
                FaceScanTabView()
                    .tag(0)

                ProductScanTabView()
                    .tag(1)

                SettingsView()
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Bottom tab bar
            HStack(spacing: 0) {
                SGTabItem(
                    icon: "camera.fill",
                    title: "Face Scan",
                    isSelected: selectedTab == 0
                ) {
                    hapticFeedback(.light)
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selectedTab = 0
                    }
                }

                SGTabItem(
                    icon: "flask.fill",
                    title: "Product Scan",
                    isSelected: selectedTab == 1
                ) {
                    hapticFeedback(.light)
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selectedTab = 1
                    }
                }

                SGTabItem(
                    icon: "gearshape.fill",
                    title: "Settings",
                    isSelected: selectedTab == 2
                ) {
                    hapticFeedback(.light)
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selectedTab = 2
                    }
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 24)
            .background(
                Color.white
                    .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: -2)
            )
        }
        .background(Color.white.ignoresSafeArea())
        .preferredColorScheme(.light)
        .sheet(isPresented: $showingHistory) {
            ArchiveView()
        }
    }
}

// MARK: - Tab Item

struct SGTabItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? Theme.accent : Theme.captionText)

                Text(title)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? Theme.accent : Theme.captionText)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Backward Compatibility Stubs

struct ModernTabBar: View {
    @Binding var selectedTab: Int
    @Binding var showingScanModal: Bool
    let namespace: Namespace.ID
    var body: some View { EmptyView() }
}

struct TabBarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    var body: some View { EmptyView() }
}

#Preview {
    MainTabView()
}
