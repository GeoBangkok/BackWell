//
//  MainTabView.swift
//  SkinGlowing
//
//  Main navigation with floating tabs

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showingScanModal = false
    @Namespace private var animationNamespace

    let PINK = Color(hex: "E8578A")
    let INACTIVE = Color(hex: "B0A0A8")

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(hex: "F8F7FB"),
                    Color(hex: "E8D5F0").opacity(0.3)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Content
            VStack(spacing: 0) {
                // Main content area
                Group {
                    switch selectedTab {
                    case 0:
                        TodayView() // Renamed from SkinGlowingHomeView
                    case 1:
                        ProductsView() // New products screen
                    case 2:
                        Text("") // Scan button triggers modal instead
                    case 3:
                        InsightsView() // New insights screen
                    case 4:
                        ProfileView() // Profile/Sunshine screen
                    default:
                        TodayView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Modern Tab Bar like React Native version
                ModernTabBar(
                    selectedTab: $selectedTab,
                    showingScanModal: $showingScanModal,
                    namespace: animationNamespace
                )
            }
        }
        .preferredColorScheme(.light)
        .sheet(isPresented: $showingScanModal) {
            ScanModalView()
        }
    }
}

// MARK: - Modern Tab Bar (React Native Style)
struct ModernTabBar: View {
    @Binding var selectedTab: Int
    @Binding var showingScanModal: Bool
    let namespace: Namespace.ID

    let PINK = Color(hex: "E8578A")
    let INACTIVE = Color(hex: "B0A0A8")

    var body: some View {
        HStack(spacing: 0) {
            // Today Tab
            TabBarItem(
                icon: "sun.max.fill",
                title: "Today",
                isSelected: selectedTab == 0,
                color: selectedTab == 0 ? PINK : INACTIVE,
                action: {
                    hapticFeedback(.light)
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = 0
                    }
                }
            )

            // Products Tab
            TabBarItem(
                icon: "book.fill",
                title: "Products",
                isSelected: selectedTab == 1,
                color: selectedTab == 1 ? PINK : INACTIVE,
                action: {
                    hapticFeedback(.light)
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = 1
                    }
                }
            )

            // New Scan Tab (Special center button)
            Button(action: {
                hapticFeedback(.medium)
                showingScanModal = true
            }) {
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "E8578A").opacity(0.08))
                            .frame(width: 48, height: 48)

                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(PINK)
                    }
                    .offset(y: -8)

                    Text("New Scan")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(PINK)
                }
            }
            .frame(maxWidth: .infinity)

            // Insights Tab
            TabBarItem(
                icon: "chart.bar.fill",
                title: "Insights",
                isSelected: selectedTab == 3,
                color: selectedTab == 3 ? PINK : INACTIVE,
                action: {
                    hapticFeedback(.light)
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = 3
                    }
                }
            )

            // Profile Tab (Sunshine)
            TabBarItem(
                icon: "face.smiling.fill",
                title: "Sunshine",
                isSelected: selectedTab == 4,
                color: selectedTab == 4 ? PINK : INACTIVE,
                action: {
                    hapticFeedback(.light)
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = 4
                    }
                }
            )
        }
        .padding(.top, 8)
        .padding(.bottom, 20)
        .background(
            Color.white
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: -2)
        )
    }
}

struct TabBarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)

                Text(title)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(color)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MainTabView()
}