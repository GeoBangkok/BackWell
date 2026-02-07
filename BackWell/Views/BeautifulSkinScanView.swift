//
//  BeautifulSkinScanView.swift
//  SkinGlowing
//
//  Beautiful skin scanning experience with live camera

import SwiftUI
import AVFoundation

struct BeautifulSkinScanView: View {
    @Environment(\.dismiss) var dismiss
    @State private var isScanning = false
    @State private var scanProgress: CGFloat = 0
    @State private var showResults = false
    @State private var pulseAnimation = false

    // Scan Results
    @State private var skinAge = 0
    @State private var glassSkinScore = 0
    @State private var blemishesScore = 0
    @State private var hydrationScore = 0

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(hex: "FFE0EC"),
                    Color(hex: "FFC0CB")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            if !showResults {
                // Scanning View
                VStack(spacing: 30) {
                    // Close Button
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 50)

                    Spacer()

                    // Camera View Placeholder
                    ZStack {
                        // Face outline
                        RoundedRectangle(cornerRadius: 120)
                            .stroke(
                                LinearGradient(
                                    colors: [Color(hex: "FF91A4"), Color(hex: "FFB6C1")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                            .frame(width: 250, height: 320)
                            .overlay(
                                // Scanning animation
                                RoundedRectangle(cornerRadius: 120)
                                    .stroke(Color.white.opacity(0.5), lineWidth: 2)
                                    .frame(width: 250, height: 320)
                                    .scaleEffect(pulseAnimation ? 1.1 : 1)
                                    .opacity(pulseAnimation ? 0 : 1)
                                    .animation(.easeOut(duration: 1.5).repeatForever(autoreverses: false), value: pulseAnimation)
                            )

                        // Face icon
                        Image(systemName: "face.smiling")
                            .font(.system(size: 100))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "FF91A4").opacity(0.6), Color(hex: "FFB6C1").opacity(0.6)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                        // Scanning line
                        if isScanning {
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "FF91A4").opacity(0),
                                            Color(hex: "FF91A4"),
                                            Color(hex: "FF91A4").opacity(0)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: 230, height: 2)
                                .offset(y: -160 + (320 * scanProgress))
                                .animation(.linear(duration: 3), value: scanProgress)
                        }
                    }

                    // Instructions
                    VStack(spacing: 12) {
                        Text(isScanning ? "Analyzing your skin..." : "Position your face in the frame")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)

                        if isScanning {
                            // Progress Bar
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(.white.opacity(0.3))

                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color(hex: "FF91A4"), Color(hex: "FFB6C1")],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geometry.size.width * scanProgress)
                                        .animation(.linear(duration: 3), value: scanProgress)
                                }
                            }
                            .frame(height: 20)
                            .padding(.horizontal, 50)

                            Text("\(Int(scanProgress * 100))% Complete")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }

                    Spacer()

                    // Scan Button
                    if !isScanning {
                        Button(action: startScan) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "FF91A4"), Color(hex: "FF69B4")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 80, height: 80)

                                Image(systemName: "camera.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                            }
                        }
                        .shadow(color: Color(hex: "FF91A4").opacity(0.4), radius: 20, x: 0, y: 10)
                        .padding(.bottom, 50)
                    }
                }
            } else {
                // Results View
                SkinScanResultsView(
                    skinAge: skinAge,
                    glassSkinScore: glassSkinScore,
                    blemishesScore: blemishesScore,
                    hydrationScore: hydrationScore,
                    onClose: { dismiss() }
                )
            }
        }
        .onAppear {
            pulseAnimation = true
        }
    }

    private func startScan() {
        isScanning = true
        scanProgress = 0

        // Simulate scanning
        withAnimation(.linear(duration: 3)) {
            scanProgress = 1
        }

        // Show results after scan
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            // Generate random scores for demo
            skinAge = Int.random(in: 20...35)
            glassSkinScore = Int.random(in: 70...95)
            blemishesScore = Int.random(in: 60...90)
            hydrationScore = Int.random(in: 65...85)

            withAnimation(.spring()) {
                showResults = true
            }
        }
    }
}

