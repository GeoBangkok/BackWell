//
//  ModernRoutinePlayerView.swift
//  SkinGlowing
//
//  Modern routine player with clear timer and white/pink design
//

import SwiftUI
import AVFoundation

struct ModernRoutinePlayerView: View {
    let routine: BeautyRoutine
    @Environment(\.dismiss) var dismiss
    @State private var currentStepIndex = 0
    @State private var timeRemaining = 60
    @State private var isPlaying = false
    @State private var totalElapsed = 0
    @State private var timer: Timer?
    @State private var showingCompletion = false

    // Generate routine steps based on routine type
    var routineSteps: [BeautyRoutineStep] {
        routine.products.enumerated().map { index, product in
            BeautyRoutineStep(
                stepNumber: index + 1,
                title: product,
                description: "Apply \(product) to your skin",
                duration: 60, // 60 seconds per step
                instructions: [
                    "Apply product evenly",
                    "Massage in circular motions",
                    "Wait for complete absorption"
                ],
                productType: product
            )
        }
    }

    var currentStep: BeautyRoutineStep? {
        guard currentStepIndex < routineSteps.count else { return nil }
        return routineSteps[currentStepIndex]
    }

    var progress: Double {
        guard let step = currentStep else { return 0 }
        return Double(step.duration - timeRemaining) / Double(step.duration)
    }

