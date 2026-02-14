//
//  PrivacyDisclosureView.swift
//  BackWell
//
//  Privacy disclosure for AI data sharing compliance with App Store Guidelines 5.1.1(i) and 5.1.2(i)
//

import SwiftUI

struct PrivacyDisclosureStep: View {
    @Binding var userConsent: Bool
    @State private var showPrivacyPolicy = false
    @State private var animateIcon = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Icon with animation
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "FF91A4").opacity(0.15),
                                    Color(hex: "FFB6C1").opacity(0.15)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .scaleEffect(animateIcon ? 1.05 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 2.0)
                                .repeatForever(autoreverses: true),
                            value: animateIcon
                        )

                    Image(systemName: "lock.shield")
                        .font(.system(size: 45, weight: .medium))
                        .foregroundColor(Color(hex: "FF91A4"))
                }
                .padding(.top, 20)
                .onAppear {
                    animateIcon = true
                }

                // Title
                Text("Your Privacy Matters")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color.black.opacity(0.85))
                    .multilineTextAlignment(.center)

                // Subtitle
                Text("We use AI to personalize your skincare experience")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color.black.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                // Disclosure cards
                VStack(spacing: 16) {
                    // What we collect card
                    DisclosureCard(
                        icon: "camera.fill",
                        title: "What Data We Collect",
                        items: [
                            "Your facial photos (when you choose to scan)",
                            "Age range and skin sensitivity",
                            "Skincare concerns and goals",
                            "K-Beauty knowledge level",
                            "Health conditions (to ensure safe recommendations)"
                        ]
                    )

                    // How we use it card
                    DisclosureCard(
                        icon: "sparkles",
                        title: "How We Use Your Data",
                        items: [
                            "Analyze your skin condition using AI",
                            "Provide personalized skincare recommendations",
                            "Track your skin improvement over time",
                            "Suggest K-Beauty products and routines",
                            "Offer skincare tips via our AI assistant Arisa"
                        ]
                    )

                    // Who we share with card
                    DisclosureCard(
                        icon: "network",
                        title: "Third-Party AI Service",
                        items: [
                            "We use OpenAI's GPT technology for analysis",
                            "Your photos are sent securely to OpenAI servers",
                            "Data is processed according to OpenAI's privacy policy",
                            "We do not sell your personal data",
                            "You can delete your data anytime in Settings"
                        ]
                    )
                }
                .padding(.horizontal, 20)

                // Privacy Policy Link
                Button(action: {
                    showPrivacyPolicy = true
                }) {
                    HStack {
                        Image(systemName: "doc.text")
                            .font(.system(size: 14))
                        Text("Read Full Privacy Policy")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(Color(hex: "FF91A4"))
                }
                .padding(.top, 8)

                // Consent Toggle
                VStack(spacing: 12) {
                    Toggle(isOn: $userConsent) {
                        HStack {
                            Image(systemName: userConsent ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 20))
                                .foregroundColor(userConsent ? Color(hex: "FF91A4") : Color.gray.opacity(0.5))

                            Text("I understand and consent to data sharing with OpenAI")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.black.opacity(0.8))
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: Color(hex: "FF91A4")))
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(userConsent ? Color(hex: "FF91A4").opacity(0.05) : Color.gray.opacity(0.05))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(userConsent ? Color(hex: "FF91A4").opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
                    )

                    if !userConsent {
                        Text("Please provide your consent to continue")
                            .font(.system(size: 12))
                            .foregroundColor(Color.orange)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                // Continue button
                Button(action: {
                    if userConsent {
                        hapticFeedback(.medium)
                        // Save consent
                        UserDefaults.standard.set(true, forKey: "userDataSharingConsent")
                        UserDefaults.standard.set(Date(), forKey: "consentDate")

                        // Navigate to next step
                        NotificationCenter.default.post(name: NSNotification.Name("NavigateFromPrivacyDisclosure"), object: nil)
                    }
                }) {
                    Text("Continue")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "FF91A4"),
                                            Color(hex: "FFB6C1")
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .shadow(color: Color(hex: "FF91A4").opacity(0.25), radius: 15, x: 0, y: 8)
                }
                .disabled(!userConsent)
                .opacity(userConsent ? 1.0 : 0.6)
                .padding(.horizontal, 40)
                .padding(.vertical, 20)

                Spacer(minLength: 40)
            }
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyWebView()
        }
    }
}

// Disclosure Card Component
struct DisclosureCard: View {
    let icon: String
    let title: String
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(hex: "FF91A4"))

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.black.opacity(0.85))

                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(Color(hex: "FF91A4").opacity(0.3))
                            .frame(width: 4, height: 4)
                            .offset(y: 6)

                        Text(item)
                            .font(.system(size: 14))
                            .foregroundColor(Color.black.opacity(0.7))
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer()
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// Privacy Policy Web View
struct PrivacyPolicyWebView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack {
                if let url = URL(string: "https://skinglowing.lovable.app/privacy") {
                    WebView(url: url)
                } else {
                    Text("Unable to load privacy policy")
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// WebView wrapper (if not already in project)
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // No update needed
    }
}

// Haptic feedback helper (if not already in project)
func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
    let generator = UIImpactFeedbackGenerator(style: style)
    generator.prepare()
    generator.impactOccurred()
}