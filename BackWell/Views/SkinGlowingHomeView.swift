//
//  SkinGlowingHomeView.swift
//  SkinGlowing
//
//  Beautiful home view with skin analysis features

import SwiftUI

struct SkinGlowingHomeView: View {
    @State private var skinAge = 24
    @State private var glassSkinScore = 85
    @State private var blemishesScore = 72
    @State private var hydrationScore = 68
    @State private var showingSkinScan = false
    @State private var animateScores = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("Good Morning, Beautiful")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "FF91A4"), Color(hex: "FFB6C1")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Text("Your skin is glowing today ✨")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                }
                .padding(.top, 60)
                .padding(.bottom, 20)

                // Main Skin Scan Card
                Button(action: { showingSkinScan = true }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 30)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "FFE0EC"),
                                        Color(hex: "FFC0CB").opacity(0.7)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color(hex: "FF91A4").opacity(0.3), radius: 20, x: 0, y: 10)

                        VStack(spacing: 20) {
                            // Scan Icon
                            ZStack {
                                Circle()
                                    .fill(.white.opacity(0.9))
                                    .frame(width: 80, height: 80)

                                Image(systemName: "camera.aperture")
                                    .font(.system(size: 40))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color(hex: "FF91A4"), Color(hex: "FF69B4")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .rotationEffect(.degrees(animateScores ? 360 : 0))
                                    .animation(.linear(duration: 20).repeatForever(autoreverses: false), value: animateScores)
                            }

                            Text("Start Skin Analysis")
                                .font(.system(size: 22, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)

                            Text("AI-Powered Skin Assessment")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.vertical, 40)
                    }
                    .frame(height: 220)
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal, 20)

                // Score Cards Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ScoreCard(
                        title: "Skin Age",
                        score: skinAge,
                        maxScore: 100,
                        icon: "clock.badge.checkmark",
                        color: Color(hex: "FF91A4"),
                        suffix: " years",
                        animate: $animateScores
                    )

                    ScoreCard(
                        title: "Glass Skin",
                        score: glassSkinScore,
                        maxScore: 100,
                        icon: "sparkles",
                        color: Color(hex: "87CEEB"),
                        suffix: "%",
                        animate: $animateScores
                    )

                    ScoreCard(
                        title: "Clear Skin",
                        score: blemishesScore,
                        maxScore: 100,
                        icon: "star.fill",
                        color: Color(hex: "98D8C8"),
                        suffix: "%",
                        animate: $animateScores
                    )

                    ScoreCard(
                        title: "Hydration",
                        score: hydrationScore,
                        maxScore: 100,
                        icon: "drop.fill",
                        color: Color(hex: "89CFF0"),
                        suffix: "%",
                        animate: $animateScores
                    )
                }
                .padding(.horizontal, 20)

                // Quick Actions
                VStack(spacing: 12) {
                    GlowingQuickActionCard(
                        title: "Today's Routine",
                        subtitle: "Morning Glass Skin Ritual",
                        icon: "sun.max.fill",
                        gradient: [Color(hex: "FFD700"), Color(hex: "FFA500")]
                    )

                    GlowingQuickActionCard(
                        title: "Product Scanner",
                        subtitle: "Check product compatibility",
                        icon: "barcode.viewfinder",
                        gradient: [Color(hex: "DA70D6"), Color(hex: "BA55D3")]
                    )

                    GlowingQuickActionCard(
                        title: "Skin Journal",
                        subtitle: "Track your glow up journey",
                        icon: "book.fill",
                        gradient: [Color(hex: "98D8C8"), Color(hex: "7FCDCD")]
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
        }
        .ignoresSafeArea(edges: .top)
        .onAppear {
            withAnimation(.easeInOut(duration: 1)) {
                animateScores = true
            }
        }
        .sheet(isPresented: $showingSkinScan) {
            BeautifulSkinScanView()
        }
    }
}

// MARK: - Score Card Component
struct ScoreCard: View {
    let title: String
    let score: Int
    let maxScore: Int
    let icon: String
    let color: Color
    let suffix: String
    @Binding var animate: Bool

    @State private var displayedScore: CGFloat = 0

    var body: some View {
        VStack(spacing: 12) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)

            // Title
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)

            // Score
            HStack(spacing: 0) {
                Text("\(Int(displayedScore))")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.black)

                Text(suffix)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
            }

            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * (displayedScore / CGFloat(maxScore)), height: 8)
                        .animation(.spring(response: 1, dampingFraction: 0.7), value: displayedScore)
                }
            }
            .frame(height: 8)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: color.opacity(0.2), radius: 10, x: 0, y: 5)
        )
        .onAppear {
            if animate {
                withAnimation(.easeOut(duration: 1.5).delay(0.3)) {
                    displayedScore = CGFloat(score)
                }
            }
        }
        .onChange(of: animate) { newValue in
            if newValue {
                withAnimation(.easeOut(duration: 1.5).delay(0.3)) {
                    displayedScore = CGFloat(score)
                }
            }
        }
    }
}

// MARK: - Quick Action Card
struct GlowingQuickActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let gradient: [Color]

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)

                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(.white)
            }

            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)

                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }

            Spacer()

            // Arrow
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    SkinGlowingHomeView()
}