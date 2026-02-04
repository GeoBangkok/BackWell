//
//  ArisaAIView.swift
//  SkinGlowing
//
//  AI Beauty Assistant with iMessage-like interface
//

import SwiftUI

struct ArisaAIView: View {
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = [
        ChatMessage(
            id: UUID(),
            text: "Hi! I'm Arisa, your AI beauty assistant 💕 I can help you with skincare advice, product recommendations, and answer any questions about your skin!",
            isUser: false,
            timestamp: Date()
        )
    ]
    @State private var isTyping = false
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
                                    MessageBubble(message: message)
                                        .id(message.id)
                                }

                                if isTyping {
                                    TypingIndicator()
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

        // Add user message
        let userMessage = ChatMessage(
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

        // Simulate AI response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isTyping = false

            let response = generateAIResponse(for: userQuery)
            let aiMessage = ChatMessage(
                id: UUID(),
                text: response,
                isUser: false,
                timestamp: Date()
            )
            messages.append(aiMessage)
        }
    }

    private func generateAIResponse(for query: String) -> String {
        let lowercasedQuery = query.lowercased()

        // Simple keyword-based responses
        if lowercasedQuery.contains("acne") || lowercasedQuery.contains("pimple") || lowercasedQuery.contains("breakout") {
            return "For acne-prone skin, I recommend:\n\n• Use a gentle cleanser with salicylic acid\n• Apply benzoyl peroxide as a spot treatment\n• Use non-comedogenic moisturizers\n• Consider adding niacinamide to reduce inflammation\n• Always remove makeup before bed\n\nWould you like specific product recommendations?"
        } else if lowercasedQuery.contains("dry") || lowercasedQuery.contains("hydration") {
            return "To combat dry skin:\n\n• Use a creamy, hydrating cleanser\n• Apply hyaluronic acid serum on damp skin\n• Layer a rich moisturizer with ceramides\n• Consider slugging at night with petroleum jelly\n• Use a humidifier in your room\n\nDrink plenty of water throughout the day! 💧"
        } else if lowercasedQuery.contains("dark") || lowercasedQuery.contains("spot") || lowercasedQuery.contains("hyperpigmentation") {
            return "For dark spots and hyperpigmentation:\n\n• Vitamin C serum in the morning\n• Retinol at night (start slowly!)\n• Niacinamide to even skin tone\n• Alpha arbutin for stubborn spots\n• SPF 50+ daily (this is crucial!)\n\nResults take 6-12 weeks, so be patient! ✨"
        } else if lowercasedQuery.contains("routine") {
            return "Here's a basic skincare routine:\n\n🌅 Morning:\n1. Gentle cleanser\n2. Toner (optional)\n3. Vitamin C serum\n4. Moisturizer\n5. SPF 50+\n\n🌙 Evening:\n1. Oil cleanser (if wearing makeup)\n2. Water-based cleanser\n3. Treatment (retinol/acids)\n4. Hydrating serum\n5. Night moisturizer\n\nAdjust based on your skin type!"
        } else if lowercasedQuery.contains("glow") || lowercasedQuery.contains("glass skin") {
            return "For that glass skin glow:\n\n✨ The 7 Skin Method: Layer toner 7 times\n• Use hydrating essences\n• Apply face oil before moisturizer\n• Weekly sheet masks\n• Gentle exfoliation 2x per week\n• Facial massage with gua sha\n• Sleep 7-8 hours nightly\n\nGlow comes from within - stay hydrated! 🌟"
        } else if lowercasedQuery.contains("aging") || lowercasedQuery.contains("wrinkle") || lowercasedQuery.contains("fine line") {
            return "Anti-aging skincare tips:\n\n• Retinol is gold standard (start with 0.25%)\n• Peptides boost collagen production\n• Vitamin C protects from free radicals\n• Hyaluronic acid plumps skin\n• SPF is your best anti-aging tool\n• Consider bakuchiol as gentle alternative\n\nConsistency is key! Results show in 3-6 months 🌺"
        } else if lowercasedQuery.contains("product") || lowercasedQuery.contains("recommend") {
            return "Based on your skin analysis, I recommend:\n\n🌟 Cleanser: CeraVe Hydrating Cleanser\n🌟 Serum: The Ordinary Niacinamide 10%\n🌟 Moisturizer: Cetaphil Daily Hydrating Lotion\n🌟 SPF: La Roche-Posay Anthelios\n🌟 Treatment: Paula's Choice BHA Liquid\n\nStart with basics and add products gradually!"
        } else if lowercasedQuery.contains("hi") || lowercasedQuery.contains("hello") || lowercasedQuery.contains("hey") {
            return "Hello beautiful! 💕 How can I help you with your skincare journey today? I can help with:\n\n• Skincare routines\n• Product recommendations\n• Ingredient explanations\n• Skin concerns\n• Beauty tips\n\nWhat would you like to know?"
        } else {
            let responses = [
                "Great question! Based on your skin type, I'd suggest starting with a gentle routine and gradually adding active ingredients. What specific concern would you like to address?",
                "That's interesting! Skincare is so personal. Can you tell me more about your skin type and main concerns so I can give you tailored advice?",
                "I understand! Consistency is key in skincare. Remember: cleanse, treat, moisturize, and protect with SPF. What step would you like to focus on?",
                "Good point! Every skin journey is unique. Would you like tips for morning routine, evening routine, or specific product recommendations?",
                "Absolutely! The key is finding what works for YOUR skin. Have you noticed any particular ingredients that your skin loves or reacts to?"
            ]
            return responses.randomElement() ?? "I'm here to help! Feel free to ask me anything about skincare, routines, or products."
        }
    }

    private func clearChat() {
        messages = [
            ChatMessage(
                id: UUID(),
                text: "Hi! I'm Arisa, your AI beauty assistant 💕 I can help you with skincare advice, product recommendations, and answer any questions about your skin!",
                isUser: false,
                timestamp: Date()
            )
        ]
    }
}

struct ChatMessage: Identifiable {
    let id: UUID
    let text: String
    let isUser: Bool
    let timestamp: Date
}

struct MessageBubble: View {
    let message: ChatMessage

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

struct TypingIndicator: View {
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