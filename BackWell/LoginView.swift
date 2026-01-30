//
//  LoginView.swift
//  SkinGlowing
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
                Text("SkinGlowing")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.textPrimary)
                    .padding(.bottom, 8)

                // Tagline
                Text("AI-Powered Skin Analysis")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Theme.textSecondary)
                    .padding(.bottom, 60)

                Spacer()

                // Gentle pulsating button
                Button(action: onContinue) {
                    Text("Start Your Skin Journey")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Theme.buttonGradient)
                        )
                        .shadow(color: Theme.purple.opacity(0.3), radius: 8, x: 0, y: 4)
                        .scaleEffect(isPulsating ? 1.02 : 1.0)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 20)

                // Reassuring text
                Text("Personalized skincare insights")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Theme.textMuted)
                    .padding(.bottom, 80)

                Spacer()
            }
        }
        .onAppear {
            startPulsating()
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
