//
//  OnboardingView.swift
//  SkinGlowing
//
//  AI-powered skincare analysis onboarding flow
//

import SwiftUI
import PhotosUI

struct OnboardingView: View {
    @State private var currentStep = 0
    @State private var selectedConcerns: Set<String> = []
    @State private var selectedGoals: Set<String> = []
    @State private var selectedRace = ""
    @State private var selectedSkinType = ""
    @State private var selectedCosmetics: Set<String> = []
    @State private var uploadedImages: [UIImage] = []
    @State private var showingPhotoPicker = false
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var isAnalyzing = false
    @State private var analysisProgress: Double = 0
    @State private var showBlurredScore = false

    let totalSteps = 8

    var body: some View {
        ZStack {
            // Background gradient
            Theme.onboardingBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar
                ProgressView(value: Double(currentStep + 1), total: Double(totalSteps))
                    .tint(Theme.purple)
                    .scaleEffect(x: 1, y: 2)
                    .padding(.horizontal)
                    .padding(.top, 60)

                // Content area
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
                        uploadedImages: $uploadedImages,
                        showingPhotoPicker: $showingPhotoPicker,
                        selectedPhotos: $selectedPhotos
                    )
                    .tag(6)

                    AnalysisStep(
                        isAnalyzing: $isAnalyzing,
                        analysisProgress: $analysisProgress,
                        showBlurredScore: $showBlurredScore,
                        uploadedImages: uploadedImages
                    )
                    .tag(7)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)

                // Navigation buttons
                HStack(spacing: 20) {
                    if currentStep > 0 {
                        Button(action: { currentStep -= 1 }) {
                            Text("Back")
                                .foregroundColor(Theme.textSecondary)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 15)
                                .background(Color.white.opacity(0.3))
                                .cornerRadius(25)
                        }
                    }

                    Spacer()

                    Button(action: handleNextButton) {
                        Text(nextButtonText)
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 15)
                            .background(Theme.buttonGradient)
                            .cornerRadius(25)
                            .shadow(color: Theme.shadow, radius: 5, x: 0, y: 3)
                    }
                    .disabled(!canProceed)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
        .photosPicker(
            isPresented: $showingPhotoPicker,
            selection: $selectedPhotos,
            maxSelectionCount: 3,
            matching: .images,
            photoLibrary: .shared()
        )
        .onChange(of: selectedPhotos) { _, newValue in
            Task {
                uploadedImages = []
                for item in newValue {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        uploadedImages.append(image)
                    }
                }
            }
        }
    }

    var canProceed: Bool {
        switch currentStep {
        case 1: return !selectedConcerns.isEmpty
        case 2: return !selectedGoals.isEmpty
        case 3: return !selectedRace.isEmpty
        case 4: return !selectedSkinType.isEmpty
        case 5: return !selectedCosmetics.isEmpty
        case 6: return !uploadedImages.isEmpty
        default: return true
        }
    }

    var nextButtonText: String {
        switch currentStep {
        case 6: return "Start Analysis"
        case 7: return showBlurredScore ? "Unlock Full Analysis" : "Analyzing..."
        case totalSteps - 1: return "Complete"
        default: return "Continue"
        }
    }

    func handleNextButton() {
        if currentStep == 6 {
            // Start AI analysis
            withAnimation {
                currentStep += 1
                startAnalysis()
            }
        } else if currentStep == 7 && showBlurredScore {
            // Trigger paywall
            triggerPaywall()
        } else if currentStep < totalSteps - 1 {
            withAnimation {
                currentStep += 1
            }
        }
    }

    func startAnalysis() {
        isAnalyzing = true
        analysisProgress = 0

        // Simulate analysis progress
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if analysisProgress < 1.0 {
                analysisProgress += 0.02
            } else {
                timer.invalidate()
                isAnalyzing = false
                showBlurredScore = true
            }
        }
    }

    func triggerPaywall() {
        // Trigger the SuperWall paywall after analysis
        NotificationCenter.default.post(name: Notification.Name("TriggerPaywall"), object: nil)

        // Store the analysis data for use after paywall
        if !uploadedImages.isEmpty {
            UserDefaults.standard.set(true, forKey: "HasPendingAnalysis")

            // Store user selections for later use
            UserDefaults.standard.set(Array(selectedConcerns), forKey: "SelectedConcerns")
            UserDefaults.standard.set(selectedSkinType, forKey: "SelectedSkinType")
            UserDefaults.standard.set(selectedRace, forKey: "SelectedRace")

            // Store first image data for analysis
            if let firstImage = uploadedImages.first,
               let imageData = firstImage.jpegData(compressionQuality: 0.8) {
                UserDefaults.standard.set(imageData, forKey: "PendingAnalysisImage")
            }
        }
    }
}

