//
//  SkinAnalysis.swift
//  SkinGlowing
//
//  Data models for skin analysis and scoring
//

import Foundation
import SwiftUI
import Combine

// MARK: - Skin Metrics
struct SkinMetrics: Codable, Identifiable {
    let id = UUID()
    let overallScore: Int // 0-100
    let hydration: Int // 0-100
    let acne: Int // 0-100 (higher is better/less acne)
    let glow: Int // 0-100
    let aging: Int // 0-100 (higher is better/younger looking)
    let timestamp: Date

    var overallGrade: String {
        switch overallScore {
        case 90...100: return "A+"
        case 85..<90: return "A"
        case 80..<85: return "B+"
        case 75..<80: return "B"
        case 70..<75: return "C+"
        case 65..<70: return "C"
        case 60..<65: return "D"
        default: return "F"
        }
    }

    var hydrationLevel: String {
        switch hydration {
        case 80...100: return "Excellent"
        case 60..<80: return "Good"
        case 40..<60: return "Fair"
        case 20..<40: return "Poor"
        default: return "Very Dry"
        }
    }

    var acneStatus: String {
        switch acne {
        case 90...100: return "Clear"
        case 70..<90: return "Mild"
        case 50..<70: return "Moderate"
        case 30..<50: return "Significant"
        default: return "Severe"
        }
    }

    var glowLevel: String {
        switch glow {
        case 80...100: return "Radiant"
        case 60..<80: return "Healthy"
        case 40..<60: return "Dull"
        default: return "Lackluster"
        }
    }

    var agingStatus: String {
        switch aging {
        case 90...100: return "Youthful"
        case 70..<90: return "Minimal Signs"
        case 50..<70: return "Some Signs"
        case 30..<50: return "Visible Signs"
        default: return "Advanced Signs"
        }
    }
}

// MARK: - Skin Scan Result
struct SkinScanResult: Codable, Identifiable {
    let id: UUID
    let metrics: SkinMetrics
    let imageData: Data?
    let recommendations: [String]
    let routineSteps: [RoutineStep]
    let timestamp: Date
    let userConcerns: [String]
    let skinType: String

    init(id: UUID = UUID(), metrics: SkinMetrics, imageData: Data?, recommendations: [String], routineSteps: [RoutineStep], timestamp: Date, userConcerns: [String], skinType: String) {
        self.id = id
        self.metrics = metrics
        self.imageData = imageData
        self.recommendations = recommendations
        self.routineSteps = routineSteps
        self.timestamp = timestamp
        self.userConcerns = userConcerns
        self.skinType = skinType
    }
}

// MARK: - Routine Step
struct RoutineStep: Codable, Identifiable {
    let id: UUID
    let stepNumber: Int
    let title: String
    let description: String
    let duration: String // e.g., "30 seconds", "2 minutes"
    let productType: String // e.g., "Cleanser", "Serum", "Moisturizer"
    let iconName: String // SF Symbol name
    let color: String // Hex color for TikTok-style display
    let tips: [String]

    init(id: UUID = UUID(), stepNumber: Int, title: String, description: String, duration: String, productType: String, iconName: String, color: String, tips: [String]) {
        self.id = id
        self.stepNumber = stepNumber
        self.title = title
        self.description = description
        self.duration = duration
        self.productType = productType
        self.iconName = iconName
        self.color = color
        self.tips = tips
    }
}

// MARK: - Skin Chat Message (renamed to avoid conflicts)
struct SkinChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isFromUser: Bool
    let timestamp: Date
}

// MARK: - Archive Entry
struct ArchiveEntry: Codable, Identifiable {
    let id = UUID()
    let scanResult: SkinScanResult
    let notes: String?
    let isFavorite: Bool

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: scanResult.timestamp)
    }
}

// MARK: - API Service
class SkinAnalysisService: ObservableObject {
    static let shared = SkinAnalysisService()

    @Published var isAnalyzing = false
    @Published var currentAnalysis: SkinScanResult?
    @Published var scanHistory: [ArchiveEntry] = []

