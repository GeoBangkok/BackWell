//
//  OnboardingView.swift
//  SkinGlowing
//
//  Complete onboarding flow with multiple screens

import SwiftUI

struct OnboardingView: View {
    @State private var currentStep = 0
    @State private var selectedAge: String = ""
    @State private var skinSensitive: String = ""
    @State private var selectedMotivation: String = ""
    @State private var selectedConcerns: Set<String> = []
    @State private var kBeautyKnowledge: String = ""
    @State private var selectedConditions: Set<String> = []
    @State private var userDataSharingConsent: Bool = false
    @State private var showingSkinScan = false
    @State private var navigateToMainApp = false
    let onComplete: () -> Void
    let totalSteps = 10

    var body: some View {
        NavigationView {
            ZStack {
                // Clean white background
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header with SkinGlowing title and back button
                    ZStack {
                        // Center title - always visible
                        Text("SkinGlowing")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color(hex: "FF91A4"))

                        // Back button (except for welcome and review screens)
                        if currentStep > 0 && currentStep != 9 {
                            HStack {
                                Button(action: {
                                    hapticFeedback(.light)
                                    if currentStep > 0 {
                                        currentStep -= 1
                                    }
                                }) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(Color.black.opacity(0.7))
                                        .frame(width: 44, height: 44)
                                }
                                .padding(.leading, 8)

                                Spacer()
                            }
                        }
                    }
                    .frame(height: 56)
                    .padding(.top, 10)

                    // Content area with tab view - 10 steps total
                    TabView(selection: $currentStep) {
                        WelcomeStep()
                            .tag(0)

                        AgeSelectionStep(selectedAge: $selectedAge)
                            .tag(1)

                        SkinSensitivityStep(skinSensitive: $skinSensitive)
                            .tag(2)

                        MotivationStep(selectedMotivation: $selectedMotivation)
                            .tag(3)

                        SkinConcernsStep(selectedConcerns: $selectedConcerns)
                            .tag(4)

                        KBeautyKnowledgeStep(kBeautyKnowledge: $kBeautyKnowledge)
                            .tag(5)

                        ChronicConditionsStep(selectedConditions: $selectedConditions)
                            .tag(6)

                        PrivacyDisclosureStep(userConsent: $userDataSharingConsent)
                            .tag(7)

                        ReviewRequestStep()
                            .tag(8)

                        AIScanningStep(showingSkinScan: $showingSkinScan)
                            .tag(9)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut, value: currentStep)

                    // Navigation button (except for steps with their own navigation)
                    if currentStep != 4 && currentStep != 6 && currentStep != 7 && currentStep != 8 && currentStep != 9 {
                        Button(action: {
                            hapticFeedback(.light)
                            handleNavigation()
                        }) {
                            Text(buttonText)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    RoundedRectangle(cornerRadius: 28)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(hex: "FF91A4"),
                                                    Color(hex: "FFB6C1")
                                                ]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                                .shadow(color: Color(hex: "FF91A4").opacity(0.25), radius: 15, x: 0, y: 8)
                        }
                        .disabled(isButtonDisabled)
                        .opacity(isButtonDisabled ? 0.6 : 1.0)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 20)
                        .background(
                            Color(UIColor.systemBackground)
                                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: -5)
                        )
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NavigateToAIScanning"))) { _ in
            currentStep = 9
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NavigateToReview"))) { _ in
            currentStep = 8
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NavigateFromConditions"))) { _ in
            currentStep = 7
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NavigateFromPrivacyDisclosure"))) { _ in
            currentStep = 8
        }
        .sheet(isPresented: $showingSkinScan) {
            SkinScanViewWrapper { analysisCompleted in
                // When analysis completes, dismiss sheet and trigger paywall
                showingSkinScan = false
                if analysisCompleted {
                    // Trigger paywall after a small delay for smooth transition
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        onComplete()
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("CompleteOnboarding"))) { _ in
            onComplete()
        }
    }

    var buttonText: String {
        switch currentStep {
        case 0: return "Get Started"
        case 1, 2: return "Continue"
        case 3: return "Next"
        case 5: return "Continue"
        default: return "Next"
        }
    }

    var isButtonDisabled: Bool {
        switch currentStep {
        case 1: return selectedAge.isEmpty
        case 2: return skinSensitive.isEmpty
        case 3: return selectedMotivation.isEmpty
        case 5: return kBeautyKnowledge.isEmpty
        default: return false
        }
    }

    func handleNavigation() {
        if currentStep < totalSteps - 1 {
            currentStep += 1
        } else {
            // Save all data and complete onboarding
            UserDefaults.standard.set(selectedAge, forKey: "userAge")
            UserDefaults.standard.set(skinSensitive, forKey: "skinSensitive")
            UserDefaults.standard.set(selectedMotivation, forKey: "motivation")
            UserDefaults.standard.set(Array(selectedConcerns), forKey: "skinConcerns")
            UserDefaults.standard.set(kBeautyKnowledge, forKey: "kBeautyKnowledge")
            UserDefaults.standard.set(Array(selectedConditions), forKey: "chronicConditions")
            UserDefaults.standard.set(userDataSharingConsent, forKey: "userDataSharingConsent")
            UserDefaults.standard.set(Date(), forKey: "consentDate")
            onComplete()
        }
    }
}

