//
//  LoginView.swift
//  BackWell
//
//  Created by standard on 1/17/26.
//

import SwiftUI

struct LoginView: View {
    @State private var isPulsating = false
    @State private var showOnboarding = false

    var body: some View {
        ZStack {
            // Calming gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.97, blue: 0.98),
                    Color(red: 0.88, green: 0.94, blue: 0.96),
                    Color(red: 0.82, green: 0.91, blue: 0.94)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // App Name
                Text("BackWell")
                    .font(.system(size: 44, weight: .light, design: .rounded))
                    .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.5))
                    .padding(.bottom, 8)

                // Tagline
                Text("Your path to relief")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.6))
                    .padding(.bottom, 60)

                Spacer()

                // Gentle pulsating button
                Button(action: {
                    showOnboarding = true
                }) {
                    Text("Get Back Relief Today")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.3, green: 0.6, blue: 0.7),
                                            Color(red: 0.25, green: 0.55, blue: 0.65)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .shadow(color: Color(red: 0.3, green: 0.6, blue: 0.7).opacity(0.3), radius: 8, x: 0, y: 4)
                        .scaleEffect(isPulsating ? 1.02 : 1.0)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 20)

                // Reassuring text
                Text("Clinically designed for your comfort")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color(red: 0.5, green: 0.6, blue: 0.65).opacity(0.8))
                    .padding(.bottom, 80)

                Spacer()
            }
        }
        .onAppear {
            startPulsating()
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView()
        }
    }
    
    private func startPulsating() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            isPulsating = true
        }
    }
}

#Preview {
    LoginView()
}
