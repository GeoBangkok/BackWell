//
//  OpenAIService.swift
//  SkinGlowing
//
//  OpenAI API integration for skin analysis and chat
//

import Foundation
import SwiftUI

// MARK: - API Models

struct OpenAIRequest: Codable {
    let model: String
    let messages: [OpenAIMessage]
    let maxTokens: Int?
    let temperature: Double?

    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case maxTokens = "max_tokens"
        case temperature
    }
}

struct OpenAIMessage: Codable {
    let role: String
    let content: [OpenAIContent]
}

struct OpenAIContent: Codable {
    let type: String
    let text: String?
    let imageUrl: OpenAIImageUrl?

    enum CodingKeys: String, CodingKey {
        case type
        case text
        case imageUrl = "image_url"
    }
}

struct OpenAIImageUrl: Codable {
    let url: String
    let detail: String?
}

struct OpenAIResponse: Codable {
    let choices: [OpenAIChoice]
}

struct OpenAIChoice: Codable {
    let message: OpenAIResponseMessage
}

struct OpenAIResponseMessage: Codable {
    let content: String
}

// MARK: - Skin Analysis Response Model

struct SkinAnalysisResponse: Codable {
    let overallScore: Int
    let hydration: Int
    let acne: Int
    let glow: Int
    let aging: Int
    let recommendations: [String]
    let skinType: String
    let concerns: [String]
    let routineSteps: [RoutineRecommendation]
}

struct RoutineRecommendation: Codable {
    let step: Int
    let product: String
    let description: String
    let duration: String
}

struct OpenAIFaceScanPayload: Codable {
    let glowScore: Int
    let skinAge: Int
    let skinAgeMicro: String
    let glassSkinScore: Int
    let glassSkinTier: String
    let glassSkinMicro: String
    let blemishSeverity: String
    let blemishScore: Int
    let blemishZone: String
    let blemishMicro: String
    let textureScore: Int
    let textureMicro: String
    let rednessScore: Int
    let rednessMicro: String
    let evenToneScore: Int
    let evenToneMicro: String
    let hydrationLookScore: Int
    let hydrationMicro: String
    let firmnessScore: Double
    let firmnessMicro: String
    let underEyeScore: Int
    let underEyeMicro: String
    let glowAdvice: String
    let planFocus: [String]
}

struct OpenAIProductScanPayload: Codable {
    let productName: String
    let productFitScore: Int
    let compatibilityLabel: String
    let microExplanation: String
    let acneSafe: String
    let hydrationFriendly: String
    let irritationRisk: String
    let breakoutRisk: Int
    let drynessRisk: Int
    let poreCloggingRisk: Int
    let glowSupport: String
    let glowSupportScore: Int
    let makeupMatchScore: Int
    let flaggedIngredients: [OpenAIFlaggedIngredient]
    let usageAdvice: String
}

struct OpenAIFlaggedIngredient: Codable {
    let name: String
    let concern: String
}

// MARK: - OpenAI Service

class OpenAIService {
    static let shared = OpenAIService()

    // API key - Set this to your OpenAI API key
    // For production, use environment variables or secure storage
    // IMPORTANT: Replace with your actual API key locally
    private let apiKey = "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"
    private let baseURL = "https://api.openai.com/v1/chat/completions"

    private init() {}

    // MARK: - Skin Analysis