// MARK: - Welcome Step View

struct WelcomeStep: View {
    @State private var animateSmile = false
    @State private var pulseAnimation = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Animated Smiley Face
            ZStack {
                // Soft pink circle background with pulse animation
                Circle()
                    .fill(Color(hex: "FF91A4").opacity(0.1))
                    .frame(width: 180, height: 180)
                    .scaleEffect(pulseAnimation ? 1.05 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true),
                        value: pulseAnimation
                    )

                // White inner circle
                Circle()
                    .fill(Color.white)
                    .frame(width: 160, height: 160)
                    .shadow(color: Color(hex: "FF91A4").opacity(0.15), radius: 20, x: 0, y: 10)

                // Animated smiley face
                VStack(spacing: 0) {
                    // Eyes
                    HStack(spacing: 40) {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 12, height: 12)
                            .offset(y: animateSmile ? -2 : 0)

                        Circle()
                            .fill(Color.black)
                            .frame(width: 12, height: 12)
                            .offset(y: animateSmile ? -2 : 0)
                    }
                    .padding(.bottom, 20)

                    // Smile
                    SmilePath()
                        .stroke(Color.black, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 60, height: 30)
                        .scaleEffect(animateSmile ? 1.1 : 1.0)
                }
                .animation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true),
                    value: animateSmile
                )
            }
            .padding(.bottom, 60)

            // Welcome Text
            VStack(spacing: 12) {
                Text("Hi, I'm Glow!")
                    .font(.system(size: 42, weight: .medium))
                    .foregroundColor(Color.black.opacity(0.85))

                Text("Here to help you boost\nyour skincare results")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(Color.black.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            Spacer()
            Spacer()
        }
        .onAppear {
            animateSmile = true
            pulseAnimation = true
        }
    }
}

// MARK: - Age Selection Step

struct AgeSelectionStep: View {
    @Binding var selectedAge: String
    @State private var animateSmile = false
    @State private var pulseAnimation = false

    let ageRanges = [
        "Under 18",
        "18-24",
        "25-34",
        "35-44",
        "45-54",
        "55+"
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Top spacing - reduced to fit everything
            Spacer()
                .frame(height: 40)

            // Animated Smiley Face (smaller version)
            ZStack {
                Circle()
                    .fill(Color(hex: "FF91A4").opacity(0.1))
                    .frame(width: 120, height: 120)
                    .scaleEffect(pulseAnimation ? 1.05 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true),
                        value: pulseAnimation
                    )

                Circle()
                    .fill(Color.white)
                    .frame(width: 100, height: 100)
                    .shadow(color: Color(hex: "FF91A4").opacity(0.15), radius: 15, x: 0, y: 8)

                VStack(spacing: 0) {
                    HStack(spacing: 25) {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 8, height: 8)
                            .offset(y: animateSmile ? -1 : 0)

                        Circle()
                            .fill(Color.black)
                            .frame(width: 8, height: 8)
                            .offset(y: animateSmile ? -1 : 0)
                    }
                    .padding(.bottom, 12)

                    SmilePath()
                        .stroke(Color.black, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 35, height: 18)
                        .scaleEffect(animateSmile ? 1.1 : 1.0)
                }
                .animation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true),
                    value: animateSmile
                )
            }
            .padding(.bottom, 35)

            // Question Text
            VStack(spacing: 10) {
                Text("How old are you?")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(Color.black.opacity(0.85))

                Text("This helps personalize your skincare recommendations")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color.black.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 40)
            }
            .padding(.bottom, 30)

            // Age Range Options
            VStack(spacing: 8) {
                ForEach(ageRanges, id: \.self) { age in
                    Button(action: {
                        hapticFeedback(.light)
                        selectedAge = age
                    }) {
                        Text(age)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(selectedAge == age ? .white : Color.black.opacity(0.7))
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(
                                RoundedRectangle(cornerRadius: 23)
                                    .fill(
                                        selectedAge == age ?
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(hex: "FF91A4"),
                                                Color(hex: "FFB6C1")
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ) :
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(UIColor.systemGray6),
                                                Color(UIColor.systemGray6)
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 23)
                                    .stroke(
                                        selectedAge == age ? Color.clear : Color(UIColor.systemGray4),
                                        lineWidth: 1
                                    )
                            )
                    }
                }
            }
            .padding(.horizontal, 40)

            Spacer(minLength: 20)
        }
        .onAppear {
            animateSmile = true
            pulseAnimation = true
        }
    }
}

// MARK: - Skin Sensitivity Step

