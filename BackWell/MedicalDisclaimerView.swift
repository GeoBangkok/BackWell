//
//  MedicalDisclaimerView.swift
//  BackWell
//
//  Created by standard on 1/19/26.
//

import SwiftUI

struct MedicalDisclaimerView: View {
    let onAccept: () -> Void

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
                    .frame(height: 60)

                ScrollView {
                    VStack(spacing: 24) {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.3, green: 0.6, blue: 0.7).opacity(0.15))
                                .frame(width: 80, height: 80)

                            Image(systemName: "heart.text.square.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Color(red: 0.3, green: 0.6, blue: 0.7))
                        }
                        .padding(.top, 20)

                        // Title
                        Text("Medical Disclaimer")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.5))
                            .multilineTextAlignment(.center)

                        // Disclaimer content
                        VStack(alignment: .leading, spacing: 16) {
                            DisclaimerSection(
                                title: "Not Medical Advice",
                                content: "BackWell provides general wellness information and exercises for educational purposes only. The content is not intended to be a substitute for professional medical advice, diagnosis, or treatment."
                            )

                            DisclaimerSection(
                                title: "Consult Your Doctor",
                                content: "Always seek the advice of your physician or other qualified health provider with any questions you may have regarding a medical condition. Never disregard professional medical advice or delay seeking it because of something you have read or seen in this app."
                            )

                            DisclaimerSection(
                                title: "Exercise at Your Own Risk",
                                content: "You should consult your physician before starting any exercise program. If you experience any pain or difficulty with these exercises, stop immediately and consult your healthcare provider."
                            )

                            DisclaimerSection(
                                title: "No Liability",
                                content: "BackWell and its creators are not responsible for any injuries or health issues that may result from following the exercises or advice provided in this app."
                            )
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.6))
                        )
                        .padding(.horizontal, 24)

                        // Acknowledgment text
                        Text("By continuing, you acknowledge that you have read and understood this disclaimer.")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color(red: 0.5, green: 0.6, blue: 0.65))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .padding(.top, 8)

                        Spacer(minLength: 100)
                    }
                }

                // Accept button
                VStack(spacing: 0) {
                    Button(action: {
                        onAccept()
                    }) {
                        Text("I Understand & Accept")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                RoundedRectangle(cornerRadius: 27)
                                    .fill(Color(red: 0.3, green: 0.6, blue: 0.7))
                            )
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 50)
                }
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.82, green: 0.91, blue: 0.94).opacity(0),
                            Color(red: 0.82, green: 0.91, blue: 0.94)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 120)
                    .allowsHitTesting(false)
                )
            }
        }
    }
}

struct DisclaimerSection: View {
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0.3, green: 0.6, blue: 0.7))

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.5))
            }

            Text(content)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.6))
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(3)
        }
    }
}

#Preview {
    MedicalDisclaimerView(onAccept: {})
}