    func analyzeFaceScan(imageData: Data, userConcerns: [String], userSkinType: String, previousScan: FaceScanResult?) async throws -> FaceScanResult {
        guard UserDefaults.standard.bool(forKey: "userDataSharingConsent") else {
            throw OpenAIError.noUserConsent
        }

        guard NetworkManager.shared.isConnected else {
            let localize = AppLanguageManager.shared.localized
            var fallback = SkinScoringEngine.shared.generateFaceScan(previousScan: previousScan)
            fallback = FaceScanResult(
                glowScore: fallback.glowScore ?? 72,
                skinAge: fallback.skinAge,
                skinAgeDelta: fallback.skinAgeDelta,
                skinAgeMicro: fallback.skinAgeMicro,
                glassSkinTier: fallback.glassSkinTier,
                glassSkinScore: fallback.glassSkinScore ?? 68,
                glassSkinMicro: fallback.glassSkinMicro,
                blemishSeverity: fallback.blemishSeverity,
                blemishScore: fallback.blemishScore ?? 74,
                blemishZone: fallback.blemishZone,
                blemishMicro: fallback.blemishMicro,
                textureScore: fallback.textureScore ?? 71,
                textureMicro: fallback.textureMicro ?? localize("Visible texture looks moderate today."),
                rednessScore: fallback.rednessScore ?? 78,
                rednessMicro: fallback.rednessMicro ?? localize("Visible redness appears mild."),
                evenToneScore: fallback.evenToneScore ?? 73,
                evenToneMicro: fallback.evenToneMicro ?? localize("Tone looks slightly uneven around cheeks."),
                hydrationLookScore: fallback.hydrationLookScore ?? 70,
                hydrationMicro: fallback.hydrationMicro ?? localize("Hydration look could be stronger."),
                firmnessScore: fallback.firmnessScore,
                firmnessDelta: fallback.firmnessDelta,
                firmnessMicro: fallback.firmnessMicro,
                underEyeScore: fallback.underEyeScore ?? 69,
                underEyeMicro: fallback.underEyeMicro ?? localize("Under-eye area looks a little tired."),
                glowAdvice: fallback.glowAdvice,
                planFocus: fallback.planFocus ?? [localize("Hydration"), localize("Texture"), localize("Glow")],
                imageData: imageData
            )
            return fallback
        }

        let base64Image = imageData.base64EncodedString()
        let imageUrl = "data:image/jpeg;base64,\(base64Image)"
        let previousContext = previousScan.map {
            "Previous scan: skin age \($0.skinAge), glow \($0.glowScore ?? 0), texture \($0.textureScore ?? 0), redness \($0.rednessScore ?? 0), firmness \(String(format: "%.1f", $0.firmnessScore))."
        } ?? "No previous scan."

        let systemPrompt = """
        You are SkinGlowing's visual skin analysis engine. Analyze the face photo as consumer wellness guidance, not medical diagnosis.
        Return ONLY valid JSON with this exact structure:
        {
          "glowScore": 0-100,
          "skinAge": integer perceived skin age,
          "skinAgeMicro": "short visual explanation",
          "glassSkinScore": 0-100,
          "glassSkinTier": "Dull|Balanced|Glowy|Glass-tier",
          "glassSkinMicro": "short visual explanation",
          "blemishSeverity": "Minor|Moderate|Active",
          "blemishScore": 0-100 where higher means clearer,
          "blemishZone": "main visible zone",
          "blemishMicro": "short visual explanation",
          "textureScore": 0-100,
          "textureMicro": "short visual explanation",
          "rednessScore": 0-100 where higher means calmer-looking,
          "rednessMicro": "short visual explanation",
          "evenToneScore": 0-100,
          "evenToneMicro": "short visual explanation",
          "hydrationLookScore": 0-100,
          "hydrationMicro": "short visual explanation",
          "firmnessScore": 0-10,
          "firmnessMicro": "short visual explanation",
          "underEyeScore": 0-100,
          "underEyeMicro": "short visual explanation",
          "glowAdvice": "one short next step",
          "planFocus": ["three focus areas for a 90 day plan"]
        }
        Use consumer-safe language like visible, perceived, looks, may. Do not diagnose disease.
        User skin type: \(userSkinType.isEmpty ? "Not sure" : userSkinType).
        User goals/concerns: \(userConcerns.joined(separator: ", ")).
        \(previousContext)
        \(AppLanguageManager.shared.selectedLanguage.jsonResponseInstruction)
        """

        let request = OpenAIRequest(
            model: "gpt-5-nano",
            messages: [
                OpenAIMessage(role: "system", content: [
                    OpenAIContent(type: "text", text: systemPrompt, imageUrl: nil)
                ]),
                OpenAIMessage(role: "user", content: [
                    OpenAIContent(type: "text", text: "Analyze this face photo for SkinGlowing metrics.", imageUrl: nil),
                    OpenAIContent(type: "image_url", text: nil, imageUrl: OpenAIImageUrl(url: imageUrl, detail: "high"))
                ])
            ],
            maxTokens: 1200,
            temperature: 0.2
        )

        do {
            let response = try await makeAPICall(request: request)
            guard let content = response.choices.first?.message.content,
                  let data = extractJSONData(from: content),
                  let payload = try? JSONDecoder().decode(OpenAIFaceScanPayload.self, from: data) else {
                return SkinScoringEngine.shared.generateFaceScan(previousScan: previousScan)
            }

            let tier = glassTier(from: payload.glassSkinTier, score: payload.glassSkinScore)
            let severity = blemishSeverity(from: payload.blemishSeverity)
            let skinAgeDelta = previousScan.map { payload.skinAge - $0.skinAge }
            let firmnessDelta = previousScan.map { Double(round((payload.firmnessScore - $0.firmnessScore) * 10) / 10) }

            return FaceScanResult(
                glowScore: clamped(payload.glowScore, 0, 100),
                skinAge: max(16, payload.skinAge),
                skinAgeDelta: skinAgeDelta,
                skinAgeMicro: payload.skinAgeMicro,
                glassSkinTier: tier,
                glassSkinScore: clamped(payload.glassSkinScore, 0, 100),
                glassSkinMicro: payload.glassSkinMicro,
                blemishSeverity: severity,
                blemishScore: clamped(payload.blemishScore, 0, 100),
                blemishZone: payload.blemishZone,
                blemishMicro: payload.blemishMicro,
                textureScore: clamped(payload.textureScore, 0, 100),
                textureMicro: payload.textureMicro,
                rednessScore: clamped(payload.rednessScore, 0, 100),
                rednessMicro: payload.rednessMicro,
                evenToneScore: clamped(payload.evenToneScore, 0, 100),
                evenToneMicro: payload.evenToneMicro,
                hydrationLookScore: clamped(payload.hydrationLookScore, 0, 100),
                hydrationMicro: payload.hydrationMicro,
                firmnessScore: min(10, max(0, payload.firmnessScore)),
                firmnessDelta: firmnessDelta,
                firmnessMicro: payload.firmnessMicro,
                underEyeScore: clamped(payload.underEyeScore, 0, 100),
                underEyeMicro: payload.underEyeMicro,
                glowAdvice: payload.glowAdvice,
                planFocus: payload.planFocus,
                imageData: imageData
            )
        } catch {
            print("Face scan API failed: \(error)")
            return SkinScoringEngine.shared.generateFaceScan(previousScan: previousScan)
        }
    }