struct SkinSensitivityStep: View {
    @Binding var skinSensitive: String

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Small smiley icon
                ZStack {
                    Circle()
                        .fill(Color(hex: "FF91A4").opacity(0.1))
                        .frame(width: 60, height: 60)

                    Circle()
                        .fill(Color.white)
                        .frame(width: 50, height: 50)

                    VStack(spacing: 0) {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color.black)
                                .frame(width: 4, height: 4)
                            Circle()
                                .fill(Color.black)
                                .frame(width: 4, height: 4)
                        }
                        .padding(.bottom, 6)

                        SmilePath()
                            .stroke(Color.black, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                            .frame(width: 18, height: 9)
                    }
                }

                Text("Would you consider your\nskin sensitive?")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(Color.black.opacity(0.85))
                    .lineSpacing(2)

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 40)
            .padding(.bottom, 50)

            VStack(spacing: 16) {
                // Sensitive option
                Button(action: {
                    hapticFeedback(.light)
                    skinSensitive = "sensitive"
                }) {
                    HStack(spacing: 20) {
                        Image(systemName: "leaf")
                            .font(.system(size: 24))
                            .foregroundColor(Color.black.opacity(0.6))
                            .frame(width: 30)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Sensitive")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color.black.opacity(0.85))

                            Text("My skin has reacted negatively to some skincare in the past.")
                                .font(.system(size: 14))
                                .foregroundColor(Color.black.opacity(0.5))
                                .lineSpacing(2)
                                .multilineTextAlignment(.leading)
                        }

                        Spacer()

                        Circle()
                            .stroke(skinSensitive == "sensitive" ? Color.clear : Color(UIColor.systemGray4), lineWidth: 2)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Circle()
                                    .fill(skinSensitive == "sensitive" ? Color(hex: "FF91A4") : Color.clear)
                                    .frame(width: 24, height: 24)
                            )
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .opacity(skinSensitive == "sensitive" ? 1 : 0)
                            )
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(skinSensitive == "sensitive" ?
                                  Color(hex: "FF91A4").opacity(0.08) :
                                  Color(UIColor.systemGray6))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(skinSensitive == "sensitive" ?
                                    Color(hex: "FF91A4").opacity(0.3) :
                                    Color.clear, lineWidth: 2)
                    )
                }

                // Non-sensitive option
                Button(action: {
                    hapticFeedback(.light)
                    skinSensitive = "non-sensitive"
                }) {
                    HStack(spacing: 20) {
                        Image(systemName: "shield")
                            .font(.system(size: 24))
                            .foregroundColor(Color.black.opacity(0.6))
                            .frame(width: 30)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Non-sensitive")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color.black.opacity(0.85))

                            Text("My skin shows no reaction to certain ingredients.")
                                .font(.system(size: 14))
                                .foregroundColor(Color.black.opacity(0.5))
                                .lineSpacing(2)
                                .multilineTextAlignment(.leading)
                        }

                        Spacer()

                        Circle()
                            .stroke(skinSensitive == "non-sensitive" ? Color.clear : Color(UIColor.systemGray4), lineWidth: 2)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Circle()
                                    .fill(skinSensitive == "non-sensitive" ? Color(hex: "FF91A4") : Color.clear)
                                    .frame(width: 24, height: 24)
                            )
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .opacity(skinSensitive == "non-sensitive" ? 1 : 0)
                            )
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(skinSensitive == "non-sensitive" ?
                                  Color(hex: "FF91A4").opacity(0.08) :
                                  Color(UIColor.systemGray6))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(skinSensitive == "non-sensitive" ?
                                    Color(hex: "FF91A4").opacity(0.3) :
                                    Color.clear, lineWidth: 2)
                    )
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }
}

// MARK: - Motivation Step

struct MotivationStep: View {
    @Binding var selectedMotivation: String
    @State private var animateSmile = false
    @State private var pulseAnimation = false

    let motivations = [
        ("sparkles", "Look younger", "Turn back the clock on aging"),
        ("heart.fill", "Feel confident", "Boost self-esteem and radiance"),
        ("leaf.fill", "Clear skin", "Achieve blemish-free complexion"),
        ("sun.max.fill", "Glow naturally", "Enhance your natural beauty")
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Small smiley icon at top
            ZStack {
                Circle()
                    .fill(Color(hex: "FF91A4").opacity(0.1))
                    .frame(width: 80, height: 80)
                    .scaleEffect(pulseAnimation ? 1.05 : 1.0)

                Circle()
                    .fill(Color.white)
                    .frame(width: 70, height: 70)
                    .shadow(color: Color(hex: "FF91A4").opacity(0.15), radius: 10)

                VStack(spacing: 0) {
                    HStack(spacing: 18) {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 6, height: 6)
                        Circle()
                            .fill(Color.black)
                            .frame(width: 6, height: 6)
                    }
                    .padding(.bottom, 8)

                    SmilePath()
                        .stroke(Color.black, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                        .frame(width: 25, height: 12)
                        .scaleEffect(animateSmile ? 1.1 : 1.0)
                }
            }
            .padding(.top, 30)
            .padding(.bottom, 25)
            .onAppear {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    animateSmile = true
                    pulseAnimation = true
                }
            }

