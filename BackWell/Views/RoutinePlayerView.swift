//
//  RoutinePlayerView.swift
//  SkinGlowing
//
//  Step-by-step beauty routine player with timers
//

import SwiftUI
import AVFoundation

struct RoutinePlayerView: View {
    let routine: BeautyRoutine
    @Environment(\.dismiss) var dismiss
    @State private var currentStepIndex = 0
    @State private var timeRemaining = 60
    @State private var isPlaying = false
    @State private var totalElapsed = 0
    @State private var timer: Timer?

    // Generate routine steps based on routine type
    var routineSteps: [BeautyRoutineStep] {
        // This would normally come from the routine model
        // For now, generate sample steps based on products
        routine.products.enumerated().map { index, product in
            BeautyRoutineStep(
                stepNumber: index + 1,
                title: product,
                description: "Apply \(product) to your skin",
                duration: 60, // 60 seconds per step
                instructions: [
                    "Apply product evenly",
                    "Massage gently",
                    "Wait for absorption"
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

    var body: some View {
        NavigationStack {
            ZStack {
                // Gradient background
                LinearGradient(
                    colors: [
                        Color(hex: "FFE4E1").opacity(0.3),
                        Color(hex: "FFB6C1").opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color(uiColor: UIColor.systemGray5))
                                .frame(height: 4)

                            Rectangle()
                                .fill(Color(hex: "FF91A4"))
                                .frame(width: geometry.size.width * progressForAllSteps, height: 4)
                        }
                    }
                    .frame(height: 4)
                    .padding(.horizontal)
                    .padding(.top, 10)

                    ScrollView {
                        VStack(spacing: 30) {
                            // Current step info
                            if let step = currentStep {
                                VStack(spacing: 20) {
                                    // Step number and title
                                    VStack(spacing: 8) {
                                        Text("Step \(step.stepNumber) of \(routineSteps.count)")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color(uiColor: UIColor.secondaryLabel))

                                        Text(step.title)
                                            .font(.system(size: 28, weight: .bold))
                                            .foregroundColor(Color(uiColor: UIColor.label))
                                            .multilineTextAlignment(.center)
                                    }

                                    // Timer circle
                                    ZStack {
                                        Circle()
                                            .stroke(Color(uiColor: UIColor.systemGray5), lineWidth: 10)
                                            .frame(width: 200, height: 200)

                                        Circle()
                                            .trim(from: 0, to: progress)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [Color(hex: "FF91A4"), Color(hex: "FFB6C1")],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ),
                                                style: StrokeStyle(lineWidth: 10, lineCap: .round)
                                            )
                                            .frame(width: 200, height: 200)
                                            .rotationEffect(.degrees(-90))

                                        VStack {
                                            Text("\(timeRemaining)")
                                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                                .foregroundColor(Color(uiColor: UIColor.label))

                                            Text("seconds")
                                                .font(.system(size: 16))
                                                .foregroundColor(Color(uiColor: UIColor.secondaryLabel))
                                        }
                                    }
                                    .padding(.vertical, 20)

                                    // Instructions
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Instructions")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(Color(uiColor: UIColor.label))

                                        ForEach(step.instructions, id: \.self) { instruction in
                                            HStack(alignment: .top, spacing: 10) {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(Color(hex: "FF91A4"))

                                                Text(instruction)
                                                    .font(.system(size: 15))
                                                    .foregroundColor(Color(uiColor: UIColor.secondaryLabel))

                                                Spacer()
                                            }
                                        }
                                    }
                                    .padding(20)
                                    .background(Color(uiColor: UIColor.systemBackground))
                                    .cornerRadius(16)
                                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                }
                                .padding(.horizontal, 20)
                            } else {
                                // Routine completed
                                VStack(spacing: 20) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 80))
                                        .foregroundColor(Color(hex: "FF91A4"))

                                    Text("Routine Complete!")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(Color(uiColor: UIColor.label))

                                    Text("Great job! Your skin is glowing")
                                        .font(.system(size: 18))
                                        .foregroundColor(Color(uiColor: UIColor.secondaryLabel))

                                    Button(action: { dismiss() }) {
                                        Text("Done")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 16)
                                            .background(
                                                LinearGradient(
                                                    colors: [Color(hex: "FF91A4"), Color(hex: "FFB6C1")],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .cornerRadius(16)
                                    }
                                    .padding(.horizontal, 40)
                                    .padding(.top, 20)
                                }
                                .padding(.top, 100)
                            }
                        }
                    }

                    // Control buttons
                    if currentStep != nil {
                        HStack(spacing: 20) {
                            // Previous button
                            Button(action: previousStep) {
                                Image(systemName: "backward.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(currentStepIndex > 0 ? Color(hex: "FF91A4") : Color(uiColor: UIColor.tertiaryLabel))
                            }
                            .disabled(currentStepIndex == 0)

                            // Play/Pause button
                            Button(action: togglePlayPause) {
                                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(Color(hex: "FF91A4"))
                            }

                            // Next button
                            Button(action: nextStep) {
                                Image(systemName: "forward.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(Color(hex: "FF91A4"))
                            }
                        }
                        .padding(.vertical, 30)
                        .frame(maxWidth: .infinity)
                        .background(Color(uiColor: UIColor.systemBackground))
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
                    }
                }
            }
            .navigationTitle(routine.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
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

    private var progressForAllSteps: Double {
        let totalSteps = Double(routineSteps.count)
        let completedSteps = Double(currentStepIndex)
        let currentProgress = currentStep != nil ? progress : 1.0
        return (completedSteps + currentProgress) / totalSteps
    }

    private func togglePlayPause() {
        if isPlaying {
            pauseTimer()
        } else {
            startTimer()
        }
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
        } else {
            // Routine completed
            currentStepIndex = routineSteps.count
        }
    }

    private func previousStep() {
        pauseTimer()
        if currentStepIndex > 0 {
            currentStepIndex -= 1
            timeRemaining = routineSteps[currentStepIndex].duration
        }
    }
}