// MARK: - Step Views

struct WelcomeStep: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "sparkles")
                .font(.system(size: 80))
                .foregroundColor(Theme.purple)
                .padding(.bottom, 20)

            Text("Welcome to SkinGlowing")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Theme.textPrimary)

            Text("Your AI-Powered Skin Analysis")
                .font(.title2)
                .foregroundColor(Theme.textSecondary)

            VStack(alignment: .leading, spacing: 20) {
                FeatureRow(icon: "camera.fill", text: "Upload photos for instant analysis")
                FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Get your personalized skin score")
                FeatureRow(icon: "sparkles", text: "Receive custom skincare recommendations")
                FeatureRow(icon: "calendar", text: "Track your skin improvement over time")
            }
            .padding(.top, 40)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 30)
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Theme.purple)
                .frame(width: 30)

            Text(text)
                .font(.body)
                .foregroundColor(Theme.textPrimary)

            Spacer()
        }
    }
}

struct SkinConcernsStep: View {
    @Binding var selectedConcerns: Set<String>

    let concerns = [
        ("Acne & Breakouts", "face.smiling"),
        ("Fine Lines & Wrinkles", "clock"),
        ("Dark Spots", "circle.hexagonpath"),
        ("Dryness", "drop"),
        ("Oiliness", "sparkles"),
        ("Redness", "heart"),
        ("Large Pores", "circle.grid.3x3"),
        ("Dark Circles", "eye"),
        ("Uneven Texture", "square.grid.3x3"),
        ("Sensitivity", "exclamationmark.triangle")
    ]