            // Question
            VStack(spacing: 10) {
                Text("What motivates your\nskincare journey?")
                    .font(.system(size: 26, weight: .medium))
                    .foregroundColor(Color.black.opacity(0.85))
                    .multilineTextAlignment(.center)

                Text("Choose your primary goal")
                    .font(.system(size: 15))
                    .foregroundColor(Color.black.opacity(0.5))
            }
            .padding(.bottom, 30)

            // Motivation options
            VStack(spacing: 12) {
                ForEach(motivations, id: \.1) { icon, title, subtitle in
                    Button(action: {
                        hapticFeedback(.light)
                        selectedMotivation = title
                    }) {
                        HStack(spacing: 16) {
                            // Icon
                            ZStack {
                                Circle()
                                    .fill(selectedMotivation == title ?
                                          Color(hex: "FF91A4").opacity(0.15) :
                                          Color(UIColor.systemGray6))
                                    .frame(width: 50, height: 50)

                                Image(systemName: icon)
                                    .font(.system(size: 22))
                                    .foregroundColor(selectedMotivation == title ?
                                                   Color(hex: "FF91A4") :
                                                   Color.black.opacity(0.5))
                            }

                            // Text
                            VStack(alignment: .leading, spacing: 3) {
                                Text(title)
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(Color.black.opacity(0.85))

                                Text(subtitle)
                                    .font(.system(size: 13))
                                    .foregroundColor(Color.black.opacity(0.5))
                            }

                            Spacer()

                            // Radio button
                            Circle()
                                .stroke(selectedMotivation == title ? Color.clear : Color(UIColor.systemGray4), lineWidth: 2)
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Circle()
                                        .fill(selectedMotivation == title ? Color(hex: "FF91A4") : Color.clear)
                                        .frame(width: 24, height: 24)
                                )
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                        .opacity(selectedMotivation == title ? 1 : 0)
                                )
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(selectedMotivation == title ?
                                      Color(hex: "FF91A4").opacity(0.08) :
                                      Color(UIColor.systemGray6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(selectedMotivation == title ?
                                        Color(hex: "FF91A4").opacity(0.3) :
                                        Color.clear, lineWidth: 2)
                        )
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }
}

// MARK: - K-Beauty Knowledge Step

struct KBeautyKnowledgeStep: View {
    @Binding var kBeautyKnowledge: String

    let knowledgeLevels = [
        ("questionmark.circle", "New to K-Beauty", "I'm just starting to explore Korean skincare"),
        ("book.fill", "Some knowledge", "I know the basics and have tried a few products"),
        ("star.fill", "Experienced", "I follow a multi-step routine regularly"),
        ("crown.fill", "Expert", "I'm deeply familiar with ingredients and techniques")
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header with icon
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "FF91A4").opacity(0.1))
                        .frame(width: 60, height: 60)

                    Image(systemName: "sparkles")
                        .font(.system(size: 26))
                        .foregroundColor(Color(hex: "FF91A4"))
                }

                Text("How familiar are you\nwith K-Beauty?")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(Color.black.opacity(0.85))
                    .lineSpacing(2)

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 40)
            .padding(.bottom, 30)

            // Knowledge level options
            VStack(spacing: 12) {
                ForEach(knowledgeLevels, id: \.1) { icon, title, description in
                    Button(action: {
                        hapticFeedback(.light)
                        kBeautyKnowledge = title
                    }) {
                        HStack(spacing: 16) {
                            // Icon
                            ZStack {
                                Circle()
                                    .fill(kBeautyKnowledge == title ?
                                          Color(hex: "FF91A4").opacity(0.15) :
                                          Color(UIColor.systemGray6))
                                    .frame(width: 45, height: 45)

                                Image(systemName: icon)
                                    .font(.system(size: 20))
                                    .foregroundColor(kBeautyKnowledge == title ?
                                                   Color(hex: "FF91A4") :
                                                   Color.black.opacity(0.5))
                            }

                            // Text
                            VStack(alignment: .leading, spacing: 3) {
                                Text(title)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color.black.opacity(0.85))

                                Text(description)
                                    .font(.system(size: 13))
                                    .foregroundColor(Color.black.opacity(0.5))
                                    .lineLimit(2)
                            }

                            Spacer()

                            // Selection indicator
                            Circle()
                                .stroke(kBeautyKnowledge == title ? Color.clear : Color(UIColor.systemGray4), lineWidth: 2)
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Circle()
                                        .fill(kBeautyKnowledge == title ? Color(hex: "FF91A4") : Color.clear)
                                        .frame(width: 24, height: 24)
                                )
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                        .opacity(kBeautyKnowledge == title ? 1 : 0)
                                )
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(kBeautyKnowledge == title ?
                                      Color(hex: "FF91A4").opacity(0.08) :
                                      Color(UIColor.systemGray6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(kBeautyKnowledge == title ?
                                        Color(hex: "FF91A4").opacity(0.3) :
                                        Color.clear, lineWidth: 2)
                        )
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }
}

