//
//  RoutineMakerView.swift
//  SkinGlowing
//
//  TikTok-style colorful routine maker
//

import SwiftUI

struct RoutineMakerView: View {
    @EnvironmentObject var skinService: SkinAnalysisService
    @State private var currentStepIndex = 0
    @State private var isPlaying = false
    @State private var progress: Double = 0
    @State private var dragOffset: CGSize = .zero
    @State private var showShareSheet = false

    // Sample routine steps with vibrant colors
    let routineSteps = [
        RoutineStep(
            stepNumber: 1,
            title: "Double Cleanse",
            description: "Start with oil cleanser, then foam",
            duration: "60 seconds",
            productType: "Cleanser",
            iconName: "drop.circle.fill",
            color: "#FF6B6B",
            tips: ["Massage in circles", "Focus on T-zone", "Rinse with lukewarm water"]
        ),
        RoutineStep(
            stepNumber: 2,
            title: "Essence Time",
            description: "Pat in your hydrating essence",
            duration: "30 seconds",
            productType: "Essence",
            iconName: "sparkles",
            color: "#4ECDC4",
            tips: ["Pat gently", "Layer if needed", "Don't forget neck"]
        ),
        RoutineStep(
            stepNumber: 3,
            title: "Serum Power",
            description: "Apply your targeted treatment",
            duration: "45 seconds",
            productType: "Serum",
            iconName: "star.fill",
            color: "#FFD93D",
            tips: ["Use droplets", "Press into skin", "Wait to absorb"]
        ),
        RoutineStep(
            stepNumber: 4,
            title: "Eye Care",
            description: "Gentle eye cream application",
            duration: "20 seconds",
            productType: "Eye Cream",
            iconName: "eye",
            color: "#A8E6CF",
            tips: ["Ring finger only", "Tap gently", "Avoid pulling"]
        ),
        RoutineStep(
            stepNumber: 5,
            title: "Moisturize",
            description: "Lock in all the goodness",
            duration: "45 seconds",
            productType: "Moisturizer",
            iconName: "cloud.fill",
            color: "#FFB6C1",
            tips: ["Upward strokes", "Don't forget neck", "Extra on dry areas"]
        ),
        RoutineStep(
            stepNumber: 6,
            title: "SPF Shield",
            description: "Protect from UV damage",
            duration: "30 seconds",
            productType: "Sunscreen",
            iconName: "sun.max.fill",
            color: "#FFEAA7",
            tips: ["2 finger rule", "Reapply every 2h", "Don't miss ears"]
        )
    ]

    var currentStep: RoutineStep {
        routineSteps[currentStepIndex]
    }

