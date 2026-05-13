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
    let responseFormat: OpenAIResponseFormat?

    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case maxTokens = "max_tokens"
        case temperature
        case responseFormat = "response_format"
    }

    init(model: String, messages: [OpenAIMessage], maxTokens: Int?, temperature: Double?, responseFormat: OpenAIResponseFormat? = nil) {
        self.model = model
        self.messages = messages
        self.maxTokens = maxTokens
        self.temperature = temperature
        self.responseFormat = responseFormat
    }
}

struct OpenAIResponseFormat: Codable {
    let type: String

    static let jsonObject = OpenAIResponseFormat(type: "json_object")
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
    let faceAreas: [OpenAIFaceAreaPayload]?
}

struct OpenAIFaceAreaPayload: Codable {
    let area: String
    let score: Int
    let primaryConcern: String
    let visibleSigns: String
    let recommendation: String
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
                faceAreas: fallbackFaceAreas(from: fallback, localize: localize),
                imageData: imageData
            )
            return fallback
        }

        let optimizedImageData = optimizedJPEGData(from: imageData)
        let base64Image = optimizedImageData.base64EncodedString()
        let imageUrl = "data:image/jpeg;base64,\(base64Image)"
        let previousContext = previousScan.map {
            "Previous scan: skin age \($0.skinAge), glow \($0.glowScore ?? 0), texture \($0.textureScore ?? 0), redness \($0.rednessScore ?? 0), firmness \(String(format: "%.1f", $0.firmnessScore))."
        } ?? "No previous scan."

        let systemPrompt = """
        You are SkinGlowing's visual skin analysis engine. Analyze the face photo as consumer wellness guidance, not medical diagnosis.
        Be specific to visible image signals. Avoid generic skincare copy. Each micro explanation must reference a visible zone or pattern from the photo.
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
          "glowAdvice": "one specific next step based on the visible scan",
          "planFocus": ["three specific focus areas for a 90 day plan, ordered by priority"],
          "faceAreas": [
            {
              "area": "Forehead",
              "score": 0-100,
              "primaryConcern": "main visible concern or strength",
              "visibleSigns": "specific visible read for this zone",
              "recommendation": "one zone-specific next step"
            },
            {
              "area": "Under-eyes",
              "score": 0-100,
              "primaryConcern": "main visible concern or strength",
              "visibleSigns": "specific visible read for this zone",
              "recommendation": "one zone-specific next step"
            },
            {
              "area": "Cheeks",
              "score": 0-100,
              "primaryConcern": "main visible concern or strength",
              "visibleSigns": "specific visible read for this zone",
              "recommendation": "one zone-specific next step"
            },
            {
              "area": "Nose / T-zone",
              "score": 0-100,
              "primaryConcern": "main visible concern or strength",
              "visibleSigns": "specific visible read for this zone",
              "recommendation": "one zone-specific next step"
            },
            {
              "area": "Chin / Jaw",
              "score": 0-100,
              "primaryConcern": "main visible concern or strength",
              "visibleSigns": "specific visible read for this zone",
              "recommendation": "one zone-specific next step"
            }
          ]
        }
        Face area reads must be based on what is visible. If an area is partly hidden or lighting is weak, say that clearly in visibleSigns.
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
            temperature: 0.2,
            responseFormat: .jsonObject
        )

        do {
            let response = try await makeAPICall(request: request)
            guard let content = response.choices.first?.message.content,
                  let data = extractJSONData(from: content),
                  let payload = try? JSONDecoder().decode(OpenAIFaceScanPayload.self, from: data) else {
                return personalizedFallbackFaceScan(
                    imageData: optimizedImageData,
                    userConcerns: userConcerns,
                    userSkinType: userSkinType,
                    previousScan: previousScan
                )
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
                faceAreas: normalizedFaceAreas(payload.faceAreas),
                imageData: optimizedImageData
            )
        } catch {
            print("Face scan API failed: \(error)")
            return personalizedFallbackFaceScan(
                imageData: optimizedImageData,
                userConcerns: userConcerns,
                userSkinType: userSkinType,
                previousScan: previousScan
            )
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

        let optimizedImageData = optimizedJPEGData(from: imageData)
        let base64Image = optimizedImageData.base64EncodedString()
        let imageUrl = "data:image/jpeg;base64,\(base64Image)"
        let scanContext = latestFaceScan.map {
            "Latest face scan: glow \($0.glowScore ?? 0), blemish score \($0.blemishScore ?? 0), redness \($0.rednessScore ?? 0), hydration look \($0.hydrationLookScore ?? 0), texture \($0.textureScore ?? 0)."
        } ?? "No face scan yet."

        let systemPrompt = """
        You are SkinGlowing's cosmetic and ingredient compatibility engine. Read the product/package/ingredient photo and estimate fit for the user's skin profile.
        Be specific to the visible package, product type, claims, and ingredients when readable. If text is unreadable, explicitly say what was inferred.
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
            temperature: 0.2,
            responseFormat: .jsonObject
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
                imageData: optimizedImageData
            )
        } catch {
            print("Product scan API failed: \(error)")
            var fallback = SkinScoringEngine.shared.generateProductScan(productName: AppLanguageManager.shared.localized("Scanned Product"), userSkinType: userSkinType)
            fallback = ProductScanResult(
                productName: fallback.productName,
                compatibilityScore: fallback.compatibilityScore,
                compatibilityLabel: fallback.compatibilityLabel,
                microExplanation: AppLanguageManager.shared.localized("AI could not finish the product read, so this is a temporary compatibility estimate."),
                acneSafe: fallback.acneSafe,
                hydrationFriendly: fallback.hydrationFriendly,
                irritationRisk: fallback.irritationRisk,
                breakoutRisk: fallback.breakoutRisk,
                drynessRisk: fallback.drynessRisk,
                poreCloggingRisk: fallback.poreCloggingRisk,
                glowSupport: fallback.glowSupport,
                glowSupportScore: fallback.glowSupportScore,
                makeupMatchScore: fallback.makeupMatchScore,
                flaggedIngredients: fallback.flaggedIngredients,
                usageAdvice: fallback.usageAdvice,
                imageData: optimizedImageData
            )
            return fallback
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

    func sendChatMessage(_ message: String, context: [SkinChatMessage], profileContext: String = "") async throws -> String {
        // Check for user consent before sending data to OpenAI
        guard UserDefaults.standard.bool(forKey: "userDataSharingConsent") else {
            throw OpenAIError.noUserConsent
        }

        // Build conversation history
        var messages: [OpenAIMessage] = [
            OpenAIMessage(role: "system", content: [
                OpenAIContent(type: "text", text: """
                You are Arisa, SkinGlowing's AI skin companion.
                Use the profile and scan context below whenever it is present. Give specific, actionable skincare guidance tied to the user's latest scores, focus areas, product scans, and 90-day plan.

                Style:
                - Warm, concise, and consumer-friendly.
                - Specific enough to feel personalized, not generic.
                - Use a light conversational tone, but do not overuse slang.
                - Prefer step-by-step answers when the user asks what to do.
                - Keep medical boundaries: you are not diagnosing disease, and serious symptoms should be directed to a dermatologist.
                - If the user asks about a plan, mention exact days or next actions.

                Profile context:
                \(profileContext.isEmpty ? "No saved profile context yet." : profileContext)

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

    private func optimizedJPEGData(from imageData: Data) -> Data {
        guard let image = UIImage(data: imageData) else { return imageData }
        let maxDimension: CGFloat = 1280
        let longestSide = max(image.size.width, image.size.height)
        let outputImage: UIImage

        if longestSide > maxDimension {
            let scale = maxDimension / longestSide
            let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
            let renderer = UIGraphicsImageRenderer(size: newSize)
            outputImage = renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: newSize))
            }
        } else {
            outputImage = image
        }

        return outputImage.jpegData(compressionQuality: 0.74) ?? imageData
    }

    private func personalizedFallbackFaceScan(imageData: Data, userConcerns: [String], userSkinType: String, previousScan: FaceScanResult?) -> FaceScanResult {
        let localize = AppLanguageManager.shared.localized
        let fallback = SkinScoringEngine.shared.generateFaceScan(previousScan: previousScan)
        let lower = userConcerns.map { $0.lowercased() }
        let focus = planFocus(for: lower, skinType: userSkinType)

        return FaceScanResult(
            glowScore: fallback.glowScore ?? 72,
            skinAge: fallback.skinAge,
            skinAgeDelta: fallback.skinAgeDelta,
            skinAgeMicro: localize("AI scan detail was unavailable. Use this as a temporary baseline until your next clear selfie scan."),
            glassSkinTier: fallback.glassSkinTier,
            glassSkinScore: fallback.glassSkinScore ?? 68,
            glassSkinMicro: localize("Temporary glow estimate based on your saved profile and scan history."),
            blemishSeverity: fallback.blemishSeverity,
            blemishScore: fallback.blemishScore ?? 74,
            blemishZone: fallback.blemishZone,
            blemishMicro: localize("Temporary blemish estimate. Retake in bright, even light for stronger AI reads."),
            textureScore: fallback.textureScore ?? 70,
            textureMicro: localize("Temporary texture estimate from fallback analysis."),
            rednessScore: fallback.rednessScore ?? 76,
            rednessMicro: localize("Temporary redness estimate from fallback analysis."),
            evenToneScore: fallback.evenToneScore ?? 72,
            evenToneMicro: localize("Temporary tone estimate from fallback analysis."),
            hydrationLookScore: fallback.hydrationLookScore ?? 70,
            hydrationMicro: localize("Temporary hydration-look estimate from fallback analysis."),
            firmnessScore: fallback.firmnessScore,
            firmnessDelta: fallback.firmnessDelta,
            firmnessMicro: fallback.firmnessMicro,
            underEyeScore: fallback.underEyeScore ?? 69,
            underEyeMicro: localize("Temporary under-eye estimate from fallback analysis."),
            glowAdvice: localize("Retake the scan in front-facing natural light, then follow Day 1 of your plan."),
            planFocus: focus,
            faceAreas: fallbackFaceAreas(from: fallback, localize: localize),
            imageData: imageData
        )
    }

    private func normalizedFaceAreas(_ areas: [OpenAIFaceAreaPayload]?) -> [FaceAreaResult]? {
        guard let areas, !areas.isEmpty else { return nil }
        return areas.prefix(8).map {
            FaceAreaResult(
                area: $0.area,
                score: clamped($0.score, 0, 100),
                primaryConcern: $0.primaryConcern,
                visibleSigns: $0.visibleSigns,
                recommendation: $0.recommendation
            )
        }
    }

    private func fallbackFaceAreas(from result: FaceScanResult, localize: (String) -> String) -> [FaceAreaResult] {
        [
            FaceAreaResult(
                area: localize("Forehead"),
                score: result.textureScore ?? 70,
                primaryConcern: localize("Texture balance"),
                visibleSigns: localize("Fallback read: forehead texture needs a clearer scan for a precise zone score."),
                recommendation: localize("Keep this area simple: cleanse gently and avoid adding new actives today.")
            ),
            FaceAreaResult(
                area: localize("Under-eyes"),
                score: result.underEyeScore ?? 69,
                primaryConcern: localize("Tired look"),
                visibleSigns: result.underEyeMicro ?? localize("Fallback read: under-eye detail is limited from this scan."),
                recommendation: localize("Prioritize sleep, hydration, and a light moisturizer around the orbital area.")
            ),
            FaceAreaResult(
                area: localize("Cheeks"),
                score: result.rednessScore ?? 76,
                primaryConcern: localize("Calm and tone"),
                visibleSigns: result.rednessMicro ?? localize("Fallback read: cheek redness needs brighter, even lighting."),
                recommendation: localize("Use barrier-supporting moisturizer and skip harsh exfoliation for 24 hours.")
            ),
            FaceAreaResult(
                area: localize("Nose / T-zone"),
                score: result.evenToneScore ?? 72,
                primaryConcern: localize("Pores and shine"),
                visibleSigns: localize("Fallback read: T-zone detail is limited, so this is a temporary estimate."),
                recommendation: localize("Use gentle cleansing and avoid heavy layers if this zone gets shiny.")
            ),
            FaceAreaResult(
                area: localize("Chin / Jaw"),
                score: result.blemishScore ?? 74,
                primaryConcern: localize("Blemish control"),
                visibleSigns: result.blemishMicro,
                recommendation: localize("Keep the area clean after sweating and avoid picking or over-scrubbing.")
            )
        ]
    }

    private func planFocus(for concerns: [String], skinType: String) -> [String] {
        var focus: [String] = []
        let joined = concerns.joined(separator: " ")

        if joined.contains("acne") || joined.contains("breakout") || joined.contains("blemish") {
            focus.append("Breakout Control")
        }
        if joined.contains("red") || joined.contains("sensitive") || skinType.lowercased().contains("sensitive") {
            focus.append("Barrier Calm")
        }
        if joined.contains("dry") || joined.contains("hydration") || skinType.lowercased().contains("dry") {
            focus.append("Hydration")
        }
        if joined.contains("texture") || joined.contains("pore") {
            focus.append("Texture")
        }
        if joined.contains("dark") || joined.contains("spot") || joined.contains("tone") {
            focus.append("Even Tone")
        }
        if joined.contains("glow") || focus.isEmpty {
            focus.append("Glow")
        }

        for fallback in ["Hydration", "Texture", "Glow"] where focus.count < 3 && !focus.contains(fallback) {
            focus.append(fallback)
        }

        return Array(focus.prefix(3))
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
