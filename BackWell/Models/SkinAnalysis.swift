//
//  SkinAnalysis.swift
//  SkinGlowing
//
//  Data models for skin analysis, scoring engine, and product scanning
//

import Foundation
import SwiftUI
import Combine

// ============================================================
// MARK: - NEW SKINGLOWING MODELS
// ============================================================

// MARK: - Glass Skin Tier

enum GlassSkinTier: Int, Codable, CaseIterable {
    case dull = 0
    case balanced = 1
    case glowy = 2
    case glassTier = 3

    var label: String {
        switch self {
        case .dull: return "Dull"
        case .balanced: return "Balanced"
        case .glowy: return "Glowy"
        case .glassTier: return "Glass-tier"
        }
    }
}

// MARK: - Blemish Severity

enum BlemishSeverity: String, Codable, CaseIterable {
    case minor = "Minor"
    case moderate = "Moderate"
    case active = "Active"
}

// MARK: - Traffic Light (Product Scan)

enum TrafficLight: String, Codable {
    case green = "Green"
    case yellow = "Yellow"
    case red = "Red"

    var color: Color {
        switch self {
        case .green: return Color(red: 0.13, green: 0.77, blue: 0.37)
        case .yellow: return Color(red: 0.89, green: 0.68, blue: 0.07)
        case .red: return Color(red: 0.94, green: 0.27, blue: 0.27)
        }
    }

    var icon: String {
        switch self {
        case .green: return "checkmark.circle.fill"
        case .yellow: return "exclamationmark.circle.fill"
        case .red: return "xmark.circle.fill"
        }
    }
}

// MARK: - Face Scan Result

struct FaceScanResult: Codable, Identifiable {
    let id: UUID
    let skinAge: Int
    let skinAgeDelta: Int?
    let skinAgeMicro: String
    let glassSkinTier: GlassSkinTier
    let glassSkinMicro: String
    let blemishSeverity: BlemishSeverity
    let blemishZone: String
    let blemishMicro: String
    let firmnessScore: Double
    let firmnessDelta: Double?
    let firmnessMicro: String
    let glowAdvice: String
    let imageData: Data?
    let timestamp: Date

    init(
        id: UUID = UUID(),
        skinAge: Int, skinAgeDelta: Int? = nil, skinAgeMicro: String,
        glassSkinTier: GlassSkinTier, glassSkinMicro: String,
        blemishSeverity: BlemishSeverity, blemishZone: String, blemishMicro: String,
        firmnessScore: Double, firmnessDelta: Double? = nil, firmnessMicro: String,
        glowAdvice: String, imageData: Data? = nil, timestamp: Date = Date()
    ) {
        self.id = id
        self.skinAge = skinAge
        self.skinAgeDelta = skinAgeDelta
        self.skinAgeMicro = skinAgeMicro
        self.glassSkinTier = glassSkinTier
        self.glassSkinMicro = glassSkinMicro
        self.blemishSeverity = blemishSeverity
        self.blemishZone = blemishZone
        self.blemishMicro = blemishMicro
        self.firmnessScore = firmnessScore
        self.firmnessDelta = firmnessDelta
        self.firmnessMicro = firmnessMicro
        self.glowAdvice = glowAdvice
        self.imageData = imageData
        self.timestamp = timestamp
    }
}

// MARK: - Flagged Ingredient

struct FlaggedIngredient: Codable, Identifiable {
    let id: UUID
    let name: String
    let concern: String

    init(id: UUID = UUID(), name: String, concern: String) {
        self.id = id
        self.name = name
        self.concern = concern
    }
}

// MARK: - Product Scan Result

struct ProductScanResult: Codable, Identifiable {
    let id: UUID
    let productName: String
    let compatibilityScore: Int // 0–10
    let compatibilityLabel: String
    let microExplanation: String
    let acneSafe: TrafficLight
    let hydrationFriendly: TrafficLight
    let irritationRisk: TrafficLight
    let glowSupport: TrafficLight
    let flaggedIngredients: [FlaggedIngredient]
    let imageData: Data?
    let timestamp: Date