    func analyzeProductScan(imageData: Data, userSkinType: String, latestFaceScan: FaceScanResult?) async throws -> ProductScanResult {
        guard UserDefaults.standard.bool(forKey: "userDataSharingConsent") else {
            throw OpenAIError.noUserConsent
        }

        guard NetworkManager.shared.isConnected else {
            let localize = AppLanguageManager.shared.localized
            return SkinScoringEngine.shared.generateProductScan(
                productName: localize("Scanned Product"),
                userSkinType: userSkinType.isEmpty ? "Normal" : userSkinType
            )
        }

        let base64Image = imageData.base64EncodedString()
        let imageUrl = "data:image/jpeg;base64,\(base64Image)"
        let scanContext = latestFaceScan.map {
            "Latest face scan: glow \($0.glowScore ?? 0), blemish score \($0.blemishScore ?? 0), redness \($0.rednessScore ?? 0), hydration look \($0.hydrationLookScore ?? 0), texture \($0.textureScore ?? 0)."
        } ?? "No face scan yet."

        let systemPrompt = """
        You are SkinGlowing's cosmetic and ingredient compatibility engine. Read the product/package/ingredient photo and estimate fit for the user's skin profile.
        Return ONLY valid JSON:
        {
          "productName": "best detected product name or Scanned Product",
          "productFitScore": 0-100,
          "compatibilityLabel": "Excellent fit|Good fit|Fair fit|Poor fit",
          "microExplanation": "one short reason",
          "acneSafe": "Green|Yellow|Red",
          "hydrationFriendly": "Green|Yellow|Red",
          "irritationRisk": "Green|Yellow|Red",
          "breakoutRisk": 0-100 where higher means more risk,
          "drynessRisk": 0-100,
          "poreCloggingRisk": 0-100,
          "glowSupport": "Green|Yellow|Red",
          "glowSupportScore": 0-100,
          "makeupMatchScore": 0-100,
          "flaggedIngredients": [{"name":"ingredient", "concern":"short concern"}],
          "usageAdvice": "one short consumer-safe usage note"
        }
        Use risk language, not certainty. If label text is unreadable, infer from visible packaging and say so in microExplanation.
        User skin type: \(userSkinType.isEmpty ? "Not sure" : userSkinType).
        \(scanContext)
        \(AppLanguageManager.shared.selectedLanguage.jsonResponseInstruction)
        """

        let request = OpenAIRequest(
            model: "gpt-5-nano",
            messages: [
                OpenAIMessage(role: "system", content: [
                    OpenAIContent(type: "text", text: systemPrompt, imageUrl: nil)
                ]),
                OpenAIMessage(role: "user", content: [
                    OpenAIContent(type: "text", text: "Analyze this cosmetic/product photo for skin compatibility.", imageUrl: nil),
                    OpenAIContent(type: "image_url", text: nil, imageUrl: OpenAIImageUrl(url: imageUrl, detail: "high"))
                ])
            ],
            maxTokens: 1100,
            temperature: 0.2
        )

        do {
            let response = try await makeAPICall(request: request)
            guard let content = response.choices.first?.message.content,
                  let data = extractJSONData(from: content),
                  let payload = try? JSONDecoder().decode(OpenAIProductScanPayload.self, from: data) else {
                return SkinScoringEngine.shared.generateProductScan(productName: AppLanguageManager.shared.localized("Scanned Product"), userSkinType: userSkinType)
            }

            return ProductScanResult(
                productName: payload.productName.isEmpty ? AppLanguageManager.shared.localized("Scanned Product") : payload.productName,
                compatibilityScore: max(0, min(10, Int(round(Double(payload.productFitScore) / 10.0)))),
                compatibilityLabel: payload.compatibilityLabel,
                microExplanation: payload.microExplanation,
                acneSafe: trafficLight(from: payload.acneSafe),
                hydrationFriendly: trafficLight(from: payload.hydrationFriendly),
                irritationRisk: trafficLight(from: payload.irritationRisk),
                breakoutRisk: clamped(payload.breakoutRisk, 0, 100),
                drynessRisk: clamped(payload.drynessRisk, 0, 100),
                poreCloggingRisk: clamped(payload.poreCloggingRisk, 0, 100),
                glowSupport: trafficLight(from: payload.glowSupport),
                glowSupportScore: clamped(payload.glowSupportScore, 0, 100),
                makeupMatchScore: clamped(payload.makeupMatchScore, 0, 100),
                flaggedIngredients: payload.flaggedIngredients.map { FlaggedIngredient(name: $0.name, concern: $0.concern) },
                usageAdvice: payload.usageAdvice,
                imageData: imageData
            )
        } catch {
            print("Product scan API failed: \(error)")
            return SkinScoringEngine.shared.generateProductScan(productName: AppLanguageManager.shared.localized("Scanned Product"), userSkinType: userSkinType)
        }
    }