// MARK: - Skin Concerns Step

struct SkinConcernsStep: View {
    @Binding var selectedConcerns: Set<String>

    let concernsAll = [
        ("heart.fill", "Redness or rosacea"),
        ("star", "Fine lines and wrinkles"),
        ("sun.max.fill", "Pimples or acne"),
        ("circle.fill", "Pigmentation changes"),
        ("square.fill", "Rough texture"),
        ("person.fill", "Double chin"),
        ("eye", "Crow's feet"),
        ("eye.fill", "Puffy eyes"),
        ("triangle.fill", "Textural Irregularities"),
        ("arrow.down", "Sagging Skin"),
        ("drop.fill", "Oiliness"),
        ("cloud.fill", "Dryness"),
        ("moon.fill", "Dark circles")
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 12) {
                // Small smiley icon
                ZStack {
                    Circle()
                        .fill(Color(hex: "FF91A4").opacity(0.1))
                        .frame(width: 60, height: 60)

                    Circle()
                        .fill(Color.white)
                        .frame(width: 50, height: 50)

                    VStack(spacing: 0) {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color.black)
                                .frame(width: 4, height: 4)
                            Circle()
                                .fill(Color.black)
                                .frame(width: 4, height: 4)
                        }
                        .padding(.bottom, 6)

                        SmilePath()
                            .stroke(Color.black, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                            .frame(width: 18, height: 9)
                    }
                }

                Text("What are your additional\nskin concerns?")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(Color.black.opacity(0.85))
                    .lineSpacing(2)

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 30)

            // Scrollable concerns list
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(concernsAll, id: \.1) { icon, concern in
                        Button(action: {
                            hapticFeedback(.light)
                            if selectedConcerns.contains(concern) {
                                selectedConcerns.remove(concern)
                            } else {
                                selectedConcerns.insert(concern)
                            }
                        }) {
                            HStack(spacing: 20) {
                                Image(systemName: icon)
                                    .font(.system(size: 22))
                                    .foregroundColor(Color.black.opacity(0.6))
                                    .frame(width: 30)

                                Text(concern)
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(Color.black.opacity(0.85))

                                Spacer()

                                Circle()
                                    .stroke(selectedConcerns.contains(concern) ? Color.clear : Color(UIColor.systemGray4), lineWidth: 2)
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Circle()
                                            .fill(selectedConcerns.contains(concern) ? Color(hex: "FF91A4") : Color.clear)
                                            .frame(width: 24, height: 24)
                                    )
                                    .overlay(
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                            .opacity(selectedConcerns.contains(concern) ? 1 : 0)
                                    )
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(selectedConcerns.contains(concern) ?
                                          Color(hex: "FF91A4").opacity(0.08) :
                                          Color(UIColor.systemGray6))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(selectedConcerns.contains(concern) ?
                                            Color(hex: "FF91A4").opacity(0.3) :
                                            Color.clear, lineWidth: 2)
                            )
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 100) // Space for Next button
            }

            // Fixed Next button at bottom
            VStack {
                Button(action: {
                    hapticFeedback(.light)
                    // Save concerns and go to AI scanning screen
                    UserDefaults.standard.set(Array(selectedConcerns), forKey: "skinConcerns")
                    // Navigate to AI scanning screen
                    NotificationCenter.default.post(name: NSNotification.Name("NavigateToAIScanning"), object: nil)
                }) {
                    Text("Next")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "FF91A4"),
                                            Color(hex: "FFB6C1")
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .shadow(color: Color(hex: "FF91A4").opacity(0.25), radius: 15, x: 0, y: 8)
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 20)
                .background(
                    Color(UIColor.systemBackground)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: -5)
                )
            }
            .background(Color(UIColor.systemBackground))
        }
    }
}

// MARK: - Chronic Conditions Step

struct ChronicConditionsStep: View {
    @Binding var selectedConditions: Set<String>

