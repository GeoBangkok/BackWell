//
//  HapticFeedback.swift
//  BackWell
//
//  Shared haptic feedback utility
//

import UIKit

/// Provides haptic feedback with the specified style
/// - Parameter style: The style of haptic feedback to generate
func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
    let generator = UIImpactFeedbackGenerator(style: style)
    generator.prepare()
    generator.impactOccurred()
}