    var body: some View {
        VStack(spacing: 25) {
            Text("What are your skin concerns?")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Theme.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.top, 40)

            Text("Select all that apply")
                .font(.body)
                .foregroundColor(Theme.textSecondary)

            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    ForEach(concerns, id: \.0) { concern in
                        SelectableCard(
                            title: concern.0,
                            icon: concern.1,
                            isSelected: selectedConcerns.contains(concern.0),
                            action: {
                                if selectedConcerns.contains(concern.0) {
                                    selectedConcerns.remove(concern.0)
                                } else {
                                    selectedConcerns.insert(concern.0)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom, 20)
    }
}

struct SkinGoalsStep: View {
    @Binding var selectedGoals: Set<String>

    let goals = [
        ("Clear Skin", "sparkle"),
        ("Anti-Aging", "hourglass"),
        ("Even Tone", "circle.lefthalf.filled"),
        ("Hydration", "drop.fill"),
        ("Minimize Pores", "circle.grid.3x3.fill"),
        ("Reduce Redness", "heart.fill"),
        ("Smooth Texture", "square.fill"),
        ("Brighten", "sun.max.fill")
    ]

    var body: some View {
        VStack(spacing: 25) {
            Text("What are your skin goals?")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Theme.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.top, 40)

            Text("Choose your top priorities")
                .font(.body)
                .foregroundColor(Theme.textSecondary)

            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    ForEach(goals, id: \.0) { goal in
                        SelectableCard(
                            title: goal.0,
                            icon: goal.1,
                            isSelected: selectedGoals.contains(goal.0),
                            action: {
                                if selectedGoals.contains(goal.0) {
                                    selectedGoals.remove(goal.0)
                                } else {
                                    selectedGoals.insert(goal.0)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom, 20)
    }
}

struct RaceEthnicityStep: View {
    @Binding var selectedRace: String

    let races = [
        "Asian",
        "Black/African",
        "Hispanic/Latino",
        "Middle Eastern",
        "Native American",
        "Pacific Islander",
        "White/Caucasian",
        "Mixed/Other",
        "Prefer not to say"
    ]

    var body: some View {
        VStack(spacing: 25) {
            Text("Select your ethnicity")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Theme.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.top, 40)

            Text("This helps us provide more accurate skin analysis")
                .font(.body)
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(races, id: \.self) { race in
                        SelectableRow(
                            title: race,
                            isSelected: selectedRace == race,
                            action: { selectedRace = race }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom, 20)
    }
}

struct SkinTypeStep: View {
    @Binding var selectedSkinType: String

    let skinTypes = [
        ("Oily", "Shiny all over, prone to breakouts"),
        ("Dry", "Tight, flaky, dull appearance"),
        ("Combination", "Oily T-zone, dry cheeks"),
        ("Normal", "Balanced, few concerns"),
        ("Sensitive", "Easily irritated, reactive")
    ]

    var body: some View {
        VStack(spacing: 25) {
            Text("What's your skin type?")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Theme.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.top, 40)

            ScrollView {
                VStack(spacing: 15) {
                    ForEach(skinTypes, id: \.0) { type in
                        SelectableDetailCard(
                            title: type.0,
                            subtitle: type.1,
                            isSelected: selectedSkinType == type.0,
                            action: { selectedSkinType = type.0 }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom, 20)
    }
}

struct CosmeticsStep: View {
    @Binding var selectedCosmetics: Set<String>

    let brands = [
        "Clinique",
        "La Mer",
        "SK-II",
        "Estée Lauder",
        "Lancôme",
        "Shiseido",
        "Dior",
        "Chanel",
        "Charlotte Tilbury",
        "Drunk Elephant",
        "The Ordinary",
        "CeraVe",
        "Cetaphil",
        "Neutrogena",
        "Olay",
        "Other/None"
    ]

    var body: some View {
        VStack(spacing: 25) {
            Text("Preferred cosmetic brands")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Theme.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.top, 40)

            Text("Select brands you currently use or prefer")
                .font(.body)
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)

            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(brands, id: \.self) { brand in
                        BrandChip(
                            title: brand,
                            isSelected: selectedCosmetics.contains(brand),
                            action: {
                                if selectedCosmetics.contains(brand) {
                                    selectedCosmetics.remove(brand)
                                } else {
                                    selectedCosmetics.insert(brand)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom, 20)
    }
}

struct PhotoUploadStep: View {
    @Binding var uploadedImages: [UIImage]
    @Binding var showingPhotoPicker: Bool
    @Binding var selectedPhotos: [PhotosPickerItem]

    var body: some View {
        VStack(spacing: 25) {
            Text("Upload your photos")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Theme.textPrimary)
                .padding(.top, 40)

            Text("For best results, upload 3 clear photos:\nFront face, Left profile, Right profile")
                .font(.body)
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)

            // Photo requirements
            VStack(alignment: .leading, spacing: 10) {
                RequirementRow(text: "No makeup or filters")
                RequirementRow(text: "Good lighting")
                RequirementRow(text: "Clear, focused images")
                RequirementRow(text: "Recent photos (within 1 week)")
            }
            .padding()
            .background(Theme.purpleUltraLight)
            .cornerRadius(12)
            .padding(.horizontal)

            // Photo preview area
            if uploadedImages.isEmpty {
                Button(action: { showingPhotoPicker = true }) {
                    VStack(spacing: 20) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 60))
                            .foregroundColor(Theme.purple)

                        Text("Tap to select photos")
                            .font(.headline)
                            .foregroundColor(Theme.purple)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .background(Color.white)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Theme.purple, style: StrokeStyle(lineWidth: 2, dash: [10]))
                    )
                }
                .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(uploadedImages.indices, id: \.self) { index in
                            Image(uiImage: uploadedImages[index])
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Theme.purple, lineWidth: 2)
                                )
                        }

                        if uploadedImages.count < 3 {
                            Button(action: { showingPhotoPicker = true }) {
                                VStack {
                                    Image(systemName: "plus")
                                        .font(.title)
                                        .foregroundColor(Theme.purple)
                                }
                                .frame(width: 120, height: 120)
                                .background(Theme.purpleUltraLight)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Theme.purple, style: StrokeStyle(lineWidth: 1, dash: [5]))
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)

                Button(action: {
                    uploadedImages = []
                    selectedPhotos = []
                }) {
                    Text("Change photos")
                        .font(.footnote)
                        .foregroundColor(Theme.textSecondary)
                }
            }

            // Privacy notice
            HStack(spacing: 8) {
                Image(systemName: "lock.shield")
                    .font(.caption)
                    .foregroundColor(Theme.success)

                Text("Your photos are encrypted and never shared")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
            }
            .padding(.top)

            Spacer()
        }
    }
}

struct AnalysisStep: View {
    @Binding var isAnalyzing: Bool
    @Binding var analysisProgress: Double
    @Binding var showBlurredScore: Bool
    let uploadedImages: [UIImage]

    var body: some View {
        VStack(spacing: 30) {
            if isAnalyzing {
                // Analysis in progress
                VStack(spacing: 30) {
                    Spacer()

                    Image(systemName: "sparkles.rectangle.stack")
                        .font(.system(size: 80))
                        .foregroundColor(Theme.purple)
                        .symbolEffect(.pulse)

                    Text("AI Analyzing Your Skin")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textPrimary)

                    VStack(alignment: .leading, spacing: 15) {
                        AnalysisProgressRow(text: "Detecting skin texture", progress: min(analysisProgress * 3, 1.0))
                        AnalysisProgressRow(text: "Analyzing problem areas", progress: max(0, min((analysisProgress - 0.33) * 3, 1.0)))
                        AnalysisProgressRow(text: "Calculating skin score", progress: max(0, min((analysisProgress - 0.66) * 3, 1.0)))
                    }
                    .padding(.horizontal, 40)

                    ProgressView(value: analysisProgress)
                        .tint(Theme.purple)
                        .scaleEffect(x: 1, y: 2)
                        .padding(.horizontal, 40)

                    Spacer()
                }
            } else if showBlurredScore {
                // Show blurred score
                BlurredScoreView()
            }
        }
    }
}

struct BlurredScoreView: View {
    @State private var glowAnimation = false

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // Score display with blur
            ZStack {
                VStack(spacing: 20) {
                    Text("Your Skin Score")
                        .font(.title2)
                        .foregroundColor(Theme.textPrimary)

                    Text("87")
                        .font(.system(size: 120, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.purple)

                    Text("Above Average")
                        .font(.title3)
                        .foregroundColor(Theme.success)
                }
                .blur(radius: 15)

                // Lock overlay
                Image(systemName: "lock.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                    .padding(20)
                    .background(Theme.purple)
                    .clipShape(Circle())
                    .shadow(color: Theme.glow, radius: glowAnimation ? 20 : 10)
                    .scaleEffect(glowAnimation ? 1.1 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true),
                        value: glowAnimation
                    )
            }

            // Teaser metrics (also blurred)
            VStack(spacing: 15) {
                HStack {
                    MetricCard(title: "Skin Age", value: "28", subtitle: "years", isBlurred: true)
                    MetricCard(title: "Hydration", value: "72", subtitle: "%", isBlurred: true)
                }

                HStack {
                    MetricCard(title: "Clarity", value: "B+", subtitle: "grade", isBlurred: true)
                    MetricCard(title: "Evenness", value: "85", subtitle: "%", isBlurred: true)
                }
            }
            .padding(.horizontal)

            Text("Unlock your complete analysis")
                .font(.headline)
                .foregroundColor(Theme.textPrimary)

            Text("• Detailed skin assessment\n• Personalized routine\n• Product recommendations")
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .onAppear {
            glowAnimation = true
        }
    }
}

// MARK: - Supporting Views

struct SelectableCard: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : Theme.purple)

                Text(title)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundColor(isSelected ? .white : Theme.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(isSelected ? Theme.purple : Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Theme.purple : Theme.borderLight, lineWidth: 1)
            )
        }
    }
}

