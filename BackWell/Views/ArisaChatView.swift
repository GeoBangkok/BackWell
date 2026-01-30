//
//  ArisaChatView.swift
//  SkinWell
//
//  AI Skin Companion chat interface
//

import SwiftUI

struct ArisaChatView: View {
    @State private var messages: [ChatMessage] = [
        ChatMessage(
            content: "Hi! I'm Arisa, your AI skincare companion. I can help you with personalized skincare advice, product recommendations, and answer any questions about your skin. What would you like to know today?",
            isFromUser: false,
            timestamp: Date()
        )
    ]
    @State private var inputText = ""
    @State private var isTyping = false
    @State private var showSuggestions = true

    let suggestions = [
        "What's my skin type?",
        "How can I reduce acne?",
        "Best morning routine?",
        "Why is SPF important?",
        "How to treat dark spots?",
        "What causes dry skin?"
    ]

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [Theme.purpleUltraLight, Color.white],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with Arisa avatar
                ArisaHeader()

                // Chat messages
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }

                            if isTyping {
                                TypingIndicator()
                                    .id("typing")
                            }

                            // Suggestions
                            if showSuggestions && messages.count <= 2 {
                                SuggestionsView(
                                    suggestions: suggestions,
                                    onSelect: { suggestion in
                                        sendMessage(suggestion)
                                        showSuggestions = false
                                    }
                                )
                            }
                        }
                        .padding()
                        .padding(.bottom, 20)
                    }
                    .onChange(of: messages.count) { _, _ in
                        withAnimation {
                            proxy.scrollTo(messages.last?.id ?? "typing", anchor: .bottom)
                        }
                    }
                }

                // Input field
                ChatInputField(
                    text: $inputText,
                    onSend: {
                        sendMessage(inputText)
                        inputText = ""
                    }
                )
            }
        }
    }

    func sendMessage(_ text: String) {
        guard !text.isEmpty else { return }

        // Add user message
        let userMessage = ChatMessage(
            content: text,
            isFromUser: true,
            timestamp: Date()
        )
        messages.append(userMessage)

        // Show typing indicator
        isTyping = true

        // Call real OpenAI API
        Task {
            do {
                let response = try await OpenAIService.shared.sendChatMessage(text, context: messages)

                await MainActor.run {
                    isTyping = false
                    let aiMessage = ChatMessage(
                        content: response,
                        isFromUser: false,
                        timestamp: Date()
                    )
                    messages.append(aiMessage)
                }
            } catch {
                // If API fails, fall back to generated response
                await MainActor.run {
                    isTyping = false
                    let fallbackResponse = generateAIResponse(for: text)
                    let aiMessage = ChatMessage(
                        content: fallbackResponse,
                        isFromUser: false,
                        timestamp: Date()
                    )
                    messages.append(aiMessage)
                }
            }
        }
    }

    func generateAIResponse(for input: String) -> String {
        let lowercased = input.lowercased()

        // Simple response logic - in production, this would call OpenAI API
        if lowercased.contains("skin type") {
            return "Based on your recent scan, you have combination skin - oily in the T-zone with normal to dry cheeks. This is very common! I recommend using a gentle, balancing cleanser and adjusting your moisturizer based on different areas of your face."
        } else if lowercased.contains("acne") {
            return "For acne management, consistency is key! Here's what I recommend:\n\n1. Use a salicylic acid cleanser\n2. Apply benzoyl peroxide spot treatment\n3. Don't skip moisturizer - dehydrated skin produces more oil\n4. Always remove makeup before bed\n5. Change pillowcases weekly\n\nWould you like specific product recommendations?"
        } else if lowercased.contains("morning routine") {
            return "Here's your perfect morning routine:\n\n1. 🧼 Gentle cleanser (60 sec)\n2. 🌊 Hydrating toner (30 sec)\n3. 💧 Vitamin C serum (45 sec)\n4. 👁 Eye cream (20 sec)\n5. 🧴 Moisturizer (45 sec)\n6. ☀️ SPF 30+ sunscreen (30 sec)\n\nTotal time: ~4 minutes for glowing skin!"
        } else if lowercased.contains("spf") || lowercased.contains("sunscreen") {
            return "SPF is your skin's best friend! Here's why:\n\n☀️ Prevents premature aging (80% of aging is from sun damage)\n🛡 Protects from skin cancer\n✨ Maintains even skin tone\n🌟 Prevents dark spots\n\nApply SPF 30+ every morning, even on cloudy days. Reapply every 2 hours when outdoors. Your future self will thank you!"
        } else if lowercased.contains("dark spots") {
            return "Dark spots can be treated effectively! Here's my approach:\n\n1. Vitamin C serum in the morning\n2. Niacinamide to even skin tone\n3. Retinol at night (start slowly)\n4. AHA/BHA exfoliation 2x weekly\n5. Daily SPF to prevent new spots\n\nPatience is key - results typically show in 6-12 weeks. Stay consistent!"
        } else if lowercased.contains("dry skin") {
            return "Let's fix that dryness! Common causes:\n\n❄️ Weather changes\n💧 Dehydration\n🧼 Harsh cleansers\n🚿 Hot showers\n💊 Some medications\n\nMy recommendations:\n• Switch to cream cleanser\n• Layer hydrating toner\n• Use hyaluronic acid serum\n• Apply thick moisturizer on damp skin\n• Consider a humidifier\n• Drink more water!"
        } else {
            return "Great question! Based on your skin profile, I recommend focusing on maintaining a consistent routine. Remember, healthy skin is a journey, not a destination. Would you like me to create a personalized routine for your specific concerns?"
        }
    }
}

