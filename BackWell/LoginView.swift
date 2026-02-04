//
//  LoginView.swift
//  SkinGlowing
//
//  Created by standard on 1/17/26.
//

import SwiftUI

struct LoginView: View {
    @State private var isPulsating = false
    @State private var buttonScale: CGFloat = 1.0
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            // Korean video background
            LoopingVideoPlayer(videoName: "Korean")
                .ignoresSafeArea()
                .overlay(
                    // Subtle overlay for text readability
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                )

            VStack(spacing: 0) {
                // App Name with better contrast
                Text("SkinGlowing")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                    .padding(.top, 120)
                    .padding(.bottom, 12)

                // Tagline
                Text("AI-Powered Skin Analysis")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white.opacity(0.95))
                    .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)

                Spacer()

                // Gentle pulsating button with breathing effect
                Button(action: onContinue) {
                    ZStack {
                        // Glow effect behind button
                        RoundedRectangle(cornerRadius: 28)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "FFB6C1").opacity(0.6),
                                        Color(hex: "FFC0CB").opacity(0.4)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 60)
                            .blur(radius: isPulsating ? 20 : 10)
                            .opacity(isPulsating ? 0.8 : 0.6)

                        // Main button
                        HStack {
                            Text("Start Your Skin Journey")
                                .font(.system(size: 19, weight: .semibold))
                                .foregroundColor(.white)

                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.white.opacity(0.95))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(hex: "FFB6C1"),
                                    Color(hex: "FF91A4")
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: Color(hex: "FF91A4").opacity(0.5), radius: 12, x: 0, y: 6)
                    }
                    .scaleEffect(buttonScale)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 16)

                // Reassuring text
                Text("Personalized skincare insights")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                    .padding(.bottom, 60)
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
}


#Preview {
    LoginView(onContinue: {})
}
