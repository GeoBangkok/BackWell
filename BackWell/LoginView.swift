//
//  LoginView.swift
//  BackWell
//
//  Created by standard on 1/17/26.
//

import SwiftUI

struct LoginView: View {
    @State private var isPulsating = false
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Theme.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // App Name
                Text("BackWell")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.textPrimary)
                    .padding(.bottom, 8)

                // Tagline
                Text("Your path to relief")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Theme.textSecondary)
                    .padding(.bottom, 60)

                Spacer()

                // Gentle pulsating button
                Button(action: onContinue) {
                    Text("Get Back Relief Today")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Theme.buttonGradient)
                        )
                        .shadow(color: Theme.teal.opacity(0.3), radius: 8, x: 0, y: 4)
                        .scaleEffect(isPulsating ? 1.02 : 1.0)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 20)

                // Reassuring text
                Text("Clinically designed for your comfort")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Theme.textMuted)
                    .padding(.bottom, 80)

                Spacer()
            }
        }
        .onAppear {
            startPulsating()
            // Track ViewContent for login screen
            FacebookEventTracker.shared.trackViewContent(
                contentType: "login_screen",
                contentID: "app_launch"
            )
        }
    }

    private func startPulsating() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            isPulsating = true
        }
    }
}

#Preview {
    LoginView(onContinue: {})
}
