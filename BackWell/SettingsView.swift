//
//  SettingsView.swift
//  SkinGlowing
//
//  Settings screen with purple theme
//

import SwiftUI

struct SettingsView: View {
    @State private var notificationsEnabled = true
    @State private var reminderTime = Date()
    @State private var showRestoreAlert = false
    @State private var restoreMessage = ""
    @State private var showSupportView = false
    @State private var showLogoutAlert = false
    @State private var userDataSharingConsent = UserDefaults.standard.bool(forKey: "userDataSharingConsent")
    @State private var showPrivacyDisclosure = false

    @ObservedObject private var storeManager = StoreManager.shared

    var body: some View {
        NavigationView {
            ZStack {
                // Purple gradient background
                LinearGradient(
                    colors: [Theme.purpleUltraLight, Color.white],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        Text("Settings")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(Theme.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)
                            .padding(.top, 20)
                            .padding(.bottom, 10)

                        // Profile Section
                        VStack(spacing: 16) {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Theme.purple.opacity(0.2))
                                        .frame(width: 70, height: 70)

                                    Image(systemName: "person.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(Theme.purple)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("SkinGlowing Premium")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(Theme.textPrimary)

                                    Text("AI Skin Analysis Active")
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundColor(Theme.textSecondary)
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
                                .foregroundColor(Theme.textPrimary)
                                .padding(.horizontal, 24)

                            VStack(spacing: 0) {
                                SettingsRow(
                                    icon: "bell.fill",
                                    title: "Scan Reminders",
                                    hasToggle: true,
                                    toggleValue: $notificationsEnabled
                                )

                                Divider()
                                    .padding(.leading, 64)

                                if notificationsEnabled {
                                    HStack {
                                        Image(systemName: "clock.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(Theme.purple)
                                            .frame(width: 32)

                                        Text("Reminder Time")
                                            .font(.system(size: 16, weight: .regular))
                                            .foregroundColor(Theme.textPrimary)

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
                                .foregroundColor(Theme.textPrimary)
                                .padding(.horizontal, 24)

                            VStack(spacing: 0) {
                                // Subscription Status
                                HStack(spacing: 16) {
                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(Theme.purple)
                                        .frame(width: 32)

                                    Text("Subscription Status")
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundColor(Theme.textPrimary)

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
                                .foregroundColor(Theme.textPrimary)
                                .padding(.horizontal, 24)

                            VStack(spacing: 0) {
                                SettingsRow(
                                    icon: "questionmark.circle.fill",
                                    title: "Help & FAQ",
                                    hasChevron: true
                                )
                                .onTapGesture {
                                    showSupportView = true
                                }

                                Divider()
                                    .padding(.leading, 64)

                                SettingsRow(
                                    icon: "envelope.fill",
                                    title: "Contact Support",
                                    hasChevron: true
                                )
                                .onTapGesture {
                                    showSupportView = true
                                }

                                Divider()
                                    .padding(.leading, 64)

                                SettingsRow(
                                    icon: "doc.text.fill",
                                    title: "Terms of Service",
                                    hasChevron: true
                                )
                                .onTapGesture {
                                    if let url = URL(string: "https://skinglowing.lovable.app/terms") {
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
                                    if let url = URL(string: "https://skinglowing.lovable.app/privacy") {
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

                        // Data Privacy Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Data Privacy")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Theme.textPrimary)
                                .padding(.horizontal, 24)

                            VStack(spacing: 0) {
                                // AI Data Sharing Toggle
                                HStack(spacing: 16) {
                                    Image(systemName: "lock.shield.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(Theme.purple)
                                        .frame(width: 32)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("AI Data Sharing")
                                            .font(.system(size: 16, weight: .regular))
                                            .foregroundColor(Theme.textPrimary)

                                        Text("Share data with OpenAI for analysis")
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundColor(Theme.textSecondary)
                                    }

                                    Spacer()

                                    Toggle("", isOn: $userDataSharingConsent)
                                        .toggleStyle(SwitchToggleStyle(tint: Theme.purple))
                                        .labelsHidden()
                                        .onChange(of: userDataSharingConsent) { newValue in
                                            UserDefaults.standard.set(newValue, forKey: "userDataSharingConsent")
                                            if newValue {
                                                UserDefaults.standard.set(Date(), forKey: "consentDate")
                                            }
                                        }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)

                                Divider()
                                    .padding(.leading, 64)

                                SettingsRow(
                                    icon: "info.circle.fill",
                                    title: "Data Usage Details",
                                    hasChevron: true
                                )
                                .onTapGesture {
                                    showPrivacyDisclosure = true
                                }

                                Divider()
                                    .padding(.leading, 64)

                                SettingsRow(
                                    icon: "trash.fill",
                                    title: "Delete My Data",
                                    hasChevron: true,
                                    textColor: .red
                                )
                                .onTapGesture {
                                    // Handle data deletion request
                                    // This would typically involve clearing local data and
                                    // potentially sending a request to delete server-side data
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.6))
                            )
                            .padding(.horizontal, 24)
                        }

                        // Log Out Button
                        Button(action: {
                            showLogoutAlert = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 18))
                                Text("Log Out")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.6))
                            )
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 8)

                        // App Version
                        Text("SkinGlowing v2.0.0")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(Theme.textMuted)
                            .padding(.top, 12)

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
            .alert("Log Out", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Log Out", role: .destructive) {
                    // Reset app state - return to login
                    NotificationCenter.default.post(name: NSNotification.Name("LogOut"), object: nil)
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
            .sheet(isPresented: $showSupportView) {
                SupportView()
            }
            .sheet(isPresented: $showPrivacyDisclosure) {
                PrivacyDisclosureDetailView()
            }
        }
    }
}

// MARK: - Support View
struct SupportView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        GeometryReader { geo in
        ZStack {
            Theme.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Theme.textMuted)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                Spacer()

                // Icon
                ZStack {
                    Circle()
                        .fill(Theme.purple.opacity(0.15))
                        .frame(width: 100, height: 100)

                    Image(systemName: "envelope.fill")
                        .font(.system(size: 44))
                        .foregroundColor(Theme.purple)
                }

                // Title
                Text("Contact Support")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Theme.textPrimary)

                // Description
                Text("Need help? Have questions or feedback?\nWe'd love to hear from you!")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                // Email Card
                VStack(spacing: 16) {
                    Text("Email us at:")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Theme.textMuted)

                    Button(action: {
                        if let url = URL(string: "mailto:george@atlasremoteservices.com") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text("george@atlasremoteservices.com")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Theme.purple)
                    }

                    Text("We typically respond within 24-48 hours")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Theme.textMuted)
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.7))
                )
                .padding(.horizontal, 24)

                Spacer()

                // Send Email Button
                Button(action: {
                    if let url = URL(string: "mailto:george@atlasremoteservices.com?subject=SkinGlowing%20Support") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Send Email")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            RoundedRectangle(cornerRadius: 27)
                                .fill(Theme.purple)
                        )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, max(16, geo.safeAreaInsets.bottom + 8))
            }
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
    var textColor: Color? = nil

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(textColor ?? Theme.purple)
                .frame(width: 32)

            Text(title)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(textColor ?? Theme.textPrimary)

            Spacer()

            if hasToggle, let toggleValue = toggleValue {
                Toggle("", isOn: toggleValue)
                    .labelsHidden()
                    .tint(Theme.purple)
            } else if hasChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.textMuted)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

#Preview {
    SettingsView()
}
