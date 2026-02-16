//
//  PrivacyPolicyBannerView.swift
//  BackWell
//
//  Full-screen privacy policy banner shown when the user first reaches MainTabView.
//  Requires explicit opt-in before the app can send data to the third-party AI service (OpenAI).
//  Addresses App Store Guidelines 5.1.1(i) and 5.1.2(i).
//

import SwiftUI

struct PrivacyPolicyBannerView: View {
    @Binding var hasConsented: Bool
    @State private var consentToggle = false
    @State private var showPrivacyPolicy = false
    @State private var animateShield = false
    @State private var appearCards = false

    // Pink accent matching the app's existing disclosure style
    private let accentPink = Color(hex: "FF91A4")
    private let accentPinkLight = Color(hex: "FFB6C1")

    var body: some View {
        ZStack {
            // Blurred backdrop
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            // Main card
            VStack(spacing: 0) {
                // Drag indicator
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.gray.opacity(0.35))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Shield icon
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        gradient: Gradient(colors: [
                                            accentPink.opacity(0.15),
                                            accentPinkLight.opacity(0.05)
                                        ]),
                                        center: .center,
                                        startRadius: 5,
                                        endRadius: 55
                                    )
                                )
                                .frame(width: 96, height: 96)
                                .scaleEffect(animateShield ? 1.06 : 1.0)

                            Image(systemName: "hand.raised.fill")
                                .font(.system(size: 40, weight: .medium))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [accentPink, accentPinkLight],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .rotationEffect(.degrees(animateShield ? 2 : -2))
                        }
                        .padding(.top, 16)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                                animateShield = true
                            }
                            withAnimation(.easeOut(duration: 0.6).delay(0.15)) {
                                appearCards = true
                            }
                        }

                        // Title
                        VStack(spacing: 8) {
                            Text("Before You Begin")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(.black.opacity(0.88))

                            Text("We need your permission to provide AI-powered skin analysis")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.black.opacity(0.55))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 8)
                        }

                        // Disclosure sections
                        VStack(spacing: 14) {
                            BannerInfoCard(
                                icon: "iphone.and.arrow.forward",
                                iconColor: accentPink,
                                title: "What Data Is Sent",
                                bullets: [
                                    "Facial photos you choose to scan",
                                    "Your skin type, concerns & goals",
                                    "Chat messages with our AI assistant"
                                ]
                            )
                            .offset(y: appearCards ? 0 : 30)
                            .opacity(appearCards ? 1 : 0)

                            BannerInfoCard(
                                icon: "building.2.fill",
                                iconColor: Color(hex: "6C63FF"),
                                title: "Who Receives It",
                                bullets: [
                                    "OpenAI processes your data for AI analysis",
                                    "Data is transmitted securely via HTTPS",
                                    "OpenAI's privacy policy governs their handling"
                                ]
                            )
                            .offset(y: appearCards ? 0 : 30)
                            .opacity(appearCards ? 1 : 0)

                            BannerInfoCard(
                                icon: "lock.shield.fill",
                                iconColor: Color(hex: "34C759"),
                                title: "How We Protect You",
                                bullets: [
                                    "We never sell your personal data",
                                    "You can delete your data anytime in Settings",
                                    "Our privacy policy details all data practices"
                                ]
                            )
                            .offset(y: appearCards ? 0 : 30)
                            .opacity(appearCards ? 1 : 0)
                        }
                        .padding(.horizontal, 20)

                        // Privacy Policy link
                        Button {
                            showPrivacyPolicy = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "doc.text.fill")
                                    .font(.system(size: 13))
                                Text("Read Full Privacy Policy")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(accentPink)
                        }
                        .padding(.top, 4)

                        // Consent toggle
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                consentToggle.toggle()
                            }
                        } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(consentToggle ? accentPink : Color.gray.opacity(0.4), lineWidth: 2)
                                        .frame(width: 24, height: 24)

                                    if consentToggle {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(accentPink)
                                            .frame(width: 24, height: 24)

                                        Image(systemName: "checkmark")
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }

                                Text("I understand and consent to my data being shared with OpenAI for AI-powered analysis")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.black.opacity(0.8))
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)

                                Spacer()
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(consentToggle ? accentPink.opacity(0.06) : Color.gray.opacity(0.04))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(consentToggle ? accentPink.opacity(0.35) : Color.gray.opacity(0.15), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 20)
                        .padding(.top, 4)

                        // Accept button
                        Button {
                            hapticFeedback(.medium)
                            UserDefaults.standard.set(true, forKey: "userDataSharingConsent")
                            UserDefaults.standard.set(Date(), forKey: "consentDate")
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                hasConsented = true
                            }
                        } label: {
                            Text("Continue")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(
                                    RoundedRectangle(cornerRadius: 27)
                                        .fill(
                                            consentToggle
                                            ? LinearGradient(colors: [accentPink, accentPinkLight], startPoint: .leading, endPoint: .trailing)
                                            : LinearGradient(colors: [Color.gray.opacity(0.35), Color.gray.opacity(0.25)], startPoint: .leading, endPoint: .trailing)
                                        )
                                )
                                .shadow(color: consentToggle ? accentPink.opacity(0.3) : Color.clear, radius: 12, x: 0, y: 6)
                        }
                        .disabled(!consentToggle)
                        .padding(.horizontal, 28)
                        .padding(.top, 8)

                        // Decline option
                        Button {
                            // Do nothing — just informational; user cannot proceed without consent
                        } label: {
                            Text("You must opt in to use SkinGlowing's AI features")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.gray)
                        }
                        .disabled(true)
                        .padding(.bottom, 28)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.white)
            )
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .padding(.horizontal, 8)
            .padding(.top, 50)
            .padding(.bottom, 8)
            .shadow(color: Color.black.opacity(0.12), radius: 30, x: 0, y: 10)
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyWebView()
        }
    }
}

// MARK: - Info Card for the Banner

private struct BannerInfoCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let bullets: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(iconColor.opacity(0.12))
                        .frame(width: 36, height: 36)

                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(iconColor)
                }

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black.opacity(0.85))

                Spacer()
            }

            VStack(alignment: .leading, spacing: 7) {
                ForEach(bullets, id: \.self) { bullet in
                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(iconColor.opacity(0.4))
                            .frame(width: 5, height: 5)
                            .offset(y: 6)

                        Text(bullet)
                            .font(.system(size: 14))
                            .foregroundColor(.black.opacity(0.65))
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer()
                    }
                }
            }
            .padding(.leading, 4)
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
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
    }
}

// MARK: - Preview

#Preview {
    PrivacyPolicyBannerView(hasConsented: .constant(false))
}
