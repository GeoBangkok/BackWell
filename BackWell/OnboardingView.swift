//
//  OnboardingView.swift
//  SkinGlowing
//
//  AI-powered skincare analysis onboarding flow - iOS Health style

import SwiftUI
import PhotosUI
import UIKit

struct OnboardingView: View {
    @State private var currentStep = 0
    @State private var selectedConcerns: Set<String> = []
    @State private var selectedGoals: Set<String> = []
    @State private var selectedRace = ""
    @State private var selectedSkinType = ""
    @State private var selectedCosmetics: Set<String> = []
    @State private var uploadedImage: UIImage?
    @State private var showingPhotoPicker = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isAnalyzing = false
    @State private var analysisProgress: Double = 0
    @State private var showBlurredScore = false
    @State private var currentAnalysisMessage = ""
    @State private var skinScore: Int = 0

    let onComplete: () -> Void
    let totalSteps = 8

    // Scientific analysis messages
    let analysisMessages = [
        "Analyzing melanin distribution patterns...",
        "Measuring skin texture uniformity...",
        "Detecting sebaceous gland activity...",
        "Evaluating collagen density markers...",
        "Processing epidermal thickness data...",
        "Calculating hydration gradient levels...",
        "Examining vascular network patterns...",
        "Quantifying elastin fiber alignment...",
        "Assessing keratinocyte turnover rate...",
        "Finalizing dermatological analysis..."
    ]

    var body: some View {
        NavigationView {
            ZStack {
                // Clean white background
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // iOS Health-style header
                    VStack(spacing: 8) {
                        // Progress indicator
                        HStack(spacing: 6) {
                            ForEach(0..<totalSteps, id: \.self) { index in
                                Circle()
                                    .fill(index <= currentStep ? Color(hex: "FF91A4") : Color(UIColor.systemGray5))
                                    .frame(width: 8, height: 8)
                                    .animation(.easeInOut(duration: 0.3), value: currentStep)
                            }
                        }
                        .padding(.top, 16)

                        // Step title
                        Text(stepTitle)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color(UIColor.label))
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)

                    // Content area with tab view
                    TabView(selection: $currentStep) {
                        WelcomeStep()
                            .tag(0)

                        SkinConcernsStep(selectedConcerns: $selectedConcerns)
                            .tag(1)

                        SkinGoalsStep(selectedGoals: $selectedGoals)
                            .tag(2)

                        RaceEthnicityStep(selectedRace: $selectedRace)
                            .tag(3)

                        SkinTypeStep(selectedSkinType: $selectedSkinType)
                            .tag(4)

                        CosmeticsStep(selectedCosmetics: $selectedCosmetics)
                            .tag(5)

                        PhotoUploadStep(
                            uploadedImage: $uploadedImage,
                            showingPhotoPicker: $showingPhotoPicker,
                            selectedPhoto: $selectedPhoto
                        )
                        .tag(6)

                        AnalysisStep(
                            isAnalyzing: $isAnalyzing,
                            analysisProgress: $analysisProgress,
                            showBlurredScore: $showBlurredScore,
                            uploadedImage: uploadedImage,
                            currentAnalysisMessage: $currentAnalysisMessage,
                            analysisMessages: analysisMessages,
                            skinScore: $skinScore,
                            onComplete: onComplete
                        )
                        .tag(7)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut, value: currentStep)

                    // Navigation buttons
                    HStack(spacing: 16) {
                        if currentStep > 0 && currentStep < 7 {
                            Button(action: {
                                hapticFeedback(.light)
                                currentStep -= 1
                            }) {
                                HStack {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Back")
                                        .font(.system(size: 17, weight: .medium))
                                }
                                .foregroundColor(Color(hex: "FF91A4"))
                                .frame(width: 110, height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color(UIColor.systemGray6))
                                )
                            }
                        }

                        Spacer()

                        if currentStep < 7 {
                            Button(action: handleNextButton) {
                                HStack {
                                    Text(nextButtonText)
                                        .font(.system(size: 17, weight: .semibold))
                                    if currentStep < 6 {
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                }
                                .foregroundColor(.white)
                                .frame(width: currentStep == 6 ? 140 : 110, height: 50)
                                .background(
                                    LinearGradient(
                                        colors: [Color(hex: "FF91A4"), Color(hex: "FFB6C1")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 25))
                                .shadow(color: Color(hex: "FF91A4").opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .disabled(!canProceed)
                            .opacity(canProceed ? 1.0 : 0.6)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                    .background(
                        Color(UIColor.systemBackground)
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: -5)
                    )
                }
            }
            .navigationBarHidden(true)
        }
        .photosPicker(
            isPresented: $showingPhotoPicker,
            selection: $selectedPhoto,
            matching: .images,
            photoLibrary: .shared()
        )
        .onChange(of: selectedPhoto) { newValue in
            Task { @MainActor in
                if let data = try? await newValue?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    uploadedImage = image
                }
            }
        }
    }

    var stepTitle: String {
        switch currentStep {
        case 0: return "Welcome"
        case 1: return "Skin Concerns"
        case 2: return "Your Goals"
        case 3: return "About You"
        case 4: return "Skin Type"
        case 5: return "Products"
        case 6: return "Photo Analysis"
        case 7: return "Analyzing"
        default: return ""
        }
    }

    var nextButtonText: String {
        switch currentStep {
        case 0: return "Start"
        case 6: return "Analyze"
        default: return "Next"
        }
    }

    var canProceed: Bool {
        switch currentStep {
        case 1: return !selectedConcerns.isEmpty
        case 2: return !selectedGoals.isEmpty
        case 3: return !selectedRace.isEmpty
        case 4: return !selectedSkinType.isEmpty
        case 6: return uploadedImage != nil
        default: return true
        }
    }

    private func handleNextButton() {
        hapticFeedback(.light)

        if currentStep == 6 {
            // Start analysis
            currentStep = 7
            startAnalysis()
        } else {
            currentStep += 1
        }
    }

    private func startAnalysis() {
        isAnalyzing = true
        analysisProgress = 0
        var messageIndex = 0

        // Simulate analysis with rotating messages
        Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { timer in
            withAnimation {
                if analysisProgress < 1.0 {
                    analysisProgress += 0.1
                    currentAnalysisMessage = analysisMessages[messageIndex]
                    messageIndex = (messageIndex + 1) % analysisMessages.count
                } else {
                    timer.invalidate()
                    isAnalyzing = false
                    showBlurredScore = true
                    skinScore = Int.random(in: 75...95)
                }
            }
        }
    }
}

// MARK: - Step Views

struct WelcomeStep: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "camera.metering.multispot")
                .font(.system(size: 80))
                .foregroundColor(Color(hex: "FF91A4"))

            VStack(spacing: 16) {
                Text("Advanced Skin Analysis")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(Color(UIColor.label))

                Text("We'll analyze your skin using AI technology to provide personalized recommendations")
                    .font(.system(size: 17))
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()
        }
    }
}