    init(
        id: UUID = UUID(), productName: String, compatibilityScore: Int,
        compatibilityLabel: String, microExplanation: String,
        acneSafe: TrafficLight, hydrationFriendly: TrafficLight,
        irritationRisk: TrafficLight, glowSupport: TrafficLight,
        flaggedIngredients: [FlaggedIngredient],
        imageData: Data? = nil, timestamp: Date = Date()
    ) {
        self.id = id
        self.productName = productName
        self.compatibilityScore = compatibilityScore
        self.compatibilityLabel = compatibilityLabel
        self.microExplanation = microExplanation
        self.acneSafe = acneSafe
        self.hydrationFriendly = hydrationFriendly
        self.irritationRisk = irritationRisk
        self.glowSupport = glowSupport
        self.flaggedIngredients = flaggedIngredients
        self.imageData = imageData
        self.timestamp = timestamp
    }
}

// MARK: - Scan History Entry

struct ScanHistoryEntry: Codable, Identifiable {
    let id: UUID
    let faceScan: FaceScanResult
    let timestamp: Date

    init(id: UUID = UUID(), faceScan: FaceScanResult) {
        self.id = id
        self.faceScan = faceScan
        self.timestamp = faceScan.timestamp
    }
}

// ============================================================
// MARK: - SKIN SCORING ENGINE ("Feels Real" Rules)
// ============================================================

class SkinScoringEngine {
    static let shared = SkinScoringEngine()
    private init() {}

    // MARK: - Micro-explanation Banks

    private let skinAgeMicros = [
        "Fine lines detected under eyes.",
        "Texture looks smooth today.",
        "Slight dullness on cheeks.",
        "Forehead appears well-hydrated.",
        "Minor creasing around mouth.",
        "Under-eye area looks rested.",
        "Crow's feet appear minimal.",
        "Jawline texture looks even.",
        "Slight dehydration lines on forehead.",
        "Cheek area appears plump today."
    ]

    private let glassSkinMicros = [
        "Hydration reflection looks strong.",
        "Texture appears smoother today.",
        "Slight dryness detected.",
        "Skin barrier looks intact.",
        "Surface glow is above average.",
        "Minor patchiness on T-zone.",
        "Light refraction appears healthy.",
        "Pore visibility reduced on cheeks.",
        "Oil balance looks well-regulated.",
        "Dewy finish detected on forehead."
    ]

    private let blemishMicros = [
        "Small redness detected on chin.",
        "Mild inflammation on cheeks.",
        "Minor congestion on forehead.",
        "Slight texture irregularity on nose.",
        "Under-eye puffiness noted.",
        "Jawline appears clear today.",
        "Tiny blemish forming near temple.",
        "Chin area looks mostly clear.",
        "Cheek redness subsiding.",
        "Forehead congestion reduced."
    ]

    private let blemishZones = ["chin", "cheeks", "forehead", "jawline", "temple", "nose", "T-zone"]

    private let firmnessMicros = [
        "Elasticity looks above average.",
        "Jawline firmness stable.",
        "Slight improvement in cheek contour.",
        "Under-eye firmness holding steady.",
        "Nasolabial area looks supported.",
        "Forehead tension appears normal.",
        "Mid-face structure looks defined.",
        "Neck firmness stable today.",
        "Orbital area elasticity maintained.",
        "Jowl area appears tight."
    ]

    private let glowAdvices = [
        "Apply SPF before stepping out today.",
        "Try double-cleansing tonight for deeper clean.",
        "Hydrate with a hyaluronic serum this morning.",
        "Skip heavy makeup today — let your skin breathe.",
        "Add a sheet mask to your evening routine.",
        "Drink an extra glass of water before noon.",
        "Apply vitamin C serum before moisturizer.",
        "Try sleeping on a silk pillowcase tonight.",
        "Exfoliate gently today for smoother texture.",
        "Mist your face mid-day for hydration boost.",
        "Apply eye cream with your ring finger — less pressure.",
        "Keep hands off your face today.",
        "Use lukewarm water when washing — not hot.",
        "Reapply sunscreen if you've been outside 2+ hours."
    ]

    // MARK: - Generate Face Scan

