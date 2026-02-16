//
//  Theme.swift
//  SkinGlowing
//
//  Apple-clean design system: white + black + red accent
//

import SwiftUI

// MARK: - Design System

struct Theme {
    // MARK: - Backgrounds
    static let background = Color.white
    static let backgroundSecondary = Color(red: 0.976, green: 0.976, blue: 0.980) // #F9F9FA

    // MARK: - Text
    static let headline = Color.black
    static let bodyText = Color(red: 0.27, green: 0.27, blue: 0.27) // #454545
    static let captionText = Color(red: 0.60, green: 0.62, blue: 0.65) // #999EA6
    static let mutedText = Color(red: 0.75, green: 0.76, blue: 0.78) // #BFC2C7

    // MARK: - Accent (Red — used sparingly)
    static let accent = Color(red: 0.86, green: 0.15, blue: 0.15) // #DB2626
    static let accentSoft = Color(red: 0.86, green: 0.15, blue: 0.15).opacity(0.08)

    // MARK: - Status Colors
    static let statusGreen = Color(red: 0.13, green: 0.77, blue: 0.37) // #22C55E
    static let statusYellow = Color(red: 0.89, green: 0.68, blue: 0.07) // #E3AD12
    static let statusRed = Color(red: 0.94, green: 0.27, blue: 0.27) // #EF4444

    // MARK: - Card System
    static let cardCorner: CGFloat = 18
    static let cardShadowColor = Color.black.opacity(0.06)
    static let cardShadowRadius: CGFloat = 12

    // MARK: - Backward Compatibility (old views still compile)
    static let purple = Color(red: 0.486, green: 0.227, blue: 0.929)
    static let purpleDark = Color(red: 0.357, green: 0.129, blue: 0.714)
    static let purpleLight = Color(red: 0.655, green: 0.545, blue: 0.980)
    static let purpleUltraLight = Color(red: 0.929, green: 0.914, blue: 0.996)
    static let pinkAccent = Color(red: 0.925, green: 0.282, blue: 0.600)
    static let success = Color(red: 0.063, green: 0.725, blue: 0.506)
    static let warning = Color(red: 0.961, green: 0.620, blue: 0.043)
    static let error = Color(red: 0.937, green: 0.267, blue: 0.267)
    static let white = Color.white
    static let offWhite = Color(red: 0.980, green: 0.980, blue: 0.980)
    static let borderLight = Color(red: 0.898, green: 0.906, blue: 0.922)
    static let textPrimary = Color(red: 0.122, green: 0.161, blue: 0.216)
    static let textSecondary = Color(red: 0.420, green: 0.447, blue: 0.502)
    static let textMuted = Color(red: 0.612, green: 0.639, blue: 0.686)
    static let textOnPurple = Color.white
    static let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [purple, pinkAccent]),
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let softBackgroundGradient = LinearGradient(
        gradient: Gradient(colors: [Color.white, purpleUltraLight]),
        startPoint: .top, endPoint: .bottom
    )
    static let onboardingBackground = LinearGradient(
        gradient: Gradient(colors: [purpleUltraLight, Color.white, Color(red: 0.996, green: 0.949, blue: 0.973)]),
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let buttonGradient = LinearGradient(
        gradient: Gradient(colors: [purple, purpleDark]),
        startPoint: .leading, endPoint: .trailing
    )
    static let secondaryButtonGradient = LinearGradient(
        gradient: Gradient(colors: [pinkAccent, purple]),
        startPoint: .leading, endPoint: .trailing
    )
    static let blurOverlay = purple.opacity(0.85)
    static let shadow = Color.black.opacity(0.1)
    static let glow = purple.opacity(0.3)
}

// MARK: - View Extensions

extension View {
    // New design system
    func sgCard() -> some View {
        self
            .background(Color.white)
            .cornerRadius(Theme.cardCorner)
            .shadow(color: Theme.cardShadowColor, radius: Theme.cardShadowRadius, x: 0, y: 4)
    }

    func sgAccentButton() -> some View {
        self
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(RoundedRectangle(cornerRadius: 28).fill(Theme.accent))
    }

    // Backward compat
    func appBackground() -> some View {
        self.background(Theme.onboardingBackground.ignoresSafeArea())
    }
    func primaryButtonStyle() -> some View {
        self
            .foregroundColor(Theme.textOnPurple)
            .font(.headline)
            .padding()
            .background(Theme.buttonGradient)
            .cornerRadius(12)
            .shadow(color: Theme.shadow, radius: 4, x: 0, y: 2)
    }
    func cardStyle() -> some View {
        self
            .background(Theme.white)
            .cornerRadius(16)
            .shadow(color: Theme.shadow, radius: 8, x: 0, y: 4)
    }
}

// MARK: - Color Hex Extension (shared across all files)

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Shimmer Effect

struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [
                            .clear,
                            Color.white.opacity(0.4),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 0.6)
                    .offset(x: phase * geo.size.width * 1.6 - geo.size.width * 0.3)
                }
            )
            .clipped()
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerEffect())
    }
}
