//
//  OnboardingView.swift
//  BackWell
//
//  Created by standard on 1/17/26.
//

import SwiftUI

// Condition facts and solutions
struct ConditionInfo {
    let fact: String
    let solution: String
}

let conditionFacts: [String: ConditionInfo] = [
    "Herniated Disc": ConditionInfo(
        fact: "A herniated disc occurs when the soft center pushes through a crack in the outer ring.",
        solution: "Targeted exercises can strengthen your core muscles, reducing pressure on the disc and alleviating pain over time."
    ),
    "Sciatica": ConditionInfo(
        fact: "Sciatica affects the sciatic nerve, causing pain that radiates from your lower back down your leg.",
        solution: "Gentle stretching and strengthening exercises can reduce nerve compression and provide significant relief within weeks."
    ),
    "Scoliosis": ConditionInfo(
        fact: "Scoliosis causes an abnormal sideways curvature of the spine.",
        solution: "Specific postural exercises and stretches can help reduce discomfort and improve spinal alignment over time."
    ),
    "Degenerative Disc Disease": ConditionInfo(
        fact: "This condition occurs when spinal discs break down with age, causing pain and stiffness.",
        solution: "Low-impact strengthening exercises can stabilize your spine and reduce pain by supporting the affected discs."
    ),
    "Spinal Stenosis": ConditionInfo(
        fact: "Spinal stenosis is a narrowing of spaces in your spine, putting pressure on nerves.",
        solution: "Flexion-based exercises can help open up the spinal canal and relieve pressure on compressed nerves."
    ),
    "Muscle Strain": ConditionInfo(
        fact: "Muscle strains happen when fibers are overstretched or torn, causing pain and limited mobility.",
        solution: "Progressive strengthening and flexibility exercises can heal the strain while preventing future injuries."
    ),
    "Arthritis": ConditionInfo(
        fact: "Spinal arthritis causes inflammation and stiffness in the joints of your back.",
        solution: "Regular gentle movement and targeted exercises can reduce inflammation and maintain joint flexibility."
    ),
    "Pinched Nerve": ConditionInfo(
        fact: "A pinched nerve occurs when too much pressure is applied to a nerve by surrounding tissues.",
        solution: "Decompression exercises and proper posture training can relieve the pressure and restore normal nerve function."
    ),
    "Poor Posture": ConditionInfo(
        fact: "Poor posture puts unnecessary strain on your spine and surrounding muscles.",
        solution: "Postural awareness exercises and core strengthening can retrain your body to maintain proper alignment naturally."
    )
]

struct OnboardingView: View {
    @State private var currentStep = 0
    @State private var painLevel = 5.0
    @State private var selectedAreas: Set<String> = []
    @State private var selectedConditions: Set<String> = []
    @State private var selectedGoal = ""
    let onContinue: () -> Void

    var hasValidConditions: Bool {
        !selectedConditions.isEmpty &&
        !(selectedConditions.count == 1 && selectedConditions.contains("Not Diagnosed"))
    }

    var totalSteps: Int {
        hasValidConditions ? 6 : 5
    }

    var body: some View {
        ZStack {
            Theme.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress indicator
                HStack(spacing: 8) {
                    ForEach(0..<totalSteps, id: \.self) { step in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(step <= currentStep ? Theme.teal : Color.gray.opacity(0.3))
                            .frame(height: 3)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.top, 60)
                .padding(.bottom, 40)

                // Content area
                TabView(selection: $currentStep) {
                    // Step 1: Welcome & Problem
                    WelcomeStep()
                        .tag(0)

                    // Step 2: Pain Assessment
                    PainAssessmentStep(painLevel: $painLevel, selectedAreas: $selectedAreas)
                        .tag(1)

                    // Step 3: Diagnosis & Conditions
                    DiagnosisStep(selectedConditions: $selectedConditions)
                        .tag(2)

                    // Step 4: Acknowledgment (conditional)
                    if hasValidConditions {
                        AcknowledgmentStep(selectedConditions: selectedConditions)
                            .tag(3)
                    }

                    // Step 5: Solution Pitch
                    SolutionStep()
                        .tag(hasValidConditions ? 4 : 3)

                    // Step 6: 28-Day Challenge
                    ChallengeStep()
                        .tag(hasValidConditions ? 5 : 4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Navigation buttons
                HStack(spacing: 16) {
                    if currentStep > 0 {
                        Button(action: {
                            withAnimation {
                                currentStep -= 1
                            }
                        }) {
                            Text("Back")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Theme.teal)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Theme.teal, lineWidth: 2)
                                )
                        }
                    }

                    Button(action: {
                        withAnimation {
                            if currentStep < totalSteps - 1 {
                                currentStep += 1
                            } else {
                                // Move to paywall
                                onContinue()
                            }
                        }
                    }) {
                        Text(currentStep == totalSteps - 1 ? "Start My Journey" : "Continue")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Theme.buttonGradient)
                            )
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
        }
    }
}

