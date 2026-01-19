//
//  ExercisePlayerView.swift
//  BackWell
//
//  Created by standard on 1/17/26.
//

import SwiftUI

struct ExercisePlayerView: View {
    let dayProgram: DayProgram
    @Environment(\.dismiss) var dismiss

    @State private var currentExerciseIndex = 0
    @State private var currentMentalIndex = 0
    @State private var timeRemaining = 0
    @State private var isPlaying = false
    @State private var isPaused = false
    @State private var showingMentalComponent = false
    @State private var sessionComplete = false
    @State private var showingIntro = true
    @State private var timer: Timer?

    var currentExercise: Exercise? {
        guard !showingMentalComponent && currentExerciseIndex < dayProgram.exercises.count else { return nil }
        return dayProgram.exercises[currentExerciseIndex]
    }

    var currentMental: MentalComponent? {
        guard showingMentalComponent && currentMentalIndex < dayProgram.mentalComponents.count else { return nil }
        return dayProgram.mentalComponents[currentMentalIndex]
    }

    var totalExercises: Int { dayProgram.exercises.count }

    private var background: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.95, green: 0.97, blue: 0.98),
                Color(red: 0.88, green: 0.94, blue: 0.96),
                Color(red: 0.82, green: 0.91, blue: 0.94)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                background

                VStack(spacing: 0) {
                    // Top nav row only (no progress/header section)
                    topNavRow
                        .padding(.top, max(8, geo.safeAreaInsets.top))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)

                    Group {
                        if showingIntro {
                            DayIntroView(dayProgram: dayProgram, onStart: {
                                showingIntro = false
                            })
                        } else if sessionComplete {
                            CompletionView(dayProgram: dayProgram)
                        } else if showingMentalComponent, let mental = currentMental {
                            MentalComponentView(
                                mentalComponent: mental,
                                timeRemaining: $timeRemaining,
                                isPlaying: $isPlaying,
                                onComplete: moveToNextComponent
                            )
                        } else if let exercise = currentExercise {
                            // EXERCISE: anchored near the top (not centered)
                            exerciseContent(exercise: exercise)
                        } else {
                            Color.clear
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()

                    if !showingIntro, !sessionComplete, !showingMentalComponent, currentExercise != nil {
                        ExerciseControls(
                            isPlaying: $isPlaying,
                            isPaused: $isPaused,
                            onPlay: startExercise,
                            onPause: pauseExercise,
                            onSkip: skipExercise,
                            onComplete: completeExercise
                        )
                        .padding(.bottom, max(12, geo.safeAreaInsets.bottom))
                    }
                }
            }
        }
        .onAppear {
            if let exercise = currentExercise {
                timeRemaining = exercise.duration
            } else if let mental = currentMental {
                timeRemaining = mental.duration
            }
        }
        .onChange(of: isPlaying) { _, newValue in
            if newValue { startTimer() } else { stopTimer() }
        }
    }

    private var topNavRow: some View {
        HStack {
            Button(action: { dismiss() }) {
                HStack(spacing: 5) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .semibold))
                    Text("Home")
                        .font(.system(size: 14, weight: .regular))
                }
                .foregroundColor(Color(red: 0.3, green: 0.6, blue: 0.7))
            }

            Spacer()

            Text("Day \(dayProgram.day)")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.5))

            Spacer()

            // keep the title centered
            Color.clear.frame(width: 65)
        }
    }

    @ViewBuilder
    private func exerciseContent(exercise: Exercise) -> some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                ExerciseAnimation(icon: exercise.icon, isPlaying: isPlaying)

                TimerDisplay(timeRemaining: timeRemaining, isPlaying: isPlaying)

                VStack(spacing: 3) {
                    Text(exercise.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.5))
                        .multilineTextAlignment(.center)

                    Text(exercise.focusArea)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(red: 0.3, green: 0.6, blue: 0.7))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(red: 0.3, green: 0.6, blue: 0.7).opacity(0.1))
                        )
                }

                // How to Perform - compact version
                VStack(alignment: .leading, spacing: 4) {
                    Text("How to Perform!")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.5))

                    ForEach(Array(exercise.instructions.enumerated()), id: \.offset) { index, instruction in
                        HStack(alignment: .top, spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.3, green: 0.6, blue: 0.7).opacity(0.2))
                                    .frame(width: 18, height: 18)

                                Text("\(index + 1)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(Color(red: 0.3, green: 0.6, blue: 0.7))
                            }

                            Text(instruction)
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(Color(red: 0.3, green: 0.4, blue: 0.5))
                                .fixedSize(horizontal: false, vertical: true)
                                .lineSpacing(1)

                            Spacer()
                        }
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.7))
                )
                .padding(.horizontal, 20)
            }
            .padding(.top, 4)

            Spacer(minLength: 8)
        }
    }

    // MARK: - Actions

    func startExercise() {
        isPlaying = true
        isPaused = false
    }

    func pauseExercise() {
        isPlaying = false
        isPaused = true
    }

    func skipExercise() {
        moveToNextComponent()
    }

    func completeExercise() {
        moveToNextComponent()
    }

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                stopTimer()
                isPlaying = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    moveToNextComponent()
                }
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func moveToNextComponent() {
        stopTimer()
        isPlaying = false

        if showingMentalComponent {
            currentMentalIndex += 1
            if currentMentalIndex < dayProgram.mentalComponents.count {
                timeRemaining = dayProgram.mentalComponents[currentMentalIndex].duration
            } else {
                showingMentalComponent = false
                currentExerciseIndex += 1
                currentMentalIndex = 0

                if currentExerciseIndex < dayProgram.exercises.count {
                    timeRemaining = dayProgram.exercises[currentExerciseIndex].duration
                } else {
                    sessionComplete = true
                }
            }
        } else {
            currentExerciseIndex += 1

            if currentExerciseIndex % 2 == 0 &&
                currentExerciseIndex < dayProgram.exercises.count &&
                currentMentalIndex < dayProgram.mentalComponents.count {
                showingMentalComponent = true
                timeRemaining = dayProgram.mentalComponents[currentMentalIndex].duration
            } else if currentExerciseIndex < dayProgram.exercises.count {
                timeRemaining = dayProgram.exercises[currentExerciseIndex].duration
            } else {
                if currentMentalIndex < dayProgram.mentalComponents.count {
                    showingMentalComponent = true
                    timeRemaining = dayProgram.mentalComponents[currentMentalIndex].duration
                } else {
                    sessionComplete = true
                }
            }
        }
    }
}