    var overallProgress: Double {
        let totalSteps = Double(routineSteps.count)
        let completedSteps = Double(currentStepIndex)
        let currentProgress = currentStep != nil ? progress : 1.0
        return (completedSteps + currentProgress) / totalSteps
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // White background
                Color.white
                    .ignoresSafeArea()

                if !showingCompletion {
                    VStack(spacing: 0) {
                        // Top progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color(hex: "FFE4E1").opacity(0.3))
                                    .frame(height: 6)

                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "FF91A4"), Color(hex: "FFB6C1")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * overallProgress, height: 6)
                                    .animation(.easeInOut(duration: 0.3), value: overallProgress)
                            }
                        }
                        .frame(height: 6)
                        .padding(.top, 10)

                        if let step = currentStep {
                            ScrollView {
                                VStack(spacing: 30) {
                                    // Step indicator
                                    HStack(spacing: 8) {
                                        ForEach(0..<routineSteps.count, id: \.self) { index in
                                            Circle()
                                                .fill(
                                                    index < currentStepIndex ? Color(hex: "FF91A4") :
                                                    index == currentStepIndex ? Color(hex: "FFB6C1") :
                                                    Color(hex: "FFE4E1").opacity(0.5)
                                                )
                                                .frame(width: 8, height: 8)
                                        }
                                    }
                                    .padding(.top, 20)

                                    // Step title
                                    VStack(spacing: 8) {
                                        Text("Step \(step.stepNumber) of \(routineSteps.count)")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(Color(hex: "FF91A4"))

                                        Text(step.title)
                                            .font(.system(size: 28, weight: .bold))
                                            .foregroundColor(Color(uiColor: .label))
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 30)
                                    }

                                    // Timer display
                                    ZStack {
                                        // Background circle
                                        Circle()
                                            .stroke(Color(hex: "FFE4E1").opacity(0.3), lineWidth: 12)
                                            .frame(width: 220, height: 220)

                                        // Progress circle
                                        Circle()
                                            .trim(from: 0, to: progress)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [Color(hex: "FF91A4"), Color(hex: "FFB6C1")],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                style: StrokeStyle(lineWidth: 12, lineCap: .round)
                                            )
                                            .frame(width: 220, height: 220)
                                            .rotationEffect(.degrees(-90))
                                            .animation(.linear(duration: 0.5), value: progress)

                                        // Timer text
                                        VStack(spacing: 8) {
                                            Text("\(timeFormatted)")
                                                .font(.system(size: 56, weight: .bold, design: .rounded))
                                                .foregroundColor(Color(hex: "FF91A4"))

                                            Text("seconds")
                                                .font(.system(size: 18, weight: .medium))
                                                .foregroundColor(Color(hex: "FFB6C1"))
                                        }

                                        // Play/Pause overlay
                                        if !isPlaying {
                                            Circle()
                                                .fill(Color.black.opacity(0.3))
                                                .frame(width: 220, height: 220)

                                            Image(systemName: "play.fill")
                                                .font(.system(size: 50))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .onTapGesture {
                                        togglePlayPause()
                                    }

                                    // Instructions card
                                    VStack(alignment: .leading, spacing: 16) {
                                        HStack {
                                            Image(systemName: "list.bullet")
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundColor(Color(hex: "FF91A4"))

                                            Text("How to apply")
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundColor(Color(uiColor: .label))

                                            Spacer()
                                        }

                                        ForEach(step.instructions, id: \.self) { instruction in
                                            HStack(alignment: .top, spacing: 12) {
                                                Circle()
                                                    .fill(Color(hex: "FFB6C1"))
                                                    .frame(width: 6, height: 6)
                                                    .offset(y: 8)

                                                Text(instruction)
                                                    .font(.system(size: 16))
                                                    .foregroundColor(Color(uiColor: .secondaryLabel))

                                                Spacer()
                                            }
                                        }
                                    }
                                    .padding(20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color(hex: "FFE4E1").opacity(0.2))
                                    )
                                    .padding(.horizontal, 20)
                                }
                                .padding(.bottom, 120)
                            }
                        }

                        // Control buttons at bottom
                        VStack(spacing: 0) {
                            Divider()
                                .background(Color(hex: "FFE4E1").opacity(0.5))

                            HStack(spacing: 40) {
                                // Previous button
                                Button(action: previousStep) {
                                    VStack(spacing: 4) {
                                        Image(systemName: "backward.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(
                                                currentStepIndex > 0 ? Color(hex: "FF91A4") : Color(uiColor: .tertiaryLabel)
                                            )

                                        Text("Previous")
                                            .font(.system(size: 12))
                                            .foregroundColor(
                                                currentStepIndex > 0 ? Color(hex: "FF91A4") : Color(uiColor: .tertiaryLabel)
                                            )
                                    }
                                }
                                .disabled(currentStepIndex == 0)

                                // Play/Pause button
                                Button(action: togglePlayPause) {
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color(hex: "FF91A4"), Color(hex: "FFB6C1")],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 70, height: 70)

                                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                            .font(.system(size: 28))
                                            .foregroundColor(.white)
                                            .offset(x: isPlaying ? 0 : 2)
                                    }
                                }
                                .shadow(color: Color(hex: "FF91A4").opacity(0.3), radius: 10, x: 0, y: 5)

                                // Next button
                                Button(action: nextStep) {
                                    VStack(spacing: 4) {
                                        Image(systemName: "forward.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(Color(hex: "FF91A4"))

                                        Text("Next")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color(hex: "FF91A4"))
                                    }
                                }
                            }
                            .padding(.vertical, 25)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                        }
                    }
                } else {
                    // Completion view
                    VStack(spacing: 30) {
                        Spacer()

                        // Celebration icon
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "FFE4E1"), Color(hex: "FFB6C1")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)

                            Image(systemName: "checkmark")
                                .font(.system(size: 50, weight: .bold))
                                .foregroundColor(.white)
                        }

                        VStack(spacing: 12) {
                            Text("Routine Complete!")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(Color(hex: "FF91A4"))

                            Text("Your skin is glowing! ✨")
                                .font(.system(size: 18))
                                .foregroundColor(Color(uiColor: .secondaryLabel))
                        }

                        // Stats
                        HStack(spacing: 40) {
                            VStack(spacing: 4) {
                                Text("\(routineSteps.count)")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(Color(hex: "FF91A4"))
                                Text("Steps")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(uiColor: .secondaryLabel))
                            }

                            VStack(spacing: 4) {
                                Text("\(totalElapsed / 60)")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(Color(hex: "FF91A4"))
                                Text("Minutes")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(uiColor: .secondaryLabel))
                            }
                        }
                        .padding(.vertical, 20)
                        .frame(maxWidth: 200)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(hex: "FFE4E1").opacity(0.2))
                        )

                        Spacer()

                        Button(action: { dismiss() }) {
                            Text("Done")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    LinearGradient(
                                        colors: [Color(hex: "FF91A4"), Color(hex: "FFB6C1")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 30)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle(routine.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        timer?.invalidate()
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "FF91A4"))
                }
            }
        }
        .onAppear {
            if let firstStep = routineSteps.first {
                timeRemaining = firstStep.duration
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private var timeFormatted: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        if minutes > 0 {
            return String(format: "%d:%02d", minutes, seconds)
        } else {
            return String(format: "%d", seconds)
        }
    }

    private func togglePlayPause() {
        if isPlaying {
            pauseTimer()
        } else {
            startTimer()
        }
        hapticFeedback(.light)
    }

    private func startTimer() {
        isPlaying = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
                totalElapsed += 1

                // Play tick sound for last 3 seconds
                if timeRemaining <= 3 && timeRemaining > 0 {
                    AudioServicesPlaySystemSound(1057) // Tick sound
                }
            } else {
                // Step completed
                AudioServicesPlaySystemSound(1025) // Success sound
                hapticFeedback(.success)
                nextStep()
            }
        }
    }

    private func pauseTimer() {
        isPlaying = false
        timer?.invalidate()
        timer = nil
    }

    private func nextStep() {
        pauseTimer()
        if currentStepIndex < routineSteps.count - 1 {
            currentStepIndex += 1
            timeRemaining = routineSteps[currentStepIndex].duration
            hapticFeedback(.light)
        } else {
            // Routine completed
            showingCompletion = true
            hapticFeedback(.success)
        }
    }

    private func previousStep() {
        pauseTimer()
        if currentStepIndex > 0 {
            currentStepIndex -= 1
            timeRemaining = routineSteps[currentStepIndex].duration
            hapticFeedback(.light)
        }
    }
}

#Preview {
    ModernRoutinePlayerView(
        routine: BeautyRoutine(
            name: "Glass Skin Glow",
            duration: "12 min",
            steps: 7,
            icon: "sparkle",
            description: "Korean-inspired dewy skin routine",
            difficulty: "Intermediate",
            products: ["Oil cleanser", "Water-based cleanser", "Toner", "Essence", "Serum", "Moisturizer", "SPF"]
        )
    )
}