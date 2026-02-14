//
//  ProfileView.swift
//  SkinGlowing
//
//  Profile screen (Sunshine tab)

import SwiftUI

struct ProfileView: View {
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false

    let PINK = Color(hex: "E8578A")
    let BG = Color(hex: "F8F7FB")
    let TEXT_PRIMARY = Color(hex: "1A1A2E")
    let TEXT_SECONDARY = Color(hex: "8E8E9A")

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(hex: "FFE4E1").opacity(0.2),
                        BG
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Header
                        VStack(spacing: 16) {
                            // Profile image placeholder
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [PINK.opacity(0.3), Color(hex: "FFB6C1").opacity(0.2)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)

                                Image(systemName: "face.smiling.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(PINK)
                            }

                            VStack(spacing: 4) {
                                Text("Hello, Sunshine!")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(TEXT_PRIMARY)

                                Text("Member since January 2026")
                                    .font(.system(size: 14))
                                    .foregroundColor(TEXT_SECONDARY)
                            }

                            // Stats row
                            HStack(spacing: 40) {
                                StatItem(value: "47", label: "Scans")
                                StatItem(value: "85", label: "Skin Score")
                                StatItem(value: "12", label: "Products")
                            }
                            .padding(.top, 8)
                        }
                        .padding(.top, 20)

                        // Menu sections
                        VStack(spacing: 16) {
                            // Account Section
                            MenuSection(title: "Account") {
                                MenuRow(
                                    icon: "person.circle.fill",
                                    title: "Edit Profile",
                                    color: PINK
                                )

                                MenuRow(
                                    icon: "bell.fill",
                                    title: "Notifications",
                                    color: Color(hex: "FF9500"),
                                    hasToggle: true,
                                    isToggled: $notificationsEnabled
                                )

                                MenuRow(
                                    icon: "moon.fill",
                                    title: "Dark Mode",
                                    color: Color(hex: "8B7DFF"),
                                    hasToggle: true,
                                    isToggled: $darkModeEnabled
                                )
                            }

                            // Skincare Journey Section
                            MenuSection(title: "Skincare Journey") {
                                MenuRow(
                                    icon: "chart.line.uptrend.xyaxis",
                                    title: "Progress History",
                                    color: Color(hex: "34C759")
                                )

                                MenuRow(
                                    icon: "heart.fill",
                                    title: "Favorite Products",
                                    color: PINK
                                )

                                MenuRow(
                                    icon: "calendar",
                                    title: "Routine Reminders",
                                    color: Color(hex: "4A90E2")
                                )
                            }

                            // Support Section
                            MenuSection(title: "Support") {
                                MenuRow(
                                    icon: "questionmark.circle.fill",
                                    title: "Help Center",
                                    color: Color(hex: "007AFF")
                                )

                                MenuRow(
                                    icon: "envelope.fill",
                                    title: "Contact Us",
                                    color: Color(hex: "5AC8FA")
                                )

                                MenuRow(
                                    icon: "star.fill",
                                    title: "Rate App",
                                    color: Color(hex: "FFD60A")
                                )
                            }

                            // Settings link
                            Button(action: {
                                hapticFeedback(.light)
                                // Navigate to settings
                            }) {
                                HStack {
                                    Image(systemName: "gearshape.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(hex: "8E8E9A"))

                                    Text("Settings")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(TEXT_PRIMARY)

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(hex: "C7C7CC"))
                                }
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(14)
                            }
                            .padding(.horizontal)
                        }

                        Spacer(minLength: 100)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct StatItem: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(hex: "E8578A"))

            Text(label)
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "8E8E9A"))
        }
    }
}

struct MenuSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(hex: "8E8E9A"))
                .textCase(.uppercase)
                .padding(.horizontal)

            VStack(spacing: 1) {
                content
            }
            .background(Color.white)
            .cornerRadius(14)
            .padding(.horizontal)
        }
    }
}

struct MenuRow: View {
    let icon: String
    let title: String
    let color: Color
    var hasToggle: Bool = false
    var isToggled: Binding<Bool>?

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 28)

            Text(title)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "1A1A2E"))

            Spacer()

            if hasToggle, let isToggled = isToggled {
                Toggle("", isOn: isToggled)
                    .labelsHidden()
                    .tint(Color(hex: "E8578A"))
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "C7C7CC"))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
        .onTapGesture {
            if !hasToggle {
                hapticFeedback(.light)
                // Handle navigation
            }
        }
    }
}

#Preview {
    ProfileView()
}