    let conditions = [
        ("cross.circle", "None", "I don't have any chronic conditions"),
        ("lungs.fill", "Asthma", "Respiratory condition affecting breathing"),
        ("drop.fill", "Diabetes", "Blood sugar regulation condition"),
        ("heart.fill", "Hypertension", "High blood pressure"),
        ("bolt.heart.fill", "Heart Disease", "Cardiovascular conditions"),
        ("brain", "Neurological", "Conditions affecting nervous system"),
        ("pills.fill", "Autoimmune", "Immune system disorders"),
        ("waveform.path.ecg", "Other", "Other chronic health conditions")
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "FF91A4").opacity(0.1))
                        .frame(width: 60, height: 60)

                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 26))
                        .foregroundColor(Color(hex: "FF91A4"))
                }

                Text("Any chronic conditions\nwe should know about?")
                    .font(.system(size: 23, weight: .medium))
                    .foregroundColor(Color.black.opacity(0.85))
                    .lineSpacing(2)

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 30)
            .padding(.bottom, 15)

            Text("This helps us personalize recommendations safely")
                .font(.system(size: 14))
                .foregroundColor(Color.black.opacity(0.5))
                .padding(.horizontal, 24)
                .padding(.bottom, 25)

            // Conditions list
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(conditions, id: \.1) { icon, condition, description in
                        Button(action: {
                            hapticFeedback(.light)
                            if condition == "None" {
                                // If "None" is selected, clear all other selections
                                selectedConditions.removeAll()
                                selectedConditions.insert(condition)
                            } else {
                                // Remove "None" if selecting other conditions
                                selectedConditions.remove("None")
                                if selectedConditions.contains(condition) {
                                    selectedConditions.remove(condition)
                                } else {
                                    selectedConditions.insert(condition)
                                }
                            }
                        }) {
                            HStack(spacing: 15) {
                                Image(systemName: icon)
                                    .font(.system(size: 20))
                                    .foregroundColor(Color.black.opacity(0.6))
                                    .frame(width: 30)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(condition)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color.black.opacity(0.85))

                                    if condition != "None" {
                                        Text(description)
                                            .font(.system(size: 12))
                                            .foregroundColor(Color.black.opacity(0.5))
                                    }
                                }

                                Spacer()

                                Circle()
                                    .stroke(selectedConditions.contains(condition) ? Color.clear : Color(UIColor.systemGray4), lineWidth: 2)
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Circle()
                                            .fill(selectedConditions.contains(condition) ? Color(hex: "FF91A4") : Color.clear)
                                            .frame(width: 24, height: 24)
                                    )
                                    .overlay(
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                            .opacity(selectedConditions.contains(condition) ? 1 : 0)
                                    )
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(selectedConditions.contains(condition) ?
                                          Color(hex: "FF91A4").opacity(0.08) :
                                          Color(UIColor.systemGray6))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(selectedConditions.contains(condition) ?
                                            Color(hex: "FF91A4").opacity(0.3) :
                                            Color.clear, lineWidth: 2)
                            )
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 100)
            }

            // Next button
            VStack {
                Button(action: {
                    hapticFeedback(.light)
                    // Save conditions
                    UserDefaults.standard.set(Array(selectedConditions), forKey: "chronicConditions")
                    // Navigate to review
                    NotificationCenter.default.post(name: NSNotification.Name("NavigateFromConditions"), object: nil)
                }) {
                    Text("Next")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "FF91A4"),
                                            Color(hex: "FFB6C1")
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .shadow(color: Color(hex: "FF91A4").opacity(0.25), radius: 15, x: 0, y: 8)
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 20)
                .background(
                    Color(UIColor.systemBackground)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: -5)
                )
            }
            .background(Color(UIColor.systemBackground))
        }
    }
}

// MARK: - AI Scanning Step

struct AIScanningStep: View {
    @Binding var showingSkinScan: Bool
    @State private var animateAnalysis = false

    var body: some View {
        VStack(spacing: 0) {
            // Face analysis visual with beauty image
            ZStack {
                // Beauty image or fallback
                Group {
                    if let uiImage = UIImage(named: "beauty") {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        // Fallback gradient placeholder if image doesn't load
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "FFB6C1").opacity(0.3),
                                        Color(hex: "FF91A4").opacity(0.2)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(Color(hex: "FF91A4").opacity(0.5))
                            )
                    }
                }
                .frame(width: 300, height: 350)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        // Analysis overlay dots and connections
                        ZStack {
                            // Animated analysis points
                            ForEach(0..<12, id: \.self) { index in
                                Circle()
                                    .fill(Color.white.opacity(0.8))
                                    .frame(width: 8, height: 8)
                                    .overlay(
                                        Circle()
                                            .stroke(Color(hex: "FF91A4"), lineWidth: 2)
                                            .frame(width: 12, height: 12)
                                    )
                                    .position(
                                        x: CGFloat.random(in: 50...250),
                                        y: CGFloat.random(in: 50...300)
                                    )
                                    .scaleEffect(animateAnalysis ? 1.2 : 0.8)
                                    .opacity(animateAnalysis ? 1 : 0.6)
                                    .animation(
                                        Animation.easeInOut(duration: 2)
                                            .repeatForever(autoreverses: true)
                                            .delay(Double(index) * 0.1),
                                        value: animateAnalysis
                                    )
                            }

                            // Analysis labels
                            VStack {
                                HStack {
                                    // Wrinkles label
                                    HStack(spacing: 6) {
                                        Circle()
                                            .fill(Color(red: 0.4, green: 0.8, blue: 0.4))
                                            .frame(width: 8, height: 8)
                                        Text("Wrinkles")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.black)
                                        Text("Strength")
                                            .font(.system(size: 11))
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.white.opacity(0.95))
                                            .shadow(radius: 5)
                                    )
                                    .offset(x: -80, y: 40)

                                    Spacer()

                                    // Pigmentation label
                                    VStack(alignment: .trailing) {
                                        Text("Pigmentation")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.black)
                                        HStack(spacing: 4) {
                                            Circle()
                                                .fill(Color(hex: "FF91A4"))
                                                .frame(width: 8, height: 8)
                                            Text("Your Focus")
                                                .font(.system(size: 11))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.white.opacity(0.95))
                                            .shadow(radius: 5)
                                    )
                                    .offset(x: 60, y: -30)
                                }

