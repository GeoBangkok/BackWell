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
    @State private var heartBeat = false
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

                // Stay Beautiful + bumping heart button
                Button(action: onContinue) {
                    HStack(spacing: 12) {
                        Text("STAY BEAUTIFUL")
                            .font(.system(size: 18, weight: .heavy))
                            .foregroundColor(.white)
                            .tracking(1.5)

                        Image(systemName: "heart.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.red)
                            .scaleEffect(buttonScale)
                            .shadow(color: .red.opacity(0.7), radius: isPulsating ? 10 : 4, x: 0, y: 0)
                    }
                    .padding(.horizontal, 28)
                    .padding(.vertical, 16)
                    .background(
                        Capsule()
                            .fill(Color(hex: "E8578A").opacity(0.85))
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: Color(hex: "E8578A").opacity(0.5), radius: 15, x: 0, y: 8)
                }
                .padding(.bottom, 80)
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