    func analyzeSkin(imageData: Data, userConcerns: [String], userSkinType: String) async throws -> SkinAnalysisResponse {
        // Check for user consent before sending data to OpenAI
        guard UserDefaults.standard.bool(forKey: "userDataSharingConsent") else {
            throw OpenAIError.noUserConsent
        }

        // Check if we should use fallback (for testing or when API is unavailable)
        if !NetworkManager.shared.isConnected {
            return generateFallbackAnalysis(concerns: userConcerns, skinType: userSkinType)
        }

        // Convert image to base64
        let base64Image = imageData.base64EncodedString()
        let imageUrl = "data:image/jpeg;base64,\(base64Image)"

        // Create the analysis prompt
        let systemPrompt = """
        You are an expert dermatologist AI assistant analyzing skin conditions from photos.
        Analyze the provided facial image and return a JSON response with the following structure:
        {
            "overallScore": (0-100 integer),
            "hydration": (0-100 integer),
            "acne": (0-100 integer, higher means less acne/clearer skin),
            "glow": (0-100 integer),
            "aging": (0-100 integer, higher means younger-looking skin),
            "recommendations": [array of 3-5 specific skincare recommendations],
            "skinType": "detected skin type",
            "concerns": [array of detected skin concerns],
            "routineSteps": [
                {
                    "step": 1,
                    "product": "product type",
                    "description": "specific recommendation",
                    "duration": "time duration"
                }
            ]
        }

        Be specific and helpful in your recommendations. Consider the user's stated concerns: \(userConcerns.joined(separator: ", "))
        \(AppLanguageManager.shared.selectedLanguage.jsonResponseInstruction)
        """

        let userPrompt = "Please analyze this facial photo and provide a comprehensive skin analysis with scores and recommendations."

        let messages = [
            OpenAIMessage(role: "system", content: [
                OpenAIContent(type: "text", text: systemPrompt, imageUrl: nil)
            ]),
            OpenAIMessage(role: "user", content: [
                OpenAIContent(type: "text", text: userPrompt, imageUrl: nil),
                OpenAIContent(type: "image_url", text: nil, imageUrl: OpenAIImageUrl(url: imageUrl, detail: "high"))
            ])
        ]

        let request = OpenAIRequest(
            model: "gpt-5-nano",
            messages: messages,
            maxTokens: 1000,
            temperature: 0.7
        )

        do {
            // Make API call
            let response = try await makeAPICall(request: request)

            // Parse the JSON response
            guard let jsonData = response.choices.first?.message.content.data(using: .utf8),
                  let analysisResponse = try? JSONDecoder().decode(SkinAnalysisResponse.self, from: jsonData) else {
                // If parsing fails, return a fallback response
                print("Failed to parse API response, using fallback")
                return generateFallbackAnalysis(concerns: userConcerns, skinType: userSkinType)
            }

            return analysisResponse
        } catch {
            print("API call failed: \(error), using fallback")
            return generateFallbackAnalysis(concerns: userConcerns, skinType: userSkinType)
        }
    }