                                Spacer()

                                // Oily label
                                HStack {
                                    Spacer()
                                    VStack(alignment: .leading) {
                                        Text("Oily")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.black)
                                        Text("Your Skin Type")
                                            .font(.system(size: 11))
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.white.opacity(0.95))
                                            .shadow(radius: 5)
                                    )
                                    .offset(x: 40, y: -60)
                                }
                            }
                        }
                    )
            }
            .padding(.top, 30)
            .padding(.bottom, 40)

            // Main text content
            VStack(spacing: 20) {
                Text("Sunshine, let's analyze\nyour skin with our AI\nFace scanner.")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(Color.black.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                Text("You'll also be able to monitor your skin's\nchanges over time.")
                    .font(.system(size: 17))
                    .foregroundColor(Color.black.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)

            // Action buttons
            VStack(spacing: 16) {
                // Make a face scan button
                Button(action: {
                    hapticFeedback(.medium)
                    showingSkinScan = true
                }) {
                    Text("Make a face scan")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "FF91A4"),
                                            Color(hex: "FFB6C1")
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .shadow(color: Color(hex: "FF91A4").opacity(0.25), radius: 15, x: 0, y: 8)
                }

                // Not now button
                Button(action: {
                    hapticFeedback(.light)
                    // Skip to review screen
                    NotificationCenter.default.post(name: NSNotification.Name("NavigateToReview"), object: nil)
                }) {
                    Text("Not now")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(Color.black.opacity(0.5))
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 40)

            Spacer()
        }
        .onAppear {
            animateAnalysis = true
        }
    }
}

// MARK: - Review Request Step

struct ReviewRequestStep: View {
    @State private var showingAppStore = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Phone mockup with notification preview
            ZStack {
                // Phone frame
                RoundedRectangle(cornerRadius: 35)
                    .fill(Color.black)
                    .frame(width: 240, height: 480)
                    .overlay(
                        RoundedRectangle(cornerRadius: 31)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 1.0, green: 0.7, blue: 0.8),
                                        Color(red: 0.6, green: 0.8, blue: 1.0)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .padding(4)
                    )

                // Notification preview
                VStack(spacing: 0) {
                    // Time and date
                    Text("Thu, June 6")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.top, 35)

                    Text("7:12")
                        .font(.system(size: 48, weight: .light))
                        .foregroundColor(.white)
                        .padding(.bottom, 15)

                    // Notification card
                    HStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "FF91A4"),
                                        Color(hex: "FFB6C1")
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Text("⭐ Love SkinGlowing?")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.black.opacity(0.85))
                                Spacer()
                                Text("now")
                                    .font(.system(size: 11))
                                    .foregroundColor(.black.opacity(0.5))
                            }
                            Text("Your review helps others discover their skincare journey!")
                                .font(.system(size: 12))
                                .foregroundColor(.black.opacity(0.7))
                                .lineLimit(2)
                        }
                        .padding(.trailing, 8)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.95))
                    )
                    .padding(.horizontal, 20)

                    Spacer()
                }
            }
            .padding(.bottom, 40)

            // Text content
            VStack(spacing: 16) {
                Text("Enjoying SkinGlowing?")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(Color.black.opacity(0.85))

                Text("We'd love to hear from you!\nYour feedback helps us improve.")
                    .font(.system(size: 18))
                    .foregroundColor(Color.black.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)

            // Buttons
            VStack(spacing: 16) {
                // Rate Us button
                Button(action: {
                    hapticFeedback(.medium)
                    openAppStore()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 18))
                        Text("Rate Us")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "FF91A4"),
                                        Color(hex: "FFB6C1")
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .shadow(color: Color(hex: "FF91A4").opacity(0.25), radius: 15, x: 0, y: 8)
                }

                // Not now button
                Button(action: {
                    hapticFeedback(.light)
                    NotificationCenter.default.post(name: NSNotification.Name("CompleteOnboarding"), object: nil)
                }) {
                    Text("Not now")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(Color.black.opacity(0.5))
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 40)

            Spacer()
        }
    }

    func openAppStore() {
        // Replace with your actual App Store ID
        let appStoreID = "YOUR_APP_STORE_ID"
        let urlString = "https://apps.apple.com/app/id\(appStoreID)?action=write-review"

        if let url = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                // Fallback to main app page if review URL doesn't work
                if let fallbackURL = URL(string: "https://apps.apple.com/app/id\(appStoreID)") {
                    UIApplication.shared.open(fallbackURL)
                }
            }
        }

        // Complete onboarding after opening App Store
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NotificationCenter.default.post(name: NSNotification.Name("CompleteOnboarding"), object: nil)
        }
    }
}

