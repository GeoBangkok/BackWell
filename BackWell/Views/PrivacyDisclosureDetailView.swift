//
//  PrivacyDisclosureDetailView.swift
//  BackWell
//
//  Detailed privacy disclosure for Settings
//

import SwiftUI

struct PrivacyDisclosureDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State private var userConsent = UserDefaults.standard.bool(forKey: "userDataSharingConsent")

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Theme.purpleUltraLight, Color.white],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header Section
                        VStack(spacing: 16) {
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 60, weight: .medium))
                                .foregroundColor(Theme.purple)
                                .padding(.top, 20)

                            Text("AI Data Usage & Privacy")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Theme.textPrimary)

                            Text("How we protect and use your data")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(Theme.textSecondary)
                        }
                        .padding(.horizontal, 24)

                        // Information Cards
                        VStack(spacing: 16) {
                            // What We Collect
                            InfoCard(
                                icon: "camera.fill",
                                iconColor: Theme.purple,
                                title: "What We Collect",
                                description: "When you use our AI features, we collect:",
                                items: [
                                    "Facial photos for skin analysis",
                                    "Your skin concerns and goals",
                                    "Age range and skin sensitivity",
                                    "K-Beauty knowledge level",
                                    "Health conditions for safe recommendations"
                                ]
                            )

                            // How It's Used
                            InfoCard(
                                icon: "sparkles",
                                iconColor: Color.orange,
                                title: "How Your Data is Used",
                                description: "We use AI technology to:",
                                items: [
                                    "Analyze skin condition and provide scores",
                                    "Generate personalized skincare routines",
                                    "Recommend suitable K-Beauty products",
                                    "Track your skin improvement progress",
                                    "Provide AI skincare assistant responses"
                                ]
                            )

                            // Third-Party Sharing
                            InfoCard(
                                icon: "network",
                                iconColor: Color.blue,
                                title: "Third-Party AI Service",
                                description: "Data sharing details:",
                                items: [
                                    "We use OpenAI's GPT technology",
                                    "Photos are sent securely via encryption",
                                    "Data is processed per OpenAI's privacy policy",
                                    "We never sell your personal data",
                                    "You control when data is shared"
                                ]
                            )

                            // Your Rights
                            InfoCard(
                                icon: "person.badge.shield.checkmark.fill",
                                iconColor: Color.green,
                                title: "Your Privacy Rights",
                                description: "You have the right to:",
                                items: [
                                    "Opt-out of AI data sharing anytime",
                                    "Request deletion of your data",
                                    "Access your collected information",
                                    "Disable specific features",
                                    "Contact us with privacy concerns"
                                ]
                            )
                        }
                        .padding(.horizontal, 24)

                        // Consent Status
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: userConsent ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(userConsent ? Color.green : Color.red)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Current Status")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Theme.textSecondary)

                                    Text(userConsent ? "AI Data Sharing Enabled" : "AI Data Sharing Disabled")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Theme.textPrimary)
                                }

                                Spacer()
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.8))
                            )

                            if let consentDate = UserDefaults.standard.object(forKey: "consentDate") as? Date {
                                Text("Consent provided on \(consentDate, formatter: dateFormatter)")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(Theme.textMuted)
                            }
                        }
                        .padding(.horizontal, 24)

                        // Links Section
                        VStack(spacing: 12) {
                            Button(action: {
                                if let url = URL(string: "https://skinglowing.lovable.app/privacy") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack {
                                    Image(systemName: "doc.text")
                                    Text("Full Privacy Policy")
                                    Spacer()
                                    Image(systemName: "arrow.up.right.square")
                                }
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Theme.purple)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Theme.purple.opacity(0.1))
                                )
                            }

                            Button(action: {
                                if let url = URL(string: "https://openai.com/policies/privacy-policy") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack {
                                    Image(systemName: "link")
                                    Text("OpenAI Privacy Policy")
                                    Spacer()
                                    Image(systemName: "arrow.up.right.square")
                                }
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Theme.purple)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Theme.purple.opacity(0.1))
                                )
                            }
                        }
                        .padding(.horizontal, 24)

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Theme.purple)
                }
            }
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
}

// Info Card Component
struct InfoCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 40, height: 40)

                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(iconColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Theme.textPrimary)

                    Text(description)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Theme.textSecondary)
                }

                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(iconColor.opacity(0.3))
                            .frame(width: 4, height: 4)
                            .offset(y: 6)

                        Text(item)
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textPrimary.opacity(0.8))
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer()
                    }
                }
            }
            .padding(.leading, 52)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.8))
        )
    }
}