//
//  SettingsView.swift
//  BackWell
//
//  Created by standard on 1/17/26.
//

import SwiftUI

struct SettingsView: View {
    @State private var notificationsEnabled = true
    @State private var reminderTime = Date()
    @State private var showRestoreAlert = false
    @State private var restoreMessage = ""

    @ObservedObject private var storeManager = StoreManager.shared

    var body: some View {
        NavigationView {
            ZStack {
                // Same calming gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.95, green: 0.97, blue: 0.98),
                        Color(red: 0.88, green: 0.94, blue: 0.96),
                        Color(red: 0.82, green: 0.91, blue: 0.94)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        Text("Settings")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.5))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)
                            .padding(.top, 20)
                            .padding(.bottom, 10)

                        // Profile Section
                        VStack(spacing: 16) {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 0.3, green: 0.6, blue: 0.7).opacity(0.2))
                                        .frame(width: 70, height: 70)

                                    Image(systemName: "person.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(Color(red: 0.3, green: 0.6, blue: 0.7))
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("BackWell User")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.5))

                                    Text("Day 1 of 28-Day Challenge")
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.6))
                                }

                                Spacer()
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.6))
                            )
                        }
                        .padding(.horizontal, 24)

                        // Notifications Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Notifications")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.5))
                                .padding(.horizontal, 24)

                            VStack(spacing: 0) {
                                SettingsRow(
                                    icon: "bell.fill",
                                    title: "Daily Reminders",
                                    hasToggle: true,
                                    toggleValue: $notificationsEnabled
                                )

                                Divider()
                                    .padding(.leading, 64)

                                if notificationsEnabled {
                                    HStack {
                                        Image(systemName: "clock.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(Color(red: 0.3, green: 0.6, blue: 0.7))
                                            .frame(width: 32)

                                        Text("Reminder Time")
                                            .font(.system(size: 16, weight: .regular))
                                            .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.5))

                                        Spacer()

                                        DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                                            .labelsHidden()
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(Color.white.opacity(0.6))
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.6))
                            )
                            .padding(.horizontal, 24)
                        }

                        // Account Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Account")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.5))
                                .padding(.horizontal, 24)

                            VStack(spacing: 0) {
                                // Subscription Status
                                HStack(spacing: 16) {
                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(red: 0.3, green: 0.6, blue: 0.7))
                                        .frame(width: 32)

                                    Text("Subscription Status")
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.5))

                                    Spacer()

                                    Text(storeManager.isSubscribed ? "Active" : "Free Trial")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(storeManager.isSubscribed ? Color.green : Color.orange)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill((storeManager.isSubscribed ? Color.green : Color.orange).opacity(0.15))
                                        )
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)

                                Divider()
                                    .padding(.leading, 64)

                                SettingsRow(
                                    icon: "arrow.clockwise.circle.fill",
                                    title: "Restore Purchases",
                                    hasChevron: true
                                )
                                .onTapGesture {
                                    Task {
                                        await storeManager.restorePurchases()
                                        if storeManager.isSubscribed {
                                            restoreMessage = "Purchases restored successfully!"
                                        } else if let error = storeManager.errorMessage {
                                            restoreMessage = error
                                        }
                                        showRestoreAlert = true
                                    }
                                }

                                Divider()
                                    .padding(.leading, 64)

                                SettingsRow(
                                    icon: "creditcard.fill",
                                    title: "Manage Subscription",
                                    hasChevron: true
                                )
                                .onTapGesture {
                                    if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.6))
                            )
                            .padding(.horizontal, 24)
                        }

                        // Support Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Support")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.5))
                                .padding(.horizontal, 24)

                            VStack(spacing: 0) {
                                SettingsRow(
                                    icon: "questionmark.circle.fill",
                                    title: "Help & FAQ",
                                    hasChevron: true
                                )

                                Divider()
                                    .padding(.leading, 64)

                                SettingsRow(
                                    icon: "envelope.fill",
                                    title: "Contact Support",
                                    hasChevron: true
                                )

                                Divider()
                                    .padding(.leading, 64)

                                SettingsRow(
                                    icon: "doc.text.fill",
                                    title: "Terms of Service",
                                    hasChevron: true
                                )
                                .onTapGesture {
                                    if let url = URL(string: "https://backwelll.lovable.app/terms") {
                                        UIApplication.shared.open(url)
                                    }
                                }

                                Divider()
                                    .padding(.leading, 64)

                                SettingsRow(
                                    icon: "hand.raised.fill",
                                    title: "Privacy Policy",
                                    hasChevron: true
                                )
                                .onTapGesture {
                                    if let url = URL(string: "https://backwelll.lovable.app/privacy") {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.6))
                            )
                            .padding(.horizontal, 24)
                        }

                        // App Version
                        Text("BackWell v1.0.0")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(Color(red: 0.5, green: 0.6, blue: 0.65))
                            .padding(.top, 20)

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarHidden(true)
            .alert("Restore Purchases", isPresented: $showRestoreAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(restoreMessage)
            }
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    var hasToggle: Bool = false
    var toggleValue: Binding<Bool>? = nil
    var hasChevron: Bool = false

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(red: 0.3, green: 0.6, blue: 0.7))
                .frame(width: 32)

            Text(title)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.5))

            Spacer()

            if hasToggle, let toggleValue = toggleValue {
                Toggle("", isOn: toggleValue)
                    .labelsHidden()
                    .tint(Color(red: 0.3, green: 0.6, blue: 0.7))
            } else if hasChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0.5, green: 0.6, blue: 0.65))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

#Preview {
    SettingsView()
}