    var body: some View {
        ZStack {
            // Dynamic gradient background based on current step
            LinearGradient(
                colors: [
                    Color(hex: currentStep.color),
                    Color(hex: currentStep.color).opacity(0.3),
                    Theme.purpleLight.opacity(0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: currentStepIndex)

            VStack(spacing: 0) {
                // Header
                RoutineHeader(
                    currentStep: currentStepIndex + 1,
                    totalSteps: routineSteps.count,
                    onShare: { showShareSheet = true }
                )

                // Main Content - TikTok style vertical scroll
                GeometryReader { geometry in
                    ZStack {
                        ForEach(routineSteps.indices, id: \.self) { index in
                            if index == currentStepIndex {
                                RoutineStepCard(
                                    step: routineSteps[index],
                                    isActive: true,
                                    progress: progress
                                )
                                .offset(y: dragOffset.height)
                                .animation(.spring(), value: dragOffset)
                            }
                        }
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation
                            }
                            .onEnded { value in
                                let threshold: CGFloat = 50
                                withAnimation(.spring()) {
                                    if value.translation.height < -threshold && currentStepIndex < routineSteps.count - 1 {
                                        currentStepIndex += 1
                                        resetProgress()
                                    } else if value.translation.height > threshold && currentStepIndex > 0 {
                                        currentStepIndex -= 1
                                        resetProgress()
                                    }
                                    dragOffset = .zero
                                }
                            }
                    )
                }

                // Bottom Controls
                RoutineControls(
                    isPlaying: $isPlaying,
                    onPrevious: previousStep,
                    onNext: nextStep,
                    onPlay: togglePlay,
                    canGoPrevious: currentStepIndex > 0,
                    canGoNext: currentStepIndex < routineSteps.count - 1
                )
            }

            // Side indicators (TikTok style)
            HStack {
                Spacer()

                VStack(spacing: 20) {
                    Spacer()

                    // Like button
                    Button(action: {}) {
                        VStack(spacing: 5) {
                            Image(systemName: "heart.fill")
                                .font(.title)
                                .foregroundColor(.white)
                            Text("2.3K")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }

                    // Comment button
                    Button(action: {}) {
                        VStack(spacing: 5) {
                            Image(systemName: "bubble.left.fill")
                                .font(.title)
                                .foregroundColor(.white)
                            Text("89")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }

                    // Share button
                    Button(action: { showShareSheet = true }) {
                        VStack(spacing: 5) {
                            Image(systemName: "arrowshape.turn.up.right.fill")
                                .font(.title)
                                .foregroundColor(.white)
                            Text("Share")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }

                    // Save button
                    Button(action: {}) {
                        VStack(spacing: 5) {
                            Image(systemName: "bookmark.fill")
                                .font(.title)
                                .foregroundColor(.white)
                            Text("Save")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }

                    Spacer()
                        .frame(height: 100)
                }
                .padding(.trailing, 20)
            }
        }
        .onAppear {
            startAutoProgress()
        }
    }

    func previousStep() {
        if currentStepIndex > 0 {
            currentStepIndex -= 1
            resetProgress()
        }
    }

    func nextStep() {
        if currentStepIndex < routineSteps.count - 1 {
            currentStepIndex += 1
            resetProgress()
        }
    }

    func togglePlay() {
        isPlaying.toggle()
        if isPlaying {
            startAutoProgress()
        }
    }

    func resetProgress() {
        progress = 0
        if isPlaying {
            startAutoProgress()
        }
    }

    func startAutoProgress() {
        guard isPlaying else { return }

        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if progress < 1.0 && isPlaying {
                progress += 0.02
            } else {
                timer.invalidate()
                if currentStepIndex < routineSteps.count - 1 {
                    nextStep()
                    startAutoProgress()
                } else {
                    isPlaying = false
                }
            }
        }
    }
}

struct RoutineHeader: View {
    let currentStep: Int
    let totalSteps: Int
    let onShare: () -> Void

    var body: some View {
        VStack(spacing: 15) {
            // Progress indicators
            HStack(spacing: 4) {
                ForEach(1...totalSteps, id: \.self) { step in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(step <= currentStep ? Color.white : Color.white.opacity(0.3))
                        .frame(height: 3)
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)

            HStack {
                Text("Step \(currentStep) of \(totalSteps)")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                Button(action: onShare) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.white)
                        .font(.title3)
                }
            }
            .padding(.horizontal)
        }
        .padding(.top, 10)
    }
}

struct RoutineStepCard: View {
    let step: RoutineStep
    let isActive: Bool
    let progress: Double

    @State private var showTips = false
    @State private var bounceAnimation = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            // Step number indicator
            Text("STEP \(step.stepNumber)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(0.8))
                .tracking(2)

            // Icon with animation
            Image(systemName: step.iconName)
                .font(.system(size: 80))
                .foregroundColor(.white)
                .scaleEffect(bounceAnimation ? 1.2 : 1.0)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        bounceAnimation = true
                    }
                }

            // Title
            Text(step.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            // Description
            Text(step.description)
                .font(.title3)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            // Duration badge
            HStack {
                Image(systemName: "clock.fill")
                Text(step.duration)
            }
            .font(.body)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.2))
            .cornerRadius(20)

            // Product type
            Text(step.productType.uppercased())
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(0.7))
                .tracking(1)

            // Tips section
            VStack(spacing: 12) {
                Button(action: { withAnimation { showTips.toggle() } }) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                        Text(showTips ? "Hide Tips" : "Show Tips")
                    }
                    .font(.body)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(15)
                }

                if showTips {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(step.tips, id: \.self) { tip in
                            HStack(spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.white.opacity(0.8))
                                    .font(.footnote)

                                Text(tip)
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(15)
                    .padding(.horizontal, 40)
                }
            }

            // Progress bar
            if isActive {
                ProgressView(value: progress)
                    .tint(.white)
                    .scaleEffect(x: 1, y: 2)
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
            }

            Spacer()

            // Swipe hint
            HStack(spacing: 5) {
                Image(systemName: "chevron.up")
                Text("Swipe for next step")
                Image(systemName: "chevron.up")
            }
            .font(.caption)
            .foregroundColor(.white.opacity(0.5))
            .padding(.bottom, 100)
        }
    }
}

struct RoutineControls: View {
    @Binding var isPlaying: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onPlay: () -> Void
    let canGoPrevious: Bool
    let canGoNext: Bool

    var body: some View {
        HStack(spacing: 30) {
            Button(action: onPrevious) {
                Image(systemName: "backward.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .opacity(canGoPrevious ? 1 : 0.3)
            }
            .disabled(!canGoPrevious)

            Button(action: onPlay) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
            }

            Button(action: onNext) {
                Image(systemName: "forward.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .opacity(canGoNext ? 1 : 0.3)
            }
            .disabled(!canGoNext)
        }
        .padding()
        .background(Color.black.opacity(0.3))
    }
}

#Preview {
    RoutineMakerView()
        .environmentObject(SkinAnalysisService.shared)
}