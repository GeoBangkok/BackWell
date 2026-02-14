//
//  ArisaAIView.swift
//  SkinGlowing
//
//  AI Beauty Assistant with iMessage-like interface
//

import SwiftUI

struct ArisaAIView: View {
    @State private var messageText = ""
    @State private var messages: [ArisaChatMessage] = [
        ArisaChatMessage(
            id: UUID(),
            text: "heyy bestie!! 💕 i'm arisa, your skincare girlie~ ask me anything about getting that glass skin or spill the tea on your skin concerns ✨",
            isUser: false,
            timestamp: Date()
        )
    ]
    @State private var isTyping = false
    @State private var isSending = false
    @FocusState private var isInputFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(hex: "FFE4E1").opacity(0.1),
                        Color.white
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
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
                            .background(Color(uiColor: .systemGray6))
                            .cornerRadius(20)
                            .lineLimit(1...4)
                            .focused($isInputFocused)
                            .onSubmit {
                                sendMessage()
                            }

                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 34))
                                .foregroundColor(messageText.isEmpty ? Color(uiColor: .systemGray3) : Color(hex: "FF91A4"))
                        }
                        .disabled(messageText.isEmpty)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        Color.white
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: -5)
                    )
                }
            }
            .navigationTitle("Arisa AI")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: clearChat) {
                        Image(systemName: "trash")
                            .foregroundColor(Color(hex: "FF91A4"))
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
                let response = try await OpenAIService.shared.sendChatMessage(userQuery, context: context)

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
            return "omg bestie acne is so annoying fr 😭 try the cerave SA cleanser and the ordinary niacinamide!! also benzoyl peroxide slaps for spot treating but start slow or you'll be peeling like crazy"
        } else if lowercasedQuery.contains("dry") || lowercasedQuery.contains("hydration") {
            return "dry skin era is not it 🥺 get you some hyaluronic acid serum (apply on WET skin!!!), cerave in the tub, and maybe slug with aquaphor at night if you're feeling spicy"
        } else if lowercasedQuery.contains("dark") || lowercasedQuery.contains("spot") || lowercasedQuery.contains("hyperpigmentation") {
            return "dark spots are my villain origin story fr 😭 vitamin c in the AM, retinol at night but like... start slowww. also SPF is literally non-negotiable bestie"
        } else if lowercasedQuery.contains("routine") {
            return "okayy so morning: cleanser, vitamin c, moisturizer, SPF (or else 🔫). night: double cleanse if you wore makeup, then your actives (retinol/acids), hydrating serum, thicc moisturizer. keep it simple tho!!"
        } else if lowercasedQuery.contains("glow") || lowercasedQuery.contains("glass skin") {
            return "glass skin tutorial incoming ✨ the 7 skin method goes HARD (layer toner 7 times no cap), snail mucin is chef's kiss, and facial oils before moisturizer!! also hydrate or diedrate bestie 💕"
        } else if lowercasedQuery.contains("aging") || lowercasedQuery.contains("wrinkle") || lowercasedQuery.contains("fine line") {
            return "anti-aging before 30? preventative queen behavior ✨ retinol is THAT girl but start at 0.25% or you'll be a flaky mess. also peptides + vitamin c + SPF = the holy trinity"
        } else if lowercasedQuery.contains("product") || lowercasedQuery.contains("recommend") {
            return "my ride or dies rn: cerave cleanser (she's reliable), the ordinary niacinamide (budget friendly icon), la roche posay SPF (french girls know wassup), and paula's choice BHA for texture!! start simple tho"
        } else if lowercasedQuery.contains("hi") || lowercasedQuery.contains("hello") || lowercasedQuery.contains("hey") {
            return "hiii babe!! 💕 what's the skin sitch today? i can help with routines, product recs, or just decode those confusing ingredients. spill the tea!"
        } else {
            let responses = [
                "ooh good question bestie! what's your main skin concern rn? acne? dryness? or are we just trying to glow up? 💕",
                "hmm interesting!! tell me more about your skin type so i can give you the tea ✨",
                "okay but like consistency is everything fr! even the best routine won't work if you're not doing it daily",
                "yesss let's talk about it! are you more of a 3-step girlie or do you want the full 10-step k-beauty moment?",
                "no literally everyone's skin is so different! what works for one person might break someone else out 😭"
            ]
            return responses.randomElement() ?? "bestie i'm here for all your skin questions!! let's get you glowing ✨"
        }
    }

    private func clearChat() {
        messages = [
            ArisaChatMessage(
                id: UUID(),
                text: "heyy bestie!! 💕 i'm arisa, your skincare girlie~ ask me anything about getting that glass skin or spill the tea on your skin concerns ✨",
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
                .background(
                    message.isUser ?
                    AnyView(
                        LinearGradient(
                            colors: [Color(hex: "FF91A4"), Color(hex: "FFB6C1")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    ) :
                    AnyView(Color(uiColor: .systemGray6))
                )
                .cornerRadius(18)
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
                                .stroke(Color(hex: "FF91A4"), lineWidth: 2)
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
                        .fill(Color(hex: "FF91A4"))
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
            .background(Color(uiColor: .systemGray6))
            .cornerRadius(18)

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