struct SelectableRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(isSelected ? .white : Theme.textPrimary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(isSelected ? Theme.purple : Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Theme.purple : Theme.borderLight, lineWidth: 1)
            )
        }
    }
}

struct SelectableDetailCard: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : Theme.textPrimary)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.9) : Theme.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(isSelected ? Theme.purple : Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Theme.purple : Theme.borderLight, lineWidth: 1)
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
                .font(.footnote)
                .foregroundColor(isSelected ? .white : Theme.textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? Theme.purple : Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Theme.purple : Theme.borderLight, lineWidth: 1)
                )
        }
    }
}

struct RequirementRow: View {
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Theme.success)
                .font(.footnote)

            Text(text)
                .font(.footnote)
                .foregroundColor(Theme.textPrimary)

            Spacer()
        }
    }
}

struct AnalysisProgressRow: View {
    let text: String
    let progress: Double

    var body: some View {
        HStack(spacing: 15) {
            if progress >= 1.0 {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Theme.success)
            } else {
                ProgressView()
                    .scaleEffect(0.8)
            }

            Text(text)
                .font(.body)
                .foregroundColor(Theme.textPrimary)

            Spacer()
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let isBlurred: Bool

    var body: some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundColor(Theme.textSecondary)

            HStack(alignment: .bottom, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.purple)

                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(Theme.textSecondary)
                    .padding(.bottom, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .blur(radius: isBlurred ? 8 : 0)
    }
}

#Preview {
    OnboardingView()
}