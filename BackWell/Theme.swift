//
//  Theme.swift
//  BackWell
//
//  Brand colors and theme for BackWell app
//

import SwiftUI

struct Theme {
    // MARK: - Primary Brand Colors

    /// Main teal color - #1A9B9A
    static let teal = Color(red: 0.102, green: 0.608, blue: 0.604)

    /// Darker teal for gradients and accents
    static let tealDark = Color(red: 0.08, green: 0.50, blue: 0.50)

    /// Lighter teal for backgrounds
    static let tealLight = Color(red: 0.15, green: 0.65, blue: 0.65)

    // MARK: - Text Colors

    /// Primary text color (dark blue-gray)
    static let textPrimary = Color(red: 0.15, green: 0.30, blue: 0.35)

    /// Secondary text color (medium gray)
    static let textSecondary = Color(red: 0.35, green: 0.45, blue: 0.50)

    /// Tertiary/muted text color
    static let textMuted = Color(red: 0.45, green: 0.55, blue: 0.60)

    // MARK: - Background Gradient

    /// Main app background gradient colors
    static let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.92, green: 0.96, blue: 0.97),
            Color(red: 0.85, green: 0.93, blue: 0.95),
            Color(red: 0.78, green: 0.90, blue: 0.92)
        ]),
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: - Button Gradient

    /// Primary button gradient
    static let buttonGradient = LinearGradient(
        gradient: Gradient(colors: [tealLight, teal]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Convenience Extensions

extension View {
    func appBackground() -> some View {
        self.background(Theme.backgroundGradient.ignoresSafeArea())
    }
}
