//
//  MainTabView.swift
//  SkinGlowing
//
//  Main navigation with floating tabs

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @Namespace private var animationNamespace

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(hex: "FFF0F5"),
                    Color(hex: "FFE4E1")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Content
            VStack(spacing: 0) {
                // Main content area
                Group {
                    switch selectedTab {
                    case 0:
                        SkinGlowingHomeView()
                    case 1:
                        MakeupScanView()
                    case 2:
                        ArisaAIView()
                    case 3:
                        SettingsView()
                    default:
                        SkinGlowingHomeView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Floating Tab Bar
                FloatingTabBar(selectedTab: $selectedTab, namespace: animationNamespace)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
            }
        }
        .preferredColorScheme(.light)
    }
}

// MARK: - Floating Tab Bar
struct FloatingTabBar: View {
    @Binding var selectedTab: Int
    let namespace: Namespace.ID

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                FloatingTabItem(
                    icon: tab.icon,
                    title: tab.title,
                    isSelected: selectedTab == index,
                    namespace: namespace,
                    action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = index
                        }
                    }
                )
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
        )
    }

    let tabs = [
        (icon: "sparkles", title: "Home"),
        (icon: "paintbrush.pointed.fill", title: "Makeup"),
        (icon: "message.fill", title: "Arisa AI"),
        (icon: "gearshape.fill", title: "Settings")
    ]
}

struct FloatingTabItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .symbolRenderingMode(.multicolor)

                Text(title)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundColor(isSelected ? Color(hex: "FF91A4") : .gray)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color(hex: "FF91A4").opacity(0.1))
                            .matchedGeometryEffect(id: "tab", in: namespace)
                    }
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MainTabView()
}