struct SkinConcernsStep: View {
    @Binding var selectedConcerns: Set<String>

    let concerns = [
        ("drop.fill", "Dryness"),
        ("sun.max.fill", "Sun Damage"),
        ("circle.dotted", "Acne"),
        ("sparkles", "Dark Spots"),
        ("wind", "Fine Lines"),
        ("eye", "Dark Circles"),
        ("oval.portrait", "Large Pores"),
        ("waveform.path.ecg", "Redness"),
        ("leaf.fill", "Sensitivity")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("What are your main skin concerns?")
                    .font(.system(size: 18))
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .padding(.top, 20)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(concerns, id: \.1) { icon, concern in
                        SelectableCard(
                            icon: icon,
                            title: concern,
                            isSelected: selectedConcerns.contains(concern),
                            action: {
                                hapticFeedback(.light)
                                if selectedConcerns.contains(concern) {
                                    selectedConcerns.remove(concern)
                                } else {
                                    selectedConcerns.insert(concern)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct SkinGoalsStep: View {
    @Binding var selectedGoals: Set<String>

    let goals = [
        ("sparkle", "Glow"),
        ("drop.circle", "Hydration"),
        ("shield.lefthalf.filled", "Protection"),
        ("arrow.down.circle", "Anti-Aging"),
        ("circle.hexagongrid", "Even Tone"),
        ("leaf.circle", "Natural"),
        ("moon.fill", "Overnight Repair"),
        ("sun.min", "Oil Control")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("What are your skincare goals?")
                    .font(.system(size: 18))
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .padding(.top, 20)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(goals, id: \.1) { icon, goal in
                        SelectableCard(
                            icon: icon,
                            title: goal,
                            isSelected: selectedGoals.contains(goal),
                            action: {
                                hapticFeedback(.light)
                                if selectedGoals.contains(goal) {
                                    selectedGoals.remove(goal)
                                } else {
                                    selectedGoals.insert(goal)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct RaceEthnicityStep: View {
    @Binding var selectedRace: String

    let options = [
        "Asian", "Black", "Hispanic/Latino",
        "Middle Eastern", "White", "Mixed", "Other"
    ]

    var body: some View {
        VStack(spacing: 24) {
            Text("Select your ethnicity")
                .font(.system(size: 18))
                .foregroundColor(Color(UIColor.secondaryLabel))
                .padding(.top, 20)

            Text("This helps us provide more accurate skin analysis")
                .font(.system(size: 15))
                .foregroundColor(Color(UIColor.tertiaryLabel))

            VStack(spacing: 10) {
                ForEach(options, id: \.self) { option in
                    OptionRow(
                        title: option,
                        isSelected: selectedRace == option,
                        action: {
                            hapticFeedback(.light)
                            selectedRace = option
                        }
                    )
                }
            }
            .padding(.horizontal, 20)

            Spacer()
        }
    }
}

struct SkinTypeStep: View {
    @Binding var selectedSkinType: String

    let skinTypes = [
        ("Dry", "Feels tight, may have flaking"),
        ("Oily", "Shiny, especially T-zone"),
        ("Combination", "Oily T-zone, dry cheeks"),
        ("Normal", "Balanced, few concerns"),
        ("Sensitive", "Easily irritated or red")
    ]

    var body: some View {
        VStack(spacing: 24) {
            Text("What's your skin type?")
                .font(.system(size: 18))
                .foregroundColor(Color(UIColor.secondaryLabel))
                .padding(.top, 20)

            VStack(spacing: 12) {
                ForEach(skinTypes, id: \.0) { type, description in
                    DetailedOptionRow(
                        title: type,
                        subtitle: description,
                        isSelected: selectedSkinType == type,
                        action: {
                            hapticFeedback(.light)
                            selectedSkinType = type
                        }
                    )
                }
            }
            .padding(.horizontal, 20)

            Spacer()
        }
    }
}

struct CosmeticsStep: View {
    @Binding var selectedCosmetics: Set<String>

    let brands = [
        "The Ordinary", "CeraVe", "La Roche-Posay", "Cetaphil",
        "Neutrogena", "Olay", "L'Oreal", "SK-II", "Clinique",
        "Estée Lauder", "Drunk Elephant", "Sunday Riley"
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Select brands you use or prefer")
                    .font(.system(size: 18))
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .padding(.top, 20)

                Text("Optional - helps personalize recommendations")
                    .font(.system(size: 15))
                    .foregroundColor(Color(UIColor.tertiaryLabel))

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(brands, id: \.self) { brand in
                        BrandChip(
                            title: brand,
                            isSelected: selectedCosmetics.contains(brand),
                            action: {
                                hapticFeedback(.light)
                                if selectedCosmetics.contains(brand) {
                                    selectedCosmetics.remove(brand)
                                } else {
                                    selectedCosmetics.insert(brand)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct PhotoUploadStep: View {
    @Binding var uploadedImage: UIImage?
    @Binding var showingPhotoPicker: Bool
    @Binding var selectedPhoto: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 28) {
            Text("Upload your photo")
                .font(.system(size: 18))
                .foregroundColor(Color(UIColor.secondaryLabel))
                .padding(.top, 20)

            // Photo requirements
            VStack(alignment: .leading, spacing: 12) {
                RequirementRow(icon: "face.smiling", text: "No makeup or filters")
                RequirementRow(icon: "sun.max", text: "Good natural lighting")
                RequirementRow(icon: "camera.aperture", text: "Clear, front-facing photo")
                RequirementRow(icon: "clock", text: "Recent photo preferred")
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.systemGray6))
            )
            .padding(.horizontal, 20)

            // Photo upload area
            if let image = uploadedImage {
                VStack(spacing: 16) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color(hex: "FF91A4"), lineWidth: 3)
                        )
                        .shadow(color: Color(hex: "FF91A4").opacity(0.3), radius: 10, x: 0, y: 5)

                    Button(action: {
                        hapticFeedback(.light)
                        uploadedImage = nil
                        selectedPhoto = nil
                    }) {
                        Text("Change Photo")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "FF91A4"))
                    }
                }
            } else {
                Button(action: {
                    hapticFeedback(.light)
                    showingPhotoPicker = true
                }) {
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(Color(UIColor.systemGray6))
                                .frame(width: 140, height: 140)

                            Image(systemName: "camera.fill")
                                .font(.system(size: 50))
                                .foregroundColor(Color(hex: "FF91A4"))
                        }

                        Text("Tap to select photo")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(Color(hex: "FF91A4"))
                    }
                }
            }

            Spacer()
        }
    }
}

struct AnalysisStep: View {
    @Binding var isAnalyzing: Bool
    @Binding var analysisProgress: Double
    @Binding var showBlurredScore: Bool
    let uploadedImage: UIImage?
    @Binding var currentAnalysisMessage: String
    let analysisMessages: [String]
    @Binding var skinScore: Int
    let onComplete: () -> Void

    @State private var scoreRevealed = false
    @State private var blurAmount: Double = 20

    var body: some View {
        VStack(spacing: 32) {
            if isAnalyzing {
                // Loading state with scientific messages
                VStack(spacing: 24) {
                    Spacer()

                    // Animated scanner effect
                    ZStack {
                        if let image = uploadedImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 150, height: 150)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                colors: [Color(hex: "FF91A4"), Color(hex: "FFB6C1")],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            ),
                                            lineWidth: 3
                                        )
                                        .rotationEffect(.degrees(analysisProgress * 360))
                                        .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: analysisProgress)
                                )
                        }
                    }

                    VStack(spacing: 16) {
                        Text("Analyzing Your Skin")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(Color(UIColor.label))

                        Text(currentAnalysisMessage)
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "FF91A4"))
                            .multilineTextAlignment(.center)
                            .frame(height: 20)
                            .animation(.easeInOut(duration: 0.3), value: currentAnalysisMessage)
                    }

                    // Progress bar
                    ProgressView(value: analysisProgress)
                        .tint(Color(hex: "FF91A4"))
                        .scaleEffect(x: 1, y: 2)
                        .padding(.horizontal, 60)

                    Spacer()
                }
            } else if showBlurredScore {
                // Blurred score reveal
                VStack(spacing: 32) {
                    Spacer()

                    Text("Your Skin Analysis is Ready")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(Color(UIColor.label))

                    // Blurred score
                    ZStack {
                        VStack(spacing: 16) {
                            Text("\(skinScore)")
                                .font(.system(size: 72, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "FF91A4"))

                            Text("Skin Score")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(Color(UIColor.secondaryLabel))

                            HStack(spacing: 4) {
                                ForEach(0..<5) { index in
                                    Image(systemName: index < Int(Double(skinScore) / 20.0) ? "star.fill" : "star")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(hex: "FFB6C1"))
                                }
                            }
                        }
                        .blur(radius: blurAmount)

                        if !scoreRevealed {
                            VStack(spacing: 16) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(Color(hex: "FF91A4"))

                                Text("Tap to reveal your score")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(Color(UIColor.secondaryLabel))
                            }
                        }
                    }
                    .frame(width: 280, height: 200)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(UIColor.systemGray6))
                    )
                    .onTapGesture {
                        if !scoreRevealed {
                            hapticFeedback(.medium)
                            withAnimation(.easeOut(duration: 0.5)) {
                                blurAmount = 0
                                scoreRevealed = true
                            }

                            // Navigate to main app after reveal
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                onComplete()
                            }
                        }
                    }

                    Spacer()
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct SelectableCard: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(isSelected ? .white : Color(hex: "FF91A4"))

                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(isSelected ? .white : Color(UIColor.label))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ?
                          LinearGradient(colors: [Color(hex: "FF91A4"), Color(hex: "FFB6C1")],
                                       startPoint: .topLeading, endPoint: .bottomTrailing) :
                          LinearGradient(colors: [Color(UIColor.systemGray6), Color(UIColor.systemGray6)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.clear : Color(UIColor.systemGray5), lineWidth: 1)
            )
        }
    }
}

struct OptionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 17))
                    .foregroundColor(Color(UIColor.label))

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? Color(hex: "FF91A4") : Color(UIColor.systemGray3))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color(hex: "FF91A4") : Color.clear, lineWidth: 2)
                    )
            )
        }
    }
}

struct DetailedOptionRow: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(Color(UIColor.label))

                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(Color(UIColor.secondaryLabel))
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? Color(hex: "FF91A4") : Color(UIColor.systemGray3))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color(hex: "FF91A4") : Color.clear, lineWidth: 2)
                    )
            )
        }
    }
}

struct BrandChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(isSelected ? .white : Color(UIColor.label))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ?
                              Color(hex: "FF91A4") :
                              Color(UIColor.systemGray6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color(UIColor.systemGray5), lineWidth: 1)
                )
        }
    }
}

struct RequirementRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color(hex: "FF91A4"))
                .frame(width: 24)

            Text(text)
                .font(.system(size: 15))
                .foregroundColor(Color(UIColor.label))

            Spacer()
        }
    }
}

// MARK: - Haptic Feedback

func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
    let generator = UIImpactFeedbackGenerator(style: style)
    generator.prepare()
    generator.impactOccurred()
}

#Preview {
    OnboardingView(onComplete: {})
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