// MARK: - Step 1: Welcome
struct WelcomeStep: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("You're Not Alone")
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(Theme.textPrimary)
                .multilineTextAlignment(.center)

            Text("80% of adults experience back pain at some point in their lives.")
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            VStack(alignment: .leading, spacing: 16) {
                FeatureBullet(text: "Hundreds of expert-designed exercises")
                FeatureBullet(text: "Personalized relief routes for your pain")
                FeatureBullet(text: "Just 10-15 minutes a day")
            }
            .padding(.top, 32)

            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Step 2: Pain Assessment
struct PainAssessmentStep: View {
    @Binding var painLevel: Double
    @Binding var selectedAreas: Set<String>

    let painAreas = ["Lower Back", "Upper Back", "Neck", "Shoulders"]

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Let's Understand Your Pain")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(Theme.textPrimary)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 12) {
                Text("Current pain level")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Theme.textSecondary)

                HStack {
                    Text("Mild")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.textMuted)

                    Slider(value: $painLevel, in: 1...10, step: 1)
                        .accentColor(Theme.teal)

                    Text("Severe")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.textMuted)
                }

                Text("\(Int(painLevel))/10")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Theme.teal)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            VStack(alignment: .leading, spacing: 12) {
                Text("Where does it hurt?")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Theme.textSecondary)
                    .padding(.horizontal, 24)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(painAreas, id: \.self) { area in
                        Button(action: {
                            if selectedAreas.contains(area) {
                                selectedAreas.remove(area)
                            } else {
                                selectedAreas.insert(area)
                            }
                        }) {
                            Text(area)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(selectedAreas.contains(area) ? .white : Theme.teal)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectedAreas.contains(area) ?
                                              Theme.teal :
                                              Theme.teal.opacity(0.1))
                                )
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.top, 20)

            Spacer()
        }
    }
}

// MARK: - Step 3: Diagnosis & Conditions
struct DiagnosisStep: View {
    @Binding var selectedConditions: Set<String>

    let conditions = [
        "Herniated Disc",
        "Sciatica",
        "Scoliosis",
        "Degenerative Disc Disease",
        "Spinal Stenosis",
        "Muscle Strain",
        "Arthritis",
        "Pinched Nerve",
        "Poor Posture",
        "Not Diagnosed"
    ]

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Any Existing Conditions?")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(Theme.textPrimary)
                .multilineTextAlignment(.center)

            Text("Have you been diagnosed with, or do you suspect you have any of the following?")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Text("Select all that apply")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Theme.textMuted)
                .padding(.top, 8)

            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(conditions, id: \.self) { condition in
                        Button(action: {
                            if selectedConditions.contains(condition) {
                                selectedConditions.remove(condition)
                            } else {
                                selectedConditions.insert(condition)
                            }
                        }) {
                            HStack {
                                Text(condition)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(selectedConditions.contains(condition) ? .white : Theme.teal)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)

                                Spacer()

                                if selectedConditions.contains(condition) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 16))
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedConditions.contains(condition) ?
                                          Theme.teal :
                                          Theme.teal.opacity(0.1))
                            )
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.top, 12)

            Spacer()
        }
    }
}

// MARK: - Step 4: Acknowledgment (Conditional)
struct AcknowledgmentStep: View {
    let selectedConditions: Set<String>

