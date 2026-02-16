//
//  SettingsView.swift
//  SkinGlowing
//
//  Minimal settings: subscription, support, legal, delete account
//

import SwiftUI

struct SettingsView: View {
    @State private var showDeleteAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                Text("Settings")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Theme.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 20)

                // Subscription
                VStack(spacing: 0) {
                    SettingsLink(
                        icon: "creditcard.fill",
                        title: "Manage Subscription"
                    ) {
                        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                            UIApplication.shared.open(url)
                        }
                    }
                }
                .background(Color.white)
                .cornerRadius(Theme.cardCorner)
                .shadow(color: Theme.cardShadowColor, radius: Theme.cardShadowRadius, x: 0, y: 4)

                // Support & Legal
                VStack(spacing: 0) {
                    SettingsLink(icon: "questionmark.circle.fill", title: "Support") {
                        if let url = URL(string: "https://backwell.lovable.app/support") {
                            UIApplication.shared.open(url)
                        }
                    }

                    Divider().padding(.leading, 56)

                    SettingsLink(icon: "doc.text.fill", title: "Terms & Conditions") {
                        if let url = URL(string: "https://backwell.lovable.app/terms") {
                            UIApplication.shared.open(url)
                        }
                    }

                    Divider().padding(.leading, 56)

                    SettingsLink(icon: "hand.raised.fill", title: "Privacy Policy") {
                        if let url = URL(string: "https://backwell.lovable.app/privacy") {
                            UIApplication.shared.open(url)
                        }
                    }
                }
                .background(Color.white)
                .cornerRadius(Theme.cardCorner)
                .shadow(color: Theme.cardShadowColor, radius: Theme.cardShadowRadius, x: 0, y: 4)

                // Delete Account
                VStack(spacing: 0) {
                    SettingsLink(
                        icon: "trash.fill",
                        title: "Delete Account",
                        tint: .red
                    ) {
                        showDeleteAlert = true
                    }
                }
                .background(Color.white)
                .cornerRadius(Theme.cardCorner)
                .shadow(color: Theme.cardShadowColor, radius: Theme.cardShadowRadius, x: 0, y: 4)

                // App Version
                Text("BackWell v2.0.0")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.captionText)
                    .padding(.top, 8)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(Color.white.ignoresSafeArea())
        .alert("Delete Account", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                NotificationCenter.default.post(name: NSNotification.Name("LogOut"), object: nil)
            }
        } message: {
            Text("This will permanently delete your account and all data. This action cannot be undone.")
        }
    }
}

// MARK: - Settings Link Row

private struct SettingsLink: View {
    let icon: String
    let title: String
    var tint: Color = Theme.accent
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(tint)
                    .frame(width: 28)

                Text(title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(tint == .red ? .red : Theme.headline)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Theme.captionText)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SettingsView()
}