// MARK: - Exercise Animation
struct ExerciseAnimation: View {
    let icon: String
    let isPlaying: Bool

    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.6))
                .frame(width: 80, height: 80)
                .shadow(color: Color(red: 0.3, green: 0.6, blue: 0.7).opacity(0.2), radius: 8, x: 0, y: 4)

            Image(systemName: icon)
                .font(.system(size: 36))
                .foregroundColor(Color(red: 0.3, green: 0.6, blue: 0.7))
                .scaleEffect(isAnimating && isPlaying ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
        }
        .onChange(of: isPlaying) { _, newValue in
            isAnimating = newValue
        }
    }
}

// MARK: - Timer Display
struct TimerDisplay: View {
    let timeRemaining: Int
    let isPlaying: Bool

    var minutes: Int { timeRemaining / 60 }
    var seconds: Int { timeRemaining % 60 }

    var body: some View {
        VStack(spacing: 2) {
            Text(String(format: "%d:%02d", minutes, seconds))
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.5))

            Text(isPlaying ? "Time Remaining" : "Ready to Begin")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.6))
        }
    }
}

// MARK: - Breathing Cue
struct BreathingCueView: View {
    let isPlaying: Bool

    @State private var breatheIn = true
    @State private var scale: CGFloat = 1.0
    @State private var breathingTimer: Timer?

    var body: some View {
        VStack(spacing: 16) {
            Text("🫁 Breathing Cue")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.5))

            HStack(spacing: 16) {
                Circle()
                    .fill(Color(red: 0.3, green: 0.6, blue: 0.7).opacity(0.3))
                    .frame(width: 60, height: 60)
                    .scaleEffect(scale)
                    .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: scale)

                Text(breatheIn ? "Breathe In" : "Breathe Out")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 0.3, green: 0.6, blue: 0.7))
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.6))
            )
        }
        .onAppear {
            if isPlaying {
                scale = 1.3
                startBreathingAnimation()
            }
        }
        .onChange(of: isPlaying) { _, newValue in
            if newValue {
                scale = 1.3
                startBreathingAnimation()
            } else {
                scale = 1.0
                stopBreathingAnimation()
            }
        }
        .onDisappear { stopBreathingAnimation() }
    }

    func startBreathingAnimation() {
        breathingTimer?.invalidate()
        breathingTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            breatheIn.toggle()
        }
    }

    func stopBreathingAnimation() {
        breathingTimer?.invalidate()
        breathingTimer = nil
    }
}

// MARK: - Exercise Controls
struct ExerciseControls: View {
    @Binding var isPlaying: Bool
    @Binding var isPaused: Bool
    let onPlay: () -> Void
    let onPause: () -> Void
    let onSkip: () -> Void
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                Button(action: onSkip) {
                    HStack {
                        Image(systemName: "forward.fill")
                        Text("Skip")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 0.3, green: 0.6, blue: 0.7))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color(red: 0.3, green: 0.6, blue: 0.7), lineWidth: 2)
                    )
                }

                Button(action: isPlaying ? onPause : onPlay) {
                    HStack {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        Text(isPlaying ? "Pause" : isPaused ? "Resume" : "Start")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color(red: 0.3, green: 0.6, blue: 0.7))
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 10)
            .padding(.bottom, 10)
        }
        .background(Color.clear)
    }
}