struct ArisaHeader: View {
    @State private var pulseAnimation = false

    var body: some View {
        HStack(spacing: 15) {
            // Animated avatar
            ZStack {
                Circle()
                    .fill(Theme.purple)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .stroke(Theme.purpleLight, lineWidth: 3)
                            .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                            .opacity(pulseAnimation ? 0 : 1)
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false), value: pulseAnimation)
                    )

                Text("A")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .onAppear { pulseAnimation = true }

            VStack(alignment: .leading, spacing: 2) {
                Text("Arisa")
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)

                HStack(spacing: 5) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)

                    Text("AI Skin Expert • Always Online")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                }
            }

            Spacer()

            // Info button
            Button(action: {}) {
                Image(systemName: "info.circle")
                    .font(.title3)
                    .foregroundColor(Theme.purple)
            }
        }
        .padding()
        .background(Color.white)
        .shadow(color: Theme.shadow, radius: 5, x: 0, y: 2)
    }
}

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isFromUser { Spacer() }

            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 5) {
                Text(message.content)
                    .font(.body)
                    .foregroundColor(message.isFromUser ? .white : Theme.textPrimary)
                    .padding()
                    .background(
                        message.isFromUser ?
                        AnyView(Theme.buttonGradient) :
                        AnyView(Color.white)
                    )
                    .cornerRadius(20)
                    .shadow(color: Theme.shadow, radius: 3, x: 0, y: 2)

                Text(formatTime(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(Theme.textMuted)
                    .padding(.horizontal, 5)
            }
            .frame(maxWidth: 280, alignment: message.isFromUser ? .trailing : .leading)

            if !message.isFromUser { Spacer() }
        }
    }

    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct TypingIndicator: View {
    @State private var animationOffset: CGFloat = 0

    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Theme.purple)
                        .frame(width: 8, height: 8)
                        .offset(y: animationOffset)
                        .animation(
                            Animation.easeInOut(duration: 0.5)
                                .repeatForever()
                                .delay(Double(index) * 0.1),
                            value: animationOffset
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Theme.shadow, radius: 3, x: 0, y: 2)

            Spacer()
        }
        .onAppear {
            animationOffset = -5
        }
    }
}

struct SuggestionsView: View {
    let suggestions: [String]
    let onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick Questions")
                .font(.headline)
                .foregroundColor(Theme.textPrimary)
                .padding(.horizontal, 5)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(suggestions, id: \.self) { suggestion in
                        Button(action: { onSelect(suggestion) }) {
                            Text(suggestion)
                                .font(.body)
                                .foregroundColor(Theme.purple)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Theme.purpleUltraLight)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Theme.purple.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                }
            }
        }
        .padding(.vertical, 10)
    }
}

struct ChatInputField: View {
    @Binding var text: String
    let onSend: () -> Void
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Attachment button
            Button(action: {}) {
                Image(systemName: "photo")
                    .font(.title3)
                    .foregroundColor(Theme.purple)
            }

            // Text field
            HStack {
                TextField("Ask Arisa anything...", text: $text)
                    .focused($isFocused)
                    .onSubmit(onSend)

                if !text.isEmpty {
                    Button(action: { text = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Theme.textMuted)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white)
            .cornerRadius(25)
            .shadow(color: Theme.shadow, radius: 3, x: 0, y: 2)

            // Send button
            Button(action: onSend) {
                Image(systemName: "paperplane.fill")
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(
                        Circle()
                            .fill(text.isEmpty ? Color.gray : Theme.purple)
                    )
            }
            .disabled(text.isEmpty)
            .animation(.spring(), value: text.isEmpty)
        }
        .padding()
        .background(
            Color.white.opacity(0.95)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

#Preview {
    ArisaChatView()
}