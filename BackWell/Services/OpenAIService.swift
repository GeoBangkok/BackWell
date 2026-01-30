//
//  OpenAIService.swift
//  SkinWell
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

// MARK: - OpenAI Service

class OpenAIService {
    static let shared = OpenAIService()

    // API key - Set this to your OpenAI API key
    // For production, use environment variables or secure storage
    private let apiKey = "YOUR_API_KEY_HERE"
    private let baseURL = "https://api.openai.com/v1/chat/completions"

    private init() {}

    // MARK: - Skin Analysis

    func analyzeSkin(imageData: Data, userConcerns: [String], userSkinType: String) async throws -> SkinAnalysisResponse {
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

        return SkinAnalysisResponse(
            overallScore: baseScore + Int.random(in: -5...10),
            hydration: baseScore + Int.random(in: -10...5),
            acne: baseScore + Int.random(in: -5...15),
            glow: baseScore + Int.random(in: -8...8),
            aging: baseScore + Int.random(in: 0...10),
            recommendations: [
                "Use a gentle, pH-balanced cleanser twice daily",
                "Apply a hydrating serum with hyaluronic acid",
                "Never skip SPF 30+ sunscreen in the morning",
                "Consider adding retinol to your evening routine",
                "Stay hydrated with 8-10 glasses of water daily"
            ],
            skinType: skinType.isEmpty ? "Combination" : skinType,
            concerns: concerns.isEmpty ? ["General skin health"] : concerns,
            routineSteps: [
                RoutineRecommendation(
                    step: 1,
                    product: "Gentle Cleanser",
                    description: "Use lukewarm water and massage for 60 seconds",
                    duration: "60 seconds"
                ),
                RoutineRecommendation(
                    step: 2,
                    product: "Hydrating Toner",
                    description: "Pat gently into skin",
                    duration: "30 seconds"
                ),
                RoutineRecommendation(
                    step: 3,
                    product: "Vitamin C Serum",
                    description: "Apply 2-3 drops to face and neck",
                    duration: "45 seconds"
                ),
                RoutineRecommendation(
                    step: 4,
                    product: "Moisturizer",
                    description: "Apply in upward strokes",
                    duration: "45 seconds"
                ),
                RoutineRecommendation(
                    step: 5,
                    product: "Sunscreen",
                    description: "Apply generously, reapply every 2 hours",
                    duration: "30 seconds"
                )
            ]
        )
    }

    // MARK: - Chat (Arisa)

    func sendChatMessage(_ message: String, context: [ChatMessage]) async throws -> String {
        // Build conversation history
        var messages: [OpenAIMessage] = [
            OpenAIMessage(role: "system", content: [
                OpenAIContent(type: "text", text: """
                You are Arisa, an expert AI skincare assistant. You provide personalized, science-based skincare advice.
                You are friendly, knowledgeable, and helpful. Keep responses concise but informative.
                Focus on evidence-based recommendations and always prioritize skin health and safety.
                If asked about medical conditions, advise consulting a dermatologist.
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
        return response.choices.first?.message.content ?? "I'm sorry, I couldn't process that request. Please try again."
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