    var conditionsList: String {
        let validConditions = selectedConditions.filter { $0 != "Not Diagnosed" }
        if validConditions.count == 1 {
            return validConditions.first ?? ""
        } else if validConditions.count == 2 {
            return validConditions.joined(separator: " and ")
        } else {
            let sortedConditions = Array(validConditions).sorted()
            let lastCondition = sortedConditions.last ?? ""
            let otherConditions = sortedConditions.dropLast().joined(separator: ", ")
            return "\(otherConditions), and \(lastCondition)"
        }
    }

    var primaryCondition: String? {
        selectedConditions.filter { $0 != "Not Diagnosed" }.first
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("We Understand")
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(Theme.textPrimary)
                .multilineTextAlignment(.center)

            if !conditionsList.isEmpty {
                Text("A lot of our users also report issues with \(conditionsList).")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Text("We will help you get relief from this.")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Theme.teal)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
            }

            // Condition fact card
            if let condition = primaryCondition,
               let info = conditionFacts[condition] {
                VStack(spacing: 16) {
                    // Divider
                    Rectangle()
                        .fill(Theme.teal.opacity(0.3))
                        .frame(height: 1)
                        .padding(.horizontal, 32)
                        .padding(.top, 16)

                    // Condition name
                    Text(condition)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Theme.textPrimary)
                        .padding(.top, 8)

                    // Fact
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(Theme.teal)
                                .font(.system(size: 20))

                            Text(info.fact)
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(Theme.textSecondary)
                        }

                        // Solution
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "checkmark.shield.fill")
                                .foregroundColor(Theme.teal)
                                .font(.system(size: 20))

                            Text(info.solution)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(Theme.teal)
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.7))
                    )
                    .padding(.horizontal, 24)
                }
                .padding(.top, 12)
            }

            Spacer()
        }
    }
}

// MARK: - Step 5: Solution
struct SolutionStep: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Here's What Changes")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Theme.textPrimary)
                .multilineTextAlignment(.center)

            Text("BackWell isn't just another exercise app.\nIt's your personalized path to relief.")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            VStack(spacing: 20) {
                ResultCard(
                    icon: "figure.strengthtraining.traditional",
                    title: "Hundreds of Exercises",
                    description: "Clinically-proven movements designed by physical therapists"
                )

                ResultCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Custom Relief Routes",
                    description: "Personalized plans that adapt to your progress and pain"
                )

                ResultCard(
                    icon: "calendar.badge.checkmark",
                    title: "Build the Habit",
                    description: "Consistency is key. We make it easy to stick with it"
                )
            }
            .padding(.top, 20)

            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Step 6: 28-Day Challenge
struct ChallengeStep: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 12) {
                Text("28")
                    .font(.system(size: 72, weight: .bold))
                    .foregroundColor(Theme.teal)

                Text("DAY CHALLENGE")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Theme.teal)
                    .tracking(2)
            }

            Text("Start with our proven 28-day challenge")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            VStack(alignment: .leading, spacing: 16) {
                ChallengeFeature(
                    day: "Days 1-7",
                    title: "Foundation",
                    description: "Learn the basics, reduce acute pain"
                )

                ChallengeFeature(
                    day: "Days 8-14",
                    title: "Strengthen",
                    description: "Build core strength, improve posture"
                )

                ChallengeFeature(
                    day: "Days 15-21",
                    title: "Mobilize",
                    description: "Increase flexibility and range of motion"
                )

                ChallengeFeature(
                    day: "Days 22-28",
                    title: "Sustain",
                    description: "Lock in your progress, prevent future pain"
                )
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            Text("After 28 days, you'll have hundreds more exercises and routes to explore.")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Theme.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.top, 16)

            Spacer()
        }
    }
}

// MARK: - Supporting Views
struct FeatureBullet: View {
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Theme.teal)
                .font(.system(size: 20))

            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Theme.textSecondary)
        }
    }
}

struct ResultCard: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(Theme.teal)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(Theme.teal.opacity(0.1))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)

                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Theme.textMuted)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.6))
        )
    }
}

struct ChallengeFeature: View {
    let day: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 4) {
                Text(day)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Theme.teal)
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)

                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Theme.textMuted)
            }

            Spacer()
        }
    }
}

#Preview {
    OnboardingView(onContinue: {})
}
