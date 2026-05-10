//
//  ArisaAIView.swift
//  SkinGlowing
//
//  AI Beauty Assistant with iMessage-like interface
//

import SwiftUI

struct ArisaAIView: View {
    let profileContext: String

    @State private var messageText = ""
    @State private var messages: [ArisaChatMessage] = [
        ArisaChatMessage(
            id: UUID(),
            text: AppLanguageManager.shared.localized("Arisa welcome message"),
            isUser: false,
            timestamp: Date()
        )
    ]
    @State private var isTyping = false
    @State private var isSending = false
    @FocusState private var isInputFocused: Bool

    init(profileContext: String = "") {
        self.profileContext = profileContext
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.blushBackground
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    VStack(spacing: 8) {
                        SGBrandMark(size: 18)
                        Text("Ask SkinGlowing anything.")
                            .font(.system(size: 32, weight: .regular, design: .serif))
                            .foregroundColor(Theme.headline)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 12)
                    .padding(.horizontal, 20)

                    // Chat messages
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(messages) { message in
                                    ArisaMessageBubble(message: message)
                                        .id(message.id)
                                }

                                if isTyping {
                                    ArisaTypingIndicator()
                                        .id("typing")
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 20)
                        }
                        .onChange(of: messages.count) { _ in
                            withAnimation {
                                proxy.scrollTo(messages.last?.id, anchor: .bottom)
                            }
                        }
                        .onChange(of: isTyping) { typing in
                            if typing {
                                withAnimation {
                                    proxy.scrollTo("typing", anchor: .bottom)
                                }
                            }
                        }
                    }

                    // Input area
                    HStack(spacing: 12) {
                        TextField("Ask me anything about skincare...", text: $messageText, axis: .vertical)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.78))
                            .clipShape(Capsule())
                            .lineLimit(1...4)
                            .focused($isInputFocused)
                            .onSubmit {
                                sendMessage()
                            }

                        Button(action: sendMessage) {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(messageText.isEmpty ? Theme.captionText : Theme.accent)
                                .frame(width: 44, height: 44)
                                .background(Color.white.opacity(0.82))
                                .clipShape(Circle())
                        }
                        .disabled(messageText.isEmpty)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        .ultraThinMaterial
                    )
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: clearChat) {
                        Image(systemName: "trash")
                            .foregroundColor(Theme.accent)
                    }
                }
            }
        }
        .onTapGesture {
            isInputFocused = false
        }
    }

    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard !isSending else { return } // Prevent multiple sends

        // Add user message
        let userMessage = ArisaChatMessage(
            id: UUID(),
            text: messageText,
            isUser: true,
            timestamp: Date()
        )
        messages.append(userMessage)

        let userQuery = messageText
        messageText = ""

        // Show typing indicator
        isTyping = true
        isSending = true

        // Convert messages to SkinChatMessage format for API
        let context = messages.map { msg in
            SkinChatMessage(
                content: msg.text,
                isFromUser: msg.isUser,
                timestamp: msg.timestamp
            )
        }

        // Call OpenAI API
        Task {
            do {
                let enrichedQuery: String
                if profileContext.isEmpty {
                    enrichedQuery = userQuery
                } else {
                    enrichedQuery = "\(profileContext)\n\nUser question: \(userQuery)"
                }

                let response = try await OpenAIService.shared.sendChatMessage(enrichedQuery, context: context)

                await MainActor.run {
                    isTyping = false
                    isSending = false
                    let aiMessage = ArisaChatMessage(
                        id: UUID(),
                        text: response,
                        isUser: false,
                        timestamp: Date()
                    )
                    messages.append(aiMessage)
                }
            } catch {
                // Fallback to simple response if API fails
                await MainActor.run {
                    isTyping = false
                    isSending = false
                    let fallbackResponse = generateAIResponse(for: userQuery)
                    let aiMessage = ArisaChatMessage(
                        id: UUID(),
                        text: fallbackResponse,
                        isUser: false,
                        timestamp: Date()
                    )
                    messages.append(aiMessage)
                }
            }
        }
    }

    private func generateAIResponse(for query: String) -> String {
        let lowercasedQuery = query.lowercased()

        // Simple keyword-based responses (fallback when API is down)
        if lowercasedQuery.contains("acne") || lowercasedQuery.contains("pimple") || lowercasedQuery.contains("breakout") {
            return AppLanguageManager.shared.localized("Arisa fallback acne")
        } else if lowercasedQuery.contains("dry") || lowercasedQuery.contains("hydration") {
            return AppLanguageManager.shared.localized("Arisa fallback dry")
        } else if lowercasedQuery.contains("dark") || lowercasedQuery.contains("spot") || lowercasedQuery.contains("hyperpigmentation") {
            return AppLanguageManager.shared.localized("Arisa fallback dark spots")
        } else if lowercasedQuery.contains("routine") {
            return AppLanguageManager.shared.localized("Arisa fallback routine")
        } else if lowercasedQuery.contains("glow") || lowercasedQuery.contains("glass skin") {
            return AppLanguageManager.shared.localized("Arisa fallback glow")
        } else if lowercasedQuery.contains("aging") || lowercasedQuery.contains("wrinkle") || lowercasedQuery.contains("fine line") {
            return AppLanguageManager.shared.localized("Arisa fallback aging")
        } else if lowercasedQuery.contains("product") || lowercasedQuery.contains("recommend") {
            return AppLanguageManager.shared.localized("Arisa fallback products")
        } else if lowercasedQuery.contains("hi") || lowercasedQuery.contains("hello") || lowercasedQuery.contains("hey") {
            return AppLanguageManager.shared.localized("Arisa fallback hello")
        } else {
            let responses = [
                AppLanguageManager.shared.localized("Arisa fallback general 1"),
                AppLanguageManager.shared.localized("Arisa fallback general 2"),
                AppLanguageManager.shared.localized("Arisa fallback general 3"),
                AppLanguageManager.shared.localized("Arisa fallback general 4"),
                AppLanguageManager.shared.localized("Arisa fallback general 5")
            ]
            return responses.randomElement() ?? AppLanguageManager.shared.localized("Arisa fallback default")
        }
    }

    private func clearChat() {
        messages = [
            ArisaChatMessage(
                id: UUID(),
                text: AppLanguageManager.shared.localized("Arisa welcome message"),
                isUser: false,
                timestamp: Date()
            )
        ]
    }
}