// MARK: - Results View
struct SkinScanResultsView: View {
    let skinAge: Int
    let glassSkinScore: Int
    let blemishesScore: Int
    let hydrationScore: Int
    let onClose: () -> Void

    @State private var showScores = false

    var overallGrade: String {
        let average = (glassSkinScore + blemishesScore + hydrationScore) / 3
        switch average {
        case 90...100: return "A+"
        case 80...89: return "A"
        case 70...79: return "B"
        case 60...69: return "C"
        default: return "D"
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 25) {
                // Header
                HStack {
                    Button(action: onClose) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 50)

                // Title
                VStack(spacing: 8) {
                    Text("Your Skin Analysis")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Scanned on \(Date().formatted(date: .abbreviated, time: .omitted))")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }

                // Overall Grade
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 150, height: 150)

                    VStack(spacing: 4) {
                        Text("Overall")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))

                        Text(overallGrade)
                            .font(.system(size: 60, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                .scaleEffect(showScores ? 1 : 0.5)
                .opacity(showScores ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: showScores)

                // Score Cards
                VStack(spacing: 16) {
                    ResultCard(
                        title: "Biological Skin Age",
                        score: skinAge,
                        suffix: " years",
                        description: "Your skin appears younger than your actual age",
                        icon: "clock.fill",
                        color: Color(hex: "FF91A4"),
                        delay: 0.3,
                        showScore: showScores
                    )

                    ResultCard(
                        title: "Glass Skin Score",
                        score: glassSkinScore,
                        suffix: "%",
                        description: "Luminosity and translucency level",
                        icon: "sparkles",
                        color: Color(hex: "87CEEB"),
                        delay: 0.4,
                        showScore: showScores
                    )

                    ResultCard(
                        title: "Clear Skin Score",
                        score: blemishesScore,
                        suffix: "%",
                        description: "Clarity and smoothness assessment",
                        icon: "star.fill",
                        color: Color(hex: "98D8C8"),
                        delay: 0.5,
                        showScore: showScores
                    )

                    ResultCard(
                        title: "Hydration Level",
                        score: hydrationScore,
                        suffix: "%",
                        description: "Moisture retention capacity",
                        icon: "drop.fill",
                        color: Color(hex: "89CFF0"),
                        delay: 0.6,
                        showScore: showScores
                    )
                }
                .padding(.horizontal, 20)

                // Recommendations Button
                Button(action: {}) {
                    HStack {
                        Text("View Personalized Recommendations")
                            .font(.system(size: 16, weight: .semibold))

                        Image(systemName: "arrow.right")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(Color(hex: "FF91A4"))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(.white)
                    )
                }
                .shadow(color: .white.opacity(0.3), radius: 10, x: 0, y: 5)
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            withAnimation {
                showScores = true
            }
        }
    }
}

struct ResultCard: View {
    let title: String
    let score: Int
    let suffix: String
    let description: String
    let icon: String
    let color: Color
    let delay: Double
    let showScore: Bool

    @State private var displayedScore: CGFloat = 0

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)

                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
            }

            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                HStack(spacing: 4) {
                    Text("\(Int(displayedScore))")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text(suffix)
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                }

                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.15))
        )
        .opacity(showScore ? 1 : 0)
        .offset(y: showScore ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay), value: showScore)
        .onAppear {
            if showScore {
                withAnimation(.easeOut(duration: 1).delay(delay + 0.2)) {
                    displayedScore = CGFloat(score)
                }
            }
        }
        .onChange(of: showScore) { newValue in
            if newValue {
                withAnimation(.easeOut(duration: 1).delay(delay + 0.2)) {
                    displayedScore = CGFloat(score)
                }
            }
        }
    }
}

#Preview {
    BeautifulSkinScanView()
}