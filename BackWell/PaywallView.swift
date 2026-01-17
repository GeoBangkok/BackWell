//
//  PaywallView.swift
//  BackWell
//
//  Created by standard on 1/17/26.
//

import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showMainApp = false

    var body: some View {
        ZStack {
            // Calming gradient background - matches onboarding
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
                // Header with back and close buttons
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 22))
                            .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.6))
                    }

                    Spacer()

                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 22))
                            .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.6))
                    }
                }
                .padding(.horizontal, 28)
                .padding(.top, 24)
                .padding(.bottom, 20)

                ScrollView {
                    VStack(spacing: 0) {
                        // Title
                        Text("How Your Free Trial Works")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.5))
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                            .padding(.horizontal, 32)
                            .padding(.bottom, 35)

                        // Timeline
                        VStack(spacing: 0) {
                    TimelineItem(
                        icon: "calendar",
                        iconColor: Color(red: 0.3, green: 0.6, blue: 0.7),
                        title: "Today: Start Your Free Trial",
                        description: "Get instant access to hundreds of exercises and your personalized 28-day challenge.",
                        isFirst: true
                    )

                    TimelineItem(
                        icon: "bell.fill",
                        iconColor: Color(red: 0.3, green: 0.6, blue: 0.7),
                        title: "Day 2: Trial Reminder",
                        description: "You'll get a notification or email reminder that your trial is ending.",
                        isFirst: false
                    )

                    TimelineItem(
                        icon: "star.fill",
                        iconColor: Color(red: 0.3, green: 0.6, blue: 0.7),
                        title: "Day 3: Trial Ends",
                        description: "You'll be charged on \(getTrialEndDate()). You can cancel anytime before.",
                        isFirst: false,
                        isLast: true
                    )
                        }
                        .padding(.horizontal, 28)

                        // No payment due now
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(red: 0.3, green: 0.6, blue: 0.7))

                            Text("No Payment Due Now")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.5))
                        }
                        .padding(.top, 30)
                        .padding(.bottom, 20)

                        // CTA Button
                        Button(action: {
                            showMainApp = true
                        }) {
                            Text("Start Free Trial")
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

                        // Pricing text
                        Text("3 days free, then just $9.99 per week")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color(red: 0.5, green: 0.6, blue: 0.65))
                            .padding(.top, 14)
                            .padding(.bottom, 8)

                        // Footer links
                        HStack(spacing: 40) {
                            Button(action: {
                                // Privacy action
                            }) {
                                Text("Privacy")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(Color(red: 0.5, green: 0.6, blue: 0.65))
                                    .underline()
                            }

                            Button(action: {
                                // Restore action
                            }) {
                                Text("Restore")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(Color(red: 0.5, green: 0.6, blue: 0.65))
                                    .underline()
                            }

                            Button(action: {
                                // Terms action
                            }) {
                                Text("Terms")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(Color(red: 0.5, green: 0.6, blue: 0.65))
                                    .underline()
                            }
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showMainApp) {
            MainAppView()
        }
    }

    func getTrialEndDate() -> String {
        let calendar = Calendar.current
        if let endDate = calendar.date(byAdding: .day, value: 3, to: Date()) {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: endDate)
        }
        return "soon"
    }
}

struct TimelineItem: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    var isFirst: Bool = false
    var isLast: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Left side - timeline with icon
            VStack(spacing: 0) {
                if !isFirst {
                    Rectangle()
                        .fill(iconColor.opacity(0.3))
                        .frame(width: 3, height: 20)
                }

                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(iconColor)
                        .frame(width: 56, height: 72)

                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }

                if !isLast {
                    Rectangle()
                        .fill(iconColor.opacity(0.3))
                        .frame(width: 3, height: 50)
                }
            }

            // Right side - content
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.5))
                    .padding(.top, 2)

                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.6))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(3)
            }
            .padding(.top, isFirst ? 0 : 20)
            .padding(.bottom, isLast ? 0 : 0)

            Spacer()
        }
    }
}

#Preview {
    PaywallView()
}