    func analyzeSkin(imageData: Data, concerns: [String], skinType: String) async throws -> SkinScanResult {
        // Simulate API call - in production, this would call OpenAI API
        isAnalyzing = true

        // Simulate processing delay
        try await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds

        // Generate mock results (in production, these would come from AI analysis)
        let metrics = SkinMetrics(
            overallScore: Int.random(in: 70...95),
            hydration: Int.random(in: 60...90),
            acne: Int.random(in: 50...95),
            glow: Int.random(in: 65...90),
            aging: Int.random(in: 70...95),
            timestamp: Date()
        )

        let recommendations = generateRecommendations(for: metrics, concerns: concerns)
        let routine = generateRoutine(for: skinType, metrics: metrics)

        let result = SkinScanResult(
            metrics: metrics,
            imageData: imageData,
            recommendations: recommendations,
            routineSteps: routine,
            timestamp: Date(),
            userConcerns: concerns,
            skinType: skinType
        )

        currentAnalysis = result
        isAnalyzing = false

        // Save to history
        let archiveEntry = ArchiveEntry(scanResult: result, notes: nil, isFavorite: false)
        scanHistory.insert(archiveEntry, at: 0)

        return result
    }

    private func generateRecommendations(for metrics: SkinMetrics, concerns: [String]) -> [String] {
        var recommendations: [String] = []

        if metrics.hydration < 70 {
            recommendations.append("Increase water intake to 8-10 glasses daily")
            recommendations.append("Use a hyaluronic acid serum twice daily")
        }

        if metrics.acne < 70 {
            recommendations.append("Consider adding salicylic acid to your routine")
            recommendations.append("Avoid heavy, pore-clogging products")
        }

        if metrics.glow < 70 {
            recommendations.append("Exfoliate 2-3 times per week")
            recommendations.append("Add vitamin C serum to your morning routine")
        }

        if metrics.aging < 80 {
            recommendations.append("Apply SPF 30+ sunscreen daily")
            recommendations.append("Consider retinol for evening use")
        }

        return recommendations
    }

    private func generateRoutine(for skinType: String, metrics: SkinMetrics) -> [RoutineStep] {
        var steps: [RoutineStep] = []

        // Morning routine
        steps.append(RoutineStep(
            stepNumber: 1,
            title: "Gentle Cleanse",
            description: "Start with a hydrating cleanser",
            duration: "60 seconds",
            productType: "Cleanser",
            iconName: "drop.fill",
            color: "#87CEEB",
            tips: ["Use lukewarm water", "Massage in circular motions"]
        ))

        steps.append(RoutineStep(
            stepNumber: 2,
            title: "Tone & Prep",
            description: "Balance your skin's pH",
            duration: "30 seconds",
            productType: "Toner",
            iconName: "sparkles",
            color: "#E6B8E6",
            tips: ["Pat gently", "Don't rub"]
        ))

        if metrics.acne < 80 {
            steps.append(RoutineStep(
                stepNumber: 3,
                title: "Treat Acne",
                description: "Apply targeted treatment",
                duration: "45 seconds",
                productType: "Treatment",
                iconName: "star.fill",
                color: "#98FB98",
                tips: ["Spot treat only", "Allow to absorb fully"]
            ))
        }

        steps.append(RoutineStep(
            stepNumber: steps.count + 1,
            title: "Hydrate",
            description: "Lock in moisture",
            duration: "45 seconds",
            productType: "Moisturizer",
            iconName: "cloud.fill",
            color: "#FFB6C1",
            tips: ["Apply to damp skin", "Don't forget your neck"]
        ))

        steps.append(RoutineStep(
            stepNumber: steps.count + 1,
            title: "Protect",
            description: "Shield from UV damage",
            duration: "30 seconds",
            productType: "Sunscreen",
            iconName: "sun.max.fill",
            color: "#FFD700",
            tips: ["Reapply every 2 hours", "Use SPF 30 minimum"]
        ))

        return steps
    }
}