    // Fallback analysis for when API is unavailable
    private func generateFallbackAnalysis(concerns: [String], skinType: String) -> SkinAnalysisResponse {
        // Generate realistic but randomized scores
        let baseScore = Int.random(in: 70...85)
        let localize = AppLanguageManager.shared.localized

        return SkinAnalysisResponse(
            overallScore: baseScore + Int.random(in: -5...10),
            hydration: baseScore + Int.random(in: -10...5),
            acne: baseScore + Int.random(in: -5...15),
            glow: baseScore + Int.random(in: -8...8),
            aging: baseScore + Int.random(in: 0...10),
            recommendations: [
                localize("Use a gentle, pH-balanced cleanser twice daily"),
                localize("Apply a hydrating serum with hyaluronic acid"),
                localize("Never skip SPF 30+ sunscreen in the morning"),
                localize("Consider adding retinol to your evening routine"),
                localize("Stay hydrated with 8-10 glasses of water daily")
            ],
            skinType: skinType.isEmpty ? localize("Combination") : skinType,
            concerns: concerns.isEmpty ? [localize("General skin health")] : concerns,
            routineSteps: [
                RoutineRecommendation(
                    step: 1,
                    product: localize("Gentle Cleanser"),
                    description: localize("Use lukewarm water and massage for 60 seconds"),
                    duration: localize("60 seconds")
                ),
                RoutineRecommendation(
                    step: 2,
                    product: localize("Hydrating Toner"),
                    description: localize("Pat gently into skin"),
                    duration: localize("30 seconds")
                ),
                RoutineRecommendation(
                    step: 3,
                    product: localize("Vitamin C Serum"),
                    description: localize("Apply 2-3 drops to face and neck"),
                    duration: localize("45 seconds")
                ),
                RoutineRecommendation(
                    step: 4,
                    product: localize("Moisturizer"),
                    description: localize("Apply in upward strokes"),
                    duration: localize("45 seconds")
                ),
                RoutineRecommendation(
                    step: 5,
                    product: localize("Sunscreen"),
                    description: localize("Apply generously, reapply every 2 hours"),
                    duration: localize("30 seconds")
                )
            ]
        )
    }

