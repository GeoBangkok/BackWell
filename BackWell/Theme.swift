//
//  Theme.swift
//  SkinWell
//
//  Modern purple theme for SkinWell AI skincare app
//

import SwiftUI

struct Theme {
    // MARK: - Primary Brand Colors

    /// Main purple color - #7C3AED
    static let purple = Color(red: 0.486, green: 0.227, blue: 0.929)

    /// Darker purple for gradients and depth - #5B21B6
    static let purpleDark = Color(red: 0.357, green: 0.129, blue: 0.714)

    /// Lighter purple for soft backgrounds - #A78BFA
    static let purpleLight = Color(red: 0.655, green: 0.545, blue: 0.980)

    /// Ultra light purple for cards - #EDE9FE
    static let purpleUltraLight = Color(red: 0.929, green: 0.914, blue: 0.996)

    // MARK: - Accent Colors

    /// Pink accent for CTAs - #EC4899
    static let pinkAccent = Color(red: 0.925, green: 0.282, blue: 0.600)

    /// Success green - #10B981
    static let success = Color(red: 0.063, green: 0.725, blue: 0.506)

    /// Warning amber - #F59E0B
    static let warning = Color(red: 0.961, green: 0.620, blue: 0.043)

    /// Error red - #EF4444
    static let error = Color(red: 0.937, green: 0.267, blue: 0.267)

    // MARK: - Neutral Colors

    /// Pure white
    static let white = Color.white

    /// Off white for cards - #FAFAFA
    static let offWhite = Color(red: 0.980, green: 0.980, blue: 0.980)

    /// Light gray for borders - #E5E7EB
    static let borderLight = Color(red: 0.898, green: 0.906, blue: 0.922)

    // MARK: - Text Colors

    /// Primary text color (dark gray) - #1F2937
    static let textPrimary = Color(red: 0.122, green: 0.161, blue: 0.216)

    /// Secondary text color (medium gray) - #6B7280
    static let textSecondary = Color(red: 0.420, green: 0.447, blue: 0.502)

    /// Tertiary/muted text color - #9CA3AF
    static let textMuted = Color(red: 0.612, green: 0.639, blue: 0.686)

    /// Text on purple backgrounds
    static let textOnPurple = Color.white

    // MARK: - Background Gradients

    /// Main app background gradient - purple to pink
    static let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            purple,
            pinkAccent
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Soft background gradient for cards
    static let softBackgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color.white,
            purpleUltraLight
        ]),
        startPoint: .top,
        endPoint: .bottom
    )

    /// Onboarding background - lighter variant
    static let onboardingBackground = LinearGradient(
        gradient: Gradient(colors: [
            purpleUltraLight,
            Color.white,
            Color(red: 0.996, green: 0.949, blue: 0.973) // Pink tint
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Button Gradients

    /// Primary button gradient
    static let buttonGradient = LinearGradient(
        gradient: Gradient(colors: [purple, purpleDark]),
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Secondary button gradient (pink accent)
    static let secondaryButtonGradient = LinearGradient(
        gradient: Gradient(colors: [pinkAccent, purple]),
        startPoint: .leading,
        endPoint: .trailing
    )

    // MARK: - Special Effects

    /// Blur overlay color for locked content
    static let blurOverlay = purple.opacity(0.85)

    /// Shadow color
    static let shadow = Color.black.opacity(0.1)

    /// Glow effect color
    static let glow = purple.opacity(0.3)
}

// MARK: - Convenience Extensions

extension View {
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