struct ArisaChatMessage: Identifiable {
    let id: UUID
    let text: String
    let isUser: Bool
    let timestamp: Date
}

struct ArisaMessageBubble: View {
    let message: ArisaChatMessage

    var body: some View {
        HStack {
            if message.isUser {
                Spacer(minLength: 60)
            }

            Text(message.text)
                .font(.system(size: 16))
                .foregroundColor(message.isUser ? .white : Color(uiColor: .label))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(message.isUser ? AnyShapeStyle(Theme.pinkButtonGradient) : AnyShapeStyle(Color.white.opacity(0.78)))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(message.isUser ? Color.clear : Color.white.opacity(0.72), lineWidth: 1)
                )
                .overlay(
                    message.isUser ?
                    nil :
                    Image("arisa_avatar")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Theme.accent, lineWidth: 2)
                        )
                        .offset(x: -40, y: -20),
                    alignment: .topLeading
                )

            if !message.isUser {
                Spacer(minLength: 60)
            }
        }
    }
}

struct ArisaTypingIndicator: View {
    @State private var animationAmount = 0.0

    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Theme.accent)
                        .frame(width: 8, height: 8)
                        .scaleEffect(animationAmount)
                        .opacity(animationAmount)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: animationAmount
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.78))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            Spacer(minLength: 60)
        }
        .onAppear {
            animationAmount = 1.0
        }
    }
}

#Preview {
    ArisaAIView()
}
