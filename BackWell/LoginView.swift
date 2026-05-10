//
//  LoginView.swift
//  SkinGlowing
//
//  Created by standard on 1/17/26.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var languageManager: AppLanguageManager
    @State private var isPulsating = false
    @State private var buttonScale: CGFloat = 1.0
    @State private var heartBeat = false
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Theme.blushBackground
                .ignoresSafeArea()

            VStack {
                HStack {
                    Spacer()
                    languageMenu
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                Spacer()
            }
            .zIndex(2)

            VStack(spacing: 22) {
                SGBrandMark(size: 22)
                    .padding(.top, 58)

                VStack(spacing: 8) {
                    Text("Your Personal")
                        .font(.system(size: 44, weight: .regular, design: .serif))
                        .foregroundColor(Theme.headline)
                    Text("Skin Coach")
                        .font(.system(size: 48, weight: .regular, design: .serif))
                        .foregroundColor(Theme.accent)
                    Text("Grow Your Glow. Build Your Beauty.")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(Theme.bodyText)
                }
                .multilineTextAlignment(.center)

                ZStack(alignment: .bottom) {
                    Image("onboarding_scan_face")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 390)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(Color.white.opacity(0.88), lineWidth: 2)
                        )

                    VStack(spacing: 12) {
                        HStack {
                            ScanCallout(icon: "sparkles", title: "Glow", subtitle: "Priority")
                            Spacer()
                            ScanCallout(icon: "circle.grid.3x3.fill", title: "Texture", subtitle: "Insight")
                        }

                        HStack {
                            ScanCallout(icon: "gauge.with.dots.needle.bottom.50percent", title: "Tone", subtitle: "Focus")
                            Spacer()
                        }
                    }
                    .padding(18)
                }
                .padding(.horizontal, 18)

                Spacer()

                Button(action: onContinue) {
                    HStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 19, weight: .bold))

                        Text("Start My Glow Plan")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background(Theme.pinkButtonGradient)
                    .clipShape(Capsule())
                    .shadow(color: Theme.accent.opacity(isPulsating ? 0.35 : 0.22), radius: isPulsating ? 18 : 10, x: 0, y: 10)
                }
                .scaleEffect(buttonScale)
                .padding(.horizontal, 22)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            startPulsating()
        }
    }

    private func startPulsating() {
        // Gentle breathing animation
        withAnimation(
            .easeInOut(duration: 2.0)
            .repeatForever(autoreverses: true)
        ) {
            isPulsating = true
            buttonScale = 1.03
        }
    }

    private var languageMenu: some View {
        Menu {
            ForEach(AppLanguage.allCases) { language in
                Button {
                    hapticFeedback(.light)
                    languageManager.select(language)
                } label: {
                    HStack {
                        Text(language.flag)
                        Text(language.displayName)
                    }
                }
            }
        } label: {
            Text(languageManager.selectedLanguage.flag)
                .font(.system(size: 25))
                .frame(width: 50, height: 50)
                .background(.ultraThinMaterial)
                .background(Color.white.opacity(0.70))
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white.opacity(0.85), lineWidth: 1))
                .shadow(color: Theme.accent.opacity(0.16), radius: 12, x: 0, y: 8)
                .accessibilityLabel(Text("Change language"))
        }
    }

}

private struct ScanCallout: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Theme.accent)
                .frame(width: 42, height: 42)
                .background(Theme.accentSoft)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 20, weight: .regular, design: .serif))
                    .foregroundColor(Theme.accent)
                Text(subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Theme.bodyText)
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .background(Color.white.opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(Color.white.opacity(0.8), lineWidth: 1))
    }
}


#Preview {
    LoginView(onContinue: {})
        .environmentObject(AppLanguageManager.shared)
}