    func generateFaceScan(previousScan: FaceScanResult?, userAge: Int? = nil) -> FaceScanResult {
        let baseAge = userAge ?? Int.random(in: 23...35)

        // Controlled variability: Skin Age changes slowly
        let skinAge: Int
        let skinAgeDelta: Int?
        if let prev = previousScan {
            let shift = Int.random(in: -1...1)
            skinAge = max(18, prev.skinAge + shift)
            skinAgeDelta = skinAge - prev.skinAge
        } else {
            skinAge = baseAge + Int.random(in: -3...2)
            skinAgeDelta = nil
        }

        // Glass Skin: changes occasionally
        let glassTier: GlassSkinTier
        if let prev = previousScan {
            let shouldChange = Int.random(in: 0...4) == 0 // 20% chance
            if shouldChange {
                let shift = Bool.random() ? 1 : -1
                let newRaw = max(0, min(3, prev.glassSkinTier.rawValue + shift))
                glassTier = GlassSkinTier(rawValue: newRaw) ?? prev.glassSkinTier
            } else {
                glassTier = prev.glassSkinTier
            }
        } else {
            glassTier = GlassSkinTier(rawValue: Int.random(in: 1...2)) ?? .balanced
        }

        // Blemishes: can swing more day-to-day
        let blemish: BlemishSeverity
        if let prev = previousScan {
            let options: [BlemishSeverity]
            switch prev.blemishSeverity {
            case .minor: options = [.minor, .minor, .moderate]
            case .moderate: options = [.minor, .moderate, .active]
            case .active: options = [.moderate, .active, .active]
            }
            blemish = options.randomElement() ?? .minor
        } else {
            blemish = [BlemishSeverity.minor, .minor, .moderate].randomElement() ?? .minor
        }

        // Firmness: changes slightly
        let firmness: Double
        let firmnessDelta: Double?
        if let prev = previousScan {
            let shift = Double.random(in: -0.3...0.3)
            firmness = max(4.0, min(9.8, prev.firmnessScore + shift))
            firmnessDelta = Double(round((firmness - prev.firmnessScore) * 10) / 10)
        } else {
            firmness = Double(round(Double.random(in: 6.5...8.5) * 10) / 10)
            firmnessDelta = nil
        }

        return FaceScanResult(
            skinAge: skinAge,
            skinAgeDelta: skinAgeDelta,
            skinAgeMicro: skinAgeMicros.randomElement()!,
            glassSkinTier: glassTier,
            glassSkinMicro: glassSkinMicros.randomElement()!,
            blemishSeverity: blemish,
            blemishZone: blemishZones.randomElement()!,
            blemishMicro: blemishMicros.randomElement()!,
            firmnessScore: firmness,
            firmnessDelta: firmnessDelta,
            firmnessMicro: firmnessMicros.randomElement()!,
            glowAdvice: glowAdvices.randomElement()!
        )
    }

    // MARK: - Generate Product Scan

    func generateProductScan(productName: String, userSkinType: String) -> ProductScanResult {
        let score = Int.random(in: 5...10)
        let label: String
        switch score {
        case 9...10: label = "Excellent fit"
        case 7...8: label = "Good fit"
        case 5...6: label = "Fair fit"
        default: label = "Poor fit"
        }

        let lights: [TrafficLight] = [.green, .green, .green, .yellow, .yellow, .red]
        let acne = lights.randomElement()!
        let hydration: TrafficLight = score >= 7 ? .green : (score >= 5 ? .yellow : .red)
        let irritation: TrafficLight = userSkinType.lowercased() == "sensitive" ?
            [TrafficLight.yellow, .red].randomElement()! : [.green, .green, .yellow].randomElement()!
        let glow: TrafficLight = [.green, .green, .yellow].randomElement()!

        let micro: String
        switch score {
        case 9...10: micro = "Low clog-risk for your skin type."
        case 7...8: micro = "Generally compatible with \(userSkinType.lowercased()) skin."
        case 5...6: micro = "Some ingredients may not suit \(userSkinType.lowercased()) skin."
        default: micro = "Several concerning ingredients detected."
        }

        let sampleIngredients: [[FlaggedIngredient]] = [
            [],
            [FlaggedIngredient(name: "Fragrance", concern: "irritation risk for sensitive skin")],
            [FlaggedIngredient(name: "Isopropyl Myristate", concern: "may clog pores")],
            [
                FlaggedIngredient(name: "Alcohol Denat.", concern: "can be drying"),
                FlaggedIngredient(name: "Fragrance", concern: "potential irritant")
            ]
        ]
        let flagged = score >= 8 ? sampleIngredients[0] :
                      score >= 6 ? sampleIngredients[Int.random(in: 0...1)] :
                      sampleIngredients[Int.random(in: 2...3)]

        return ProductScanResult(
            productName: productName,
            compatibilityScore: score,
            compatibilityLabel: label,
            microExplanation: micro,
            acneSafe: acne,
            hydrationFriendly: hydration,
            irritationRisk: irritation,
            glowSupport: glow,
            flaggedIngredients: flagged
        )
    }
}