// Custom smile path for the smiley face
struct SmilePath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Create a curved smile
        let startPoint = CGPoint(x: rect.minX + 10, y: rect.midY - 5)
        let endPoint = CGPoint(x: rect.maxX - 10, y: rect.midY - 5)
        let controlPoint1 = CGPoint(x: rect.minX + 15, y: rect.maxY)
        let controlPoint2 = CGPoint(x: rect.maxX - 15, y: rect.maxY)

        path.move(to: startPoint)
        path.addCurve(to: endPoint, control1: controlPoint1, control2: controlPoint2)

        return path
    }
}

// MARK: - SkinScan View Wrapper

struct SkinScanViewWrapper: View {
    let onCompletion: (Bool) -> Void
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var selectedImage: UIImage?
    @State private var isAnalyzing = false
    @State private var analysisProgress: Double = 0
    @State private var showActionSheet = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Cancel") {
                        onCompletion(false)
                    }
                    .foregroundColor(Color(hex: "FF91A4"))

                    Spacer()

                    Text("Skin Analysis")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)

                    Spacer()

                    Button("Cancel") {
                        onCompletion(false)
                    }
                    .foregroundColor(.clear)
                    .disabled(true)
                }
                .padding()
                .background(Color.white)

                if !isAnalyzing {
                    // Photo selection view
                    VStack(spacing: 30) {
                        Spacer()

                        // Preview or placeholder
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 250, height: 250)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color(hex: "FF91A4"), lineWidth: 3)
                                )
                        } else {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(hex: "FFE4E1").opacity(0.3),
                                                Color(hex: "FFB6C1").opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 250, height: 250)

                                VStack(spacing: 12) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(Color(hex: "FF91A4"))

                                    Text("Take or choose a photo")
                                        .font(.system(size: 16))
                                        .foregroundColor(.gray)
                                }
                            }
                        }

                        Spacer()

                        // Action buttons
                        VStack(spacing: 16) {
                            if selectedImage == nil {
                                Button(action: {
                                    showActionSheet = true
                                }) {
                                    HStack {
                                        Image(systemName: "camera.fill")
                                        Text("Select Photo")
                                    }
                                    .font(.system(size: 17, weight: .semibold))
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
                            } else {
                                Button(action: {
                                    startAnalysis()
                                }) {
                                    HStack {
                                        Image(systemName: "wand.and.stars")
                                        Text("Analyze My Skin")
                                    }
                                    .font(.system(size: 17, weight: .semibold))
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

                                Button(action: {
                                    selectedImage = nil
                                }) {
                                    Text("Choose Different Photo")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color(hex: "FF91A4"))
                                }
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.bottom, 30)
                    }
                } else {
                    // Analysis loading view
                    VStack(spacing: 40) {
                        Spacer()

                        // Animated face scanning effect
                        ZStack {
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 200, height: 200)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                LinearGradient(
                                                    colors: [Color(hex: "FF91A4"), Color(hex: "FFB6C1")],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 3
                                            )
                                            .scaleEffect(1.2)
                                            .opacity(0.6)
                                    )
                            }

                            // Scanning animation overlay
                            ForEach(0..<3, id: \.self) { index in
                                Circle()
                                    .stroke(Color(hex: "FF91A4").opacity(0.3), lineWidth: 2)
                                    .scaleEffect(1.0 + Double(index) * 0.3)
                                    .opacity(1.0 - Double(index) * 0.3)
                                    .animation(
                                        Animation.easeOut(duration: 2.0)
                                            .repeatForever(autoreverses: false)
                                            .delay(Double(index) * 0.5),
                                        value: analysisProgress
                                    )
                            }
                        }
                        .frame(width: 200, height: 200)

                        VStack(spacing: 20) {
                            Text("Analyzing your skin...")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.black)

                            // Progress bar
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 10)

                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color(hex: "FF91A4"), Color(hex: "FFB6C1")],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geometry.size.width * analysisProgress, height: 10)
                                        .animation(.linear, value: analysisProgress)
                                }
                            }
                            .frame(height: 10)
                            .padding(.horizontal, 50)

                            Text("This may take a few seconds")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }

                        Spacer()
                    }
                }
            }
            .background(Color.white)
        }
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(
                title: Text("Select Photo"),
                message: Text("Choose how you'd like to provide your photo"),
                buttons: [
                    .default(Text("Take Photo")) {
                        showCamera = true
                    },
                    .default(Text("Choose from Library")) {
                        showImagePicker = true
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(selectedImage: $selectedImage, sourceType: .camera)
        }
    }

    private func startAnalysis() {
        isAnalyzing = true
        analysisProgress = 0

        // Simulate analysis progress
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            analysisProgress += 0.033

            if analysisProgress >= 1.0 {
                timer.invalidate()
                // Complete analysis and trigger paywall
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onCompletion(true)
                }
            }
        }
    }
}

// MARK: - Image Picker

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    let sourceType: UIImagePickerController.SourceType

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    OnboardingView(onComplete: {})
}