    // MARK: - Chat (Arisa)

    func sendChatMessage(_ message: String, context: [SkinChatMessage]) async throws -> String {
        // Check for user consent before sending data to OpenAI
        guard UserDefaults.standard.bool(forKey: "userDataSharingConsent") else {
            throw OpenAIError.noUserConsent
        }

        // Build conversation history
        var messages: [OpenAIMessage] = [
            OpenAIMessage(role: "system", content: [
                OpenAIContent(type: "text", text: """
                You are Arisa, a zoomer skincare bestie who's obsessed with glass skin and K-beauty.

                Your personality:
                - Super casual, uses gen-z slang naturally (bestie, slay, no cap, fr, lowkey, highkey, it's giving, tea)
                - Excited about skincare but not preachy
                - Short responses (2-3 sentences max usually)
                - Uses emojis occasionally but not overdoing it (mostly ✨💕🥺😭)
                - References TikTok skincare trends
                - Says things like "okayy but like" "not me doing..." "the way I..."
                - Supportive friend energy, hypes people up

                Keep responses SHORT and conversational. Like texting a friend, not writing an essay.
                If it's medical/serious, still say "bestie maybe see a derm for that one 🥺"
                \(AppLanguageManager.shared.selectedLanguage.chatResponseInstruction)
                """, imageUrl: nil)
            ])
        ]

        // Add conversation history (last 10 messages for context)
        let recentContext = context.suffix(10)
        for msg in recentContext {
            let role = msg.isFromUser ? "user" : "assistant"
            messages.append(OpenAIMessage(role: role, content: [
                OpenAIContent(type: "text", text: msg.content, imageUrl: nil)
            ]))
        }

        // Add current message
        messages.append(OpenAIMessage(role: "user", content: [
            OpenAIContent(type: "text", text: message, imageUrl: nil)
        ]))

        let request = OpenAIRequest(
            model: "gpt-5-nano",
            messages: messages,
            maxTokens: 500,
            temperature: 0.8
        )

        let response = try await makeAPICall(request: request)
        return response.choices.first?.message.content ?? AppLanguageManager.shared.localized("I'm sorry, I couldn't process that request. Please try again.")
    }

    // MARK: - Response Helpers

    private func extractJSONData(from content: String) -> Data? {
        var trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.hasPrefix("```") {
            trimmed = trimmed
                .replacingOccurrences(of: "```json", with: "")
                .replacingOccurrences(of: "```JSON", with: "")
                .replacingOccurrences(of: "```", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }

        if let start = trimmed.firstIndex(of: "{"),
           let end = trimmed.lastIndex(of: "}"),
           start <= end {
            trimmed = String(trimmed[start...end])
        }

        return trimmed.data(using: .utf8)
    }

    private func glassTier(from value: String, score: Int) -> GlassSkinTier {
        let normalized = value.lowercased()
        if normalized.contains("glass") { return .glassTier }
        if normalized.contains("glow") { return .glowy }
        if normalized.contains("balanced") { return .balanced }
        if normalized.contains("dull") { return .dull }

        switch score {
        case 85...100: return .glassTier
        case 70..<85: return .glowy
        case 50..<70: return .balanced
        default: return .dull
        }
    }

    private func blemishSeverity(from value: String) -> BlemishSeverity {
        let normalized = value.lowercased()
        if normalized.contains("active") { return .active }
        if normalized.contains("moderate") { return .moderate }
        return .minor
    }

    private func trafficLight(from value: String) -> TrafficLight {
        let normalized = value.lowercased()
        if normalized.contains("red") || normalized.contains("poor") || normalized.contains("high") {
            return .red
        }
        if normalized.contains("yellow") || normalized.contains("fair") || normalized.contains("medium") {
            return .yellow
        }
        return .green
    }

    private func clamped(_ value: Int, _ minValue: Int, _ maxValue: Int) -> Int {
        min(maxValue, max(minValue, value))
    }

    // MARK: - Private API Call Method

    private func makeAPICall(request: OpenAIRequest) async throws -> OpenAIResponse {
        // Check network connectivity
        guard NetworkManager.shared.isConnected else {
            throw APIError.noConnection
        }

        guard let url = URL(string: baseURL) else {
            throw APIError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = 30.0  // 30 second timeout

        let encoder = JSONEncoder()
        urlRequest.httpBody = try encoder.encode(request)

        // Use retry logic for network calls
        return try await RetryManager.retry {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            // Log response for debugging
            print("API Response Status: \(httpResponse.statusCode)")

            guard httpResponse.statusCode == 200 else {
                // Try to parse error message from response
                if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let error = errorData["error"] as? [String: Any],
                   let message = error["message"] as? String {
                    print("API Error: \(message)")
                }
                throw APIError.httpError(statusCode: httpResponse.statusCode)
            }

            let decoder = JSONDecoder()
            let openAIResponse = try decoder.decode(OpenAIResponse.self, from: data)

            return openAIResponse
        }
    }
}

// MARK: - API Errors

enum OpenAIError: LocalizedError {
    case noUserConsent

    var errorDescription: String? {
        switch self {
        case .noUserConsent:
            return "User consent is required to use AI features. Please review and accept the privacy disclosure in Settings."
        }
    }
}

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case parsingError
    case noData
    case noConnection

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .parsingError:
            return "Failed to parse response"
        case .noData:
            return "No data received"
        case .noConnection:
            return "No internet connection"
        }
    }
}