// MARK: - Mental Component View
struct MentalComponentView: View {
    let mentalComponent: MentalComponent
    @Binding var timeRemaining: Int
    @Binding var isPlaying: Bool
    let onComplete: () -> Void

    var typeTitle: String {
        switch mentalComponent.type {
        case .breathing: return "🫁 Breathing Exercise"
        case .affirmation: return "💭 Affirmation"
        case .bodyScan: return "🧘 Body Scan"
        case .reflection: return "✨ Reflection"
        }
    }

    var typeIcon: String {
        switch mentalComponent.type {
        case .breathing: return "wind"
        case .affirmation: return "sparkles"
        case .bodyScan: return "figure.mind.and.body"
        case .reflection: return "brain.head.profile"
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 110, height: 110)

                Image(systemName: typeIcon)
                    .font(.system(size: 50))
                    .foregroundColor(Color(red: 0.3, green: 0.6, blue: 0.7))
            }

            Text(typeTitle)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.5))
                .multilineTextAlignment(.center)

            Text(String(format: "%d:%02d", timeRemaining / 60, timeRemaining % 60))
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.5))

            Text(mentalComponent.guidance)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color(red: 0.3, green: 0.4, blue: 0.5))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
                .padding(18)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.6))
                )
                .padding(.horizontal, 24)

            Spacer()

            HStack(spacing: 20) {
                Button(action: onComplete) {
                    HStack {
                        Image(systemName: "forward.fill")
                        Text("Skip")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 0.3, green: 0.6, blue: 0.7))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color(red: 0.3, green: 0.6, blue: 0.7), lineWidth: 2)
                    )
                }

                Button(action: { isPlaying.toggle() }) {
                    HStack {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        Text(isPlaying ? "Pause" : "Start")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color(red: 0.3, green: 0.6, blue: 0.7))
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Completion View
struct CompletionView: View {
    let dayProgram: DayProgram
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color(red: 0.3, green: 0.6, blue: 0.7).opacity(0.2))
                    .frame(width: 160, height: 160)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(Color(red: 0.3, green: 0.6, blue: 0.7))
            }

            Text("Day \(dayProgram.day) Complete!")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.5))

            Text(dayProgram.completionMessage)
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(Color(red: 0.3, green: 0.4, blue: 0.5))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal, 32)
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.7))
                )
                .padding(.horizontal, 24)

            VStack(spacing: 12) {
                Text("Today's Focus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.6))

                Text(dayProgram.mentalFocus)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(red: 0.3, green: 0.6, blue: 0.7))
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.6))
            )
            .padding(.horizontal, 32)

            Spacer()

            Button(action: { dismiss() }) {
                Text("Done")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        RoundedRectangle(cornerRadius: 27)
                            .fill(Color(red: 0.3, green: 0.6, blue: 0.7))
                    )
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Day Intro View
struct DayIntroView: View {
    let dayProgram: DayProgram
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            // Day badge
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 100, height: 100)
                    .shadow(color: Color(red: 0.3, green: 0.6, blue: 0.7).opacity(0.2), radius: 10, x: 0, y: 5)

                VStack(spacing: 2) {
                    Text("DAY")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(red: 0.3, green: 0.6, blue: 0.7))

                    Text("\(dayProgram.day)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.5))
                }
            }

            // Title and theme
            VStack(spacing: 8) {
                Text(dayProgram.title)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.5))
                    .multilineTextAlignment(.center)

                Text(dayProgram.theme)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 0.3, green: 0.6, blue: 0.7))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.3, green: 0.6, blue: 0.7).opacity(0.1))
                    )
            }

            // Info cards
            VStack(spacing: 12) {
                // Target Areas
                InfoCard(
                    icon: "figure.walk",
                    title: "Target Areas",
                    description: dayProgram.targetAreas
                )

                // Daily Goal
                InfoCard(
                    icon: "target",
                    title: "Today's Goal",
                    description: dayProgram.dailyGoal
                )
            }
            .padding(.horizontal, 24)

            Spacer()

            // Start button
            Button(action: onStart) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Begin Day \(dayProgram.day)")
                }
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color(red: 0.3, green: 0.6, blue: 0.7))
                )
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Info Card
struct InfoCard: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.3, green: 0.6, blue: 0.7).opacity(0.2))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(Color(red: 0.3, green: 0.6, blue: 0.7))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.5))

                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(red: 0.3, green: 0.4, blue: 0.5))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(3)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.7))
        )
    }
}

#Preview {
    if let day1 = ExerciseDatabase.getDay(1) {
        ExercisePlayerView(dayProgram: day1)
    }
}