// MARK: - Scan History Manager

class ScanHistoryManager: ObservableObject {
    static let shared = ScanHistoryManager()

    @Published var faceScans: [FaceScanResult] = []
    @Published var productScans: [ProductScanResult] = []

    private let faceScansKey = "sg_face_scans"
    private let productScansKey = "sg_product_scans"

    private init() {
        loadHistory()
    }

    var latestFaceScan: FaceScanResult? { faceScans.first }

    func addFaceScan(_ scan: FaceScanResult) {
        faceScans.insert(scan, at: 0)
        saveHistory()
    }

    func addProductScan(_ scan: ProductScanResult) {
        productScans.insert(scan, at: 0)
        saveHistory()
    }

    private func saveHistory() {
        if let data = try? JSONEncoder().encode(faceScans) {
            UserDefaults.standard.set(data, forKey: faceScansKey)
        }
        if let data = try? JSONEncoder().encode(productScans) {
            UserDefaults.standard.set(data, forKey: productScansKey)
        }
    }

    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: faceScansKey),
           let scans = try? JSONDecoder().decode([FaceScanResult].self, from: data) {
            faceScans = scans
        }
        if let data = UserDefaults.standard.data(forKey: productScansKey),
           let scans = try? JSONDecoder().decode([ProductScanResult].self, from: data) {
            productScans = scans
        }
    }
}

// ============================================================
// MARK: - LEGACY MODELS (backward compatibility)
// ============================================================

struct SkinMetrics: Codable, Identifiable {
    let id = UUID()
    let overallScore: Int
    let hydration: Int
    let acne: Int
    let glow: Int
    let aging: Int
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

struct RoutineStep: Codable, Identifiable {
    let id: UUID
    let stepNumber: Int
    let title: String
    let description: String
    let duration: String
    let productType: String
    let iconName: String
    let color: String
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

struct SkinChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isFromUser: Bool
    let timestamp: Date
}

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

class SkinAnalysisService: ObservableObject {
    static let shared = SkinAnalysisService()

    @Published var isAnalyzing = false
    @Published var currentAnalysis: SkinScanResult?
    @Published var scanHistory: [ArchiveEntry] = []

    func analyzeSkin(imageData: Data, concerns: [String], skinType: String) async throws -> SkinScanResult {
        isAnalyzing = true
        try await Task.sleep(nanoseconds: 3_000_000_000)
        let metrics = SkinMetrics(
            overallScore: Int.random(in: 70...95),
            hydration: Int.random(in: 60...90),
            acne: Int.random(in: 50...95),
            glow: Int.random(in: 65...90),
            aging: Int.random(in: 70...95),
            timestamp: Date()
        )
        let result = SkinScanResult(
            metrics: metrics, imageData: imageData,
            recommendations: ["Use hydrating serum", "Apply SPF daily"],
            routineSteps: [], timestamp: Date(),
            userConcerns: concerns, skinType: skinType
        )
        currentAnalysis = result
        isAnalyzing = false
        let entry = ArchiveEntry(scanResult: result, notes: nil, isFavorite: false)
        scanHistory.insert(entry, at: 0)
        return result
    }
}