// MARK: - Updated SkinAnalysisService

extension SkinAnalysisService {
    func analyzeSkinWithAPI(imageData: Data, concerns: [String], skinType: String) async throws -> SkinScanResult {
        do {
            // Call OpenAI API
            let apiResponse = try await OpenAIService.shared.analyzeSkin(
                imageData: imageData,
                userConcerns: concerns,
                userSkinType: skinType
            )

            // Convert API response to our models
            let metrics = SkinMetrics(
                overallScore: apiResponse.overallScore,
                hydration: apiResponse.hydration,
                acne: apiResponse.acne,
                glow: apiResponse.glow,
                aging: apiResponse.aging,
                timestamp: Date()
            )

            // Convert routine recommendations to RoutineStep
            let routineSteps = apiResponse.routineSteps.map { rec in
                RoutineStep(
                    id: UUID(),
                    stepNumber: rec.step,
                    title: rec.product,
                    description: rec.description,
                    duration: rec.duration,
                    productType: rec.product,
                    iconName: getIconForProduct(rec.product),
                    color: getColorForStep(rec.step),
                    tips: []
                )
            }

            let result = SkinScanResult(
                metrics: metrics,
                imageData: imageData,
                recommendations: apiResponse.recommendations,
                routineSteps: routineSteps,
                timestamp: Date(),
                userConcerns: apiResponse.concerns,
                skinType: apiResponse.skinType
            )

            // Update state
            await MainActor.run {
                self.currentAnalysis = result
                self.isAnalyzing = false

                // Save to history
                let archiveEntry = ArchiveEntry(scanResult: result, notes: nil, isFavorite: false)
                self.scanHistory.insert(archiveEntry, at: 0)
            }

            return result

        } catch {
            await MainActor.run {
                self.isAnalyzing = false
            }
            throw error
        }
    }

    private func getIconForProduct(_ product: String) -> String {
        let productLower = product.lowercased()
        if productLower.contains("cleanser") { return "drop.fill" }
        if productLower.contains("toner") { return "sparkles" }
        if productLower.contains("serum") { return "star.fill" }
        if productLower.contains("moisturizer") { return "cloud.fill" }
        if productLower.contains("sunscreen") || productLower.contains("spf") { return "sun.max.fill" }
        if productLower.contains("eye") { return "eye" }
        return "circle.fill"
    }

    private func getColorForStep(_ step: Int) -> String {
        let colors = ["#FF6B6B", "#4ECDC4", "#FFD93D", "#A8E6CF", "#FFB6C1", "#FFEAA7", "#DDA0DD", "#98D8C8"]
        return colors[(step - 1) % colors.count]
    }
}
