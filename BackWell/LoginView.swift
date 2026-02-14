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
    @State private var shimmerOffset: CGFloat = -UIScreen.main.bounds.width
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
                                        Color(hex: "E8A0BF").opacity(0.6),
                                        Color(hex: "D4728C").opacity(0.4)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 260, height: 56)
                            .blur(radius: isPulsating ? 20 : 10)
                            .opacity(isPulsating ? 0.8 : 0.6)

                        // Main button with gradient
                        ZStack {
                            // Background gradient
                            LinearGradient(
                                colors: [
                                    Color(hex: "E8A0BF"),
                                    Color(hex: "D4728C"),
                                    Color(hex: "C25577")
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .frame(width: 260, height: 56)
                            .clipShape(RoundedRectangle(cornerRadius: 28))

                            // Button content
                            HStack(spacing: 10) {
                                Text("Get Beautiful")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)

                                Image(systemName: "heart.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                            }

                            // Shimmer overlay
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0),
                                    Color.white.opacity(0.15),
                                    Color.white.opacity(0)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .frame(width: 60, height: 56)
                            .offset(x: shimmerOffset)
                            .clipShape(RoundedRectangle(cornerRadius: 28))
                        }
                        .frame(width: 260, height: 56)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: Color(hex: "E8578A").opacity(0.5), radius: 15, x: 0, y: 8)
                    }
                    .scaleEffect(buttonScale)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 16)

                // Reassuring text
                Text("Your beauty journey starts here")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))
                    .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                    .padding(.bottom, 60)
            }
        }
        .onAppear {
            startPulsating()
            startShimmer()
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

    private func startShimmer() {
        // Shimmer animation that repeats
        withAnimation(
            .linear(duration: 3.0)
            .repeatForever(autoreverses: false)
        ) {
            shimmerOffset = UIScreen.main.bounds.width
        }
    }
}


#Preview {
    LoginView(onContinue: {})
}
