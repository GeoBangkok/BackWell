//
//  OnboardingView.swift
//  SkinGlowing
//
//  Focused 15-screen onboarding flow
//

import SwiftUI
import AVFoundation

// MARK: - Main Onboarding View

struct OnboardingView: View {
    @State private var currentStep = 0
    @State private var selectedSkinType: String = ""
    @State private var selectedGoals: Set<String> = []
    @State private var selectedConcerns: Set<String> = []
    @State private var capturedImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var imagePickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var showActionSheet = false
    @State private var splashOpacity: Double = 0
    @State private var loadingFinished = false

    let onComplete: () -> Void
    let totalSteps = 14 // 0-indexed (0-14), paywall is handled by onComplete

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                // Back button and progress (hidden on splash, loading, blurry preview)
                if currentStep > 0 && currentStep != 13 && currentStep != 14 {
                    HStack {
                        Button(action: {
                            hapticFeedback(.light)
                            withAnimation(.easeInOut(duration: 0.3)) {
                                if currentStep > 0 {
                                    currentStep -= 1
                                }
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.black.opacity(0.6))
                                .frame(width: 44, height: 44)
                        }

                        Spacer()

                        // Step indicator
                        Text("\(currentStep)/\(totalSteps)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Theme.captionText)

                        Spacer()

                        // Invisible spacer for alignment
                        Color.clear.frame(width: 44, height: 44)
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 4)
                }

                // Screen content
                TabView(selection: $currentStep) {
                    SplashScreen(splashOpacity: $splashOpacity)
                        .tag(0)

                    HookScreen()
                        .tag(1)

                    MicroPainScreen()
                        .tag(2)

                    FaceScanTeaserScreen()
                        .tag(3)

                    CredibilityScreen()
                        .tag(4)

                    SkinTypeScreen(selectedSkinType: $selectedSkinType)
                        .tag(5)

                    PrimaryGoalScreen(selectedGoals: $selectedGoals)
                        .tag(6)

                    CurrentConcernsScreen(selectedConcerns: $selectedConcerns)
                        .tag(7)

                    HabitLockScreen()
                        .tag(8)

                    ResultPreviewScreen()
                        .tag(9)

                    CameraPermissionScreen(onGranted: {
                        advanceStep()
                    })
                        .tag(10)

                    LightingInstructionScreen()
                        .tag(11)

                    ScanOrUploadScreen(
                        capturedImage: $capturedImage,
                        showActionSheet: $showActionSheet,
                        showImagePicker: $showImagePicker,
                        imagePickerSource: $imagePickerSource
                    )
                        .tag(12)

                    LoadingScreen(capturedImage: $capturedImage, onFinished: {
                        loadingFinished = true
                        advanceStep()
                    })
                        .tag(13)

                    BlurryPreviewScreen(capturedImage: $capturedImage, onUnlock: {
                        onComplete()
                    })
                        .tag(14)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.35), value: currentStep)

                // Bottom CTA button (shown on most screens)
                if shouldShowContinueButton {
                    Button(action: {
                        hapticFeedback(.medium)
                        handleContinue()
                    }) {
                        Text(continueButtonText)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(Theme.accent)
                            )
                    }
                    .disabled(isContinueDisabled)
                    .opacity(isContinueDisabled ? 0.45 : 1.0)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 24)
                    .padding(.top, 8)
                }
            }
        }
        .onAppear {
            // Auto-advance splash after 1 second
            withAnimation(.easeIn(duration: 0.8)) {
                splashOpacity = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation {
                    currentStep = 1
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $capturedImage, sourceType: imagePickerSource)
        }
        .onChange(of: capturedImage) { newImage in
            // When photo is selected on screen 12, auto-advance to loading
            if newImage != nil && currentStep == 12 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    advanceStep()
                }
            }
        }
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(
                title: Text("Add a Photo"),
                buttons: [
                    .default(Text("Take Photo")) {
                        imagePickerSource = .camera
                        showImagePicker = true
                    },
                    .default(Text("Choose from Library")) {
                        imagePickerSource = .photoLibrary
                        showImagePicker = true
                    },
                    .cancel()
                ]
            )
        }
    }

    // MARK: - Navigation Helpers

    private var shouldShowContinueButton: Bool {
        // Hide on splash, camera permission, scan/upload, loading, blurry preview.
        switch currentStep {
        case 0, 10, 12, 13, 14:
            return false
        default:
            return true
        }
    }

    private var continueButtonText: String {
        return "Continue"
    }

    private var isContinueDisabled: Bool {
        switch currentStep {
        case 5: return selectedSkinType.isEmpty
        case 6: return selectedGoals.isEmpty
        case 7: return selectedConcerns.isEmpty
        default: return false
        }
    }

    private func handleContinue() {
        // Save user data on relevant screens
        switch currentStep {
        case 5:
            UserDefaults.standard.set(selectedSkinType, forKey: "sg_skinType")
        case 6:
            UserDefaults.standard.set(Array(selectedGoals), forKey: "sg_goals")
        case 7:
            UserDefaults.standard.set(Array(selectedConcerns), forKey: "sg_concerns")
        default:
            break
        }
        advanceStep()
    }

    private func advanceStep() {
        withAnimation(.easeInOut(duration: 0.35)) {
            if currentStep < totalSteps {
                currentStep += 1
            }
        }
    }
}

// MARK: - Screen 1: Splash

struct SplashScreen: View {
    @Binding var splashOpacity: Double

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Text("SkinGlowing")
                .font(.system(size: 42, weight: .heavy))
                .foregroundColor(.black)

            Text("AI Skin Coach")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Theme.captionText)

            Spacer()
        }
        .opacity(splashOpacity)
    }
}

// MARK: - Screen 2: The Hook

struct HookScreen: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: "face.smiling")
                .font(.system(size: 80, weight: .thin))
                .foregroundColor(.black.opacity(0.8))
                .padding(.bottom, 40)

            Text("Your skin changes\nevery day.")
                .font(.system(size: 32, weight: .heavy))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.bottom, 16)

            Text("Most people only notice\nwhen it gets obvious.")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(Theme.captionText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Screen 3: Micro-pain

struct MicroPainScreen: View {
    let icons = [
        ("drop.fill", "Dryness"),
        ("flame.fill", "Redness"),
        ("square.grid.2x2", "Texture"),
        ("circle.circle", "Spots")
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // 4 icons in a row
            HStack(spacing: 28) {
                ForEach(icons, id: \.0) { icon, label in
                    VStack(spacing: 8) {
                        Image(systemName: icon)
                            .font(.system(size: 28, weight: .thin))
                            .foregroundColor(.black.opacity(0.7))
                            .frame(width: 56, height: 56)
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0.04))
                            )

                        Text(label)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Theme.captionText)
                    }
                }
            }
            .padding(.bottom, 48)

            Text("Tiny skin changes stack.")
                .font(.system(size: 32, weight: .heavy))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.bottom, 16)

            Text("Dryness. Breakouts. Texture.\nUneven tone.")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(Theme.captionText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Screen 4: Face Scan Teaser

struct FaceScanTeaserScreen: View {
    @State private var scanLineOffset: CGFloat = -120

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Mock scan view
            ZStack {
                Image("onboarding_scan_face")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 280, height: 240)
                    .overlay(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.04),
                                Color.black.opacity(0.18)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                // Scan line
                Rectangle()
                    .fill(Theme.accent.opacity(0.6))
                    .frame(width: 240, height: 2)
                    .offset(y: scanLineOffset)
                    .animation(
                        Animation.easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true),
                        value: scanLineOffset
                    )

                Image(systemName: "viewfinder")
                    .font(.system(size: 156, weight: .ultraLight))
                    .foregroundColor(.white.opacity(0.72))
            }
            .frame(width: 280, height: 240)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
            .padding(.bottom, 40)
            .onAppear {
                scanLineOffset = 120
            }

            Text("One selfie.\nFour skin signals.")
                .font(.system(size: 32, weight: .heavy))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.bottom, 16)

            Text("Track Skin Age, Glass Skin,\nBlemishes, and Firmness.")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(Theme.captionText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.bottom, 24)

            // Small score labels
            HStack(spacing: 6) {
                ForEach(["Skin Age", "Glass Skin", "Blemishes", "Firmness"], id: \.self) { label in
                    Text(label)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Theme.captionText)
                    if label != "Firmness" {
                        Text("\u{2022}")
                            .font(.system(size: 10))
                            .foregroundColor(Theme.mutedText)
                    }
                }
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Screen 5: Credibility Framing

struct CredibilityScreen: View {
    let bullets = [
        "Zone-based analysis",
        "Progress history",
        "Personalized tips"
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("Built for consistency.")
                .font(.system(size: 32, weight: .heavy))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.bottom, 12)

            Text("Same angle.\nSame lighting.\nBetter tracking over time.")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(Theme.captionText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.bottom, 36)

            // Card with bullets
            VStack(alignment: .leading, spacing: 20) {
                ForEach(bullets, id: \.self) { bullet in
                    HStack(spacing: 14) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Theme.statusGreen)

                        Text(bullet)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black.opacity(0.8))
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
            )

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Screen 6: Skin Type Selection

struct SkinTypeScreen: View {
    @Binding var selectedSkinType: String
    let options = ["Dry", "Oily", "Combination", "Sensitive", "Not sure"]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("What's your skin type?")
                .font(.system(size: 32, weight: .heavy))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.bottom, 32)

            // Pill buttons
            FlowLayout(spacing: 12) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        hapticFeedback(.light)
                        selectedSkinType = option
                    }) {
                        Text(option)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(selectedSkinType == option ? .white : .black.opacity(0.7))
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(
                                Capsule()
                                    .fill(selectedSkinType == option ? Theme.accent : Color.black.opacity(0.04))
                            )
                            .overlay(
                                Capsule()
                                    .stroke(selectedSkinType == option ? Color.clear : Color.black.opacity(0.08), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.bottom, 24)

            Text("This helps personalize your analysis.")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Theme.captionText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Screen 7: Product Scan Teaser

struct ProductScanTeaserScreen: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Ingredient list mockup card
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 20, weight: .thin))
                        .foregroundColor(.black.opacity(0.5))
                    Text("Ingredients")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black.opacity(0.6))
                }
                .padding(.bottom, 4)

                ForEach(["Aqua", "Glycerin", "Niacinamide", "Hyaluronic Acid", "Retinol 0.1%"], id: \.self) { ingredient in
                    HStack {
                        Circle()
                            .fill(ingredient == "Retinol 0.1%" ? Theme.statusYellow : Theme.statusGreen)
                            .frame(width: 8, height: 8)
                        Text(ingredient)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.black.opacity(0.7))
                        Spacer()
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
            )
            .padding(.bottom, 40)

            Text("Your makeup can be\nthe problem.")
                .font(.system(size: 32, weight: .heavy))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.bottom, 16)

            Text("Scan products to see fit\nfor your skin.")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(Theme.captionText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Screen 8: Primary Goal (Multi-select)

struct PrimaryGoalScreen: View {
    @Binding var selectedGoals: Set<String>

    let goals: [(String, String)] = [
        ("sparkle", "Clear acne"),
        ("sun.max", "Glass glow"),
        ("circle.lefthalf.filled", "Even tone"),
        ("clock.arrow.circlepath", "Anti-aging"),
        ("circle.grid.cross", "Smaller pores"),
        ("flame", "Less redness")
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("What do you want most?")
                .font(.system(size: 32, weight: .heavy))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.bottom, 32)

            // 2-column grid
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                ForEach(goals, id: \.1) { icon, label in
                    Button(action: {
                        hapticFeedback(.light)
                        if selectedGoals.contains(label) {
                            selectedGoals.remove(label)
                        } else {
                            selectedGoals.insert(label)
                        }
                    }) {
                        VStack(spacing: 10) {
                            Image(systemName: icon)
                                .font(.system(size: 26, weight: .thin))
                                .foregroundColor(selectedGoals.contains(label) ? Theme.accent : .black.opacity(0.5))

                            Text(label)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(selectedGoals.contains(label) ? .black : .black.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 90)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(selectedGoals.contains(label) ? Theme.accent.opacity(0.08) : Color.black.opacity(0.03))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(selectedGoals.contains(label) ? Theme.accent.opacity(0.4) : Color.clear, lineWidth: 1.5)
                        )
                    }
                }
            }
            .padding(.bottom, 20)

            Text("Pick all that apply.")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Theme.captionText)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Screen 9: Skin Age Teaser

struct SkinAgeTeaserScreen: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Result card preview
            VStack(spacing: 12) {
                Text("Skin Age")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Theme.captionText)

                Text("27")
                    .font(.system(size: 64, weight: .heavy, design: .rounded))
                    .foregroundColor(.black)

                Text("Fine lines detected under eyes.")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Theme.captionText)
            }
            .padding(.vertical, 32)
            .padding(.horizontal, 40)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
            )
            .padding(.bottom, 40)

            Text("Skin Age hits different.")
                .font(.system(size: 32, weight: .heavy))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.bottom, 16)

            Text("\"You look 27\" is clearer than\na random score.")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(Theme.captionText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Screen 10: Habit Lock

struct HabitLockScreen: View {
    let days = ["M", "T", "W", "T", "F", "S", "S"]
    let checked = [true, true, true, true, true, false, false]
    let todayIndex = 5 // Saturday as "today"

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Calendar strip
            HStack(spacing: 12) {
                ForEach(0..<7, id: \.self) { i in
                    VStack(spacing: 6) {
                        Text(days[i])
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Theme.captionText)

                        ZStack {
                            Circle()
                                .fill(
                                    i == todayIndex ? Theme.accent :
                                    checked[i] ? Color.black.opacity(0.06) : Color.clear
                                )
                                .frame(width: 38, height: 38)

                            if checked[i] {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(Theme.statusGreen)
                            } else if i == todayIndex {
                                Text("\(16)")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
            )
            .padding(.bottom, 40)

            Text("A 10-second daily scan.")
                .font(.system(size: 32, weight: .heavy))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.bottom, 16)

            Text("Progress is easier\nwhen you can see it.")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(Theme.captionText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Screen 10: Result Preview

struct ResultPreviewScreen: View {
    let results: [(String, String)] = [
        ("27", "Skin Age"),
        ("Glowy", "Glass Skin"),
        ("Low", "Blemishes"),
        ("7.4", "Firmness")
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(results, id: \.1) { value, label in
                    VStack(spacing: 8) {
                        Text(value)
                            .font(.system(size: value.count > 4 ? 22 : 30, weight: .heavy, design: .rounded))
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)

                        Text(label)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Theme.captionText)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 104)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
                    )
                }
            }
            .padding(.bottom, 40)

            Text("Simple scores.\nClear next steps.")
                .font(.system(size: 32, weight: .heavy))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.bottom, 16)

            Text("No guessing.")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(Theme.captionText)
                .multilineTextAlignment(.center)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Legacy Screen: Glass Skin Teaser

struct GlassSkinTeaserScreen: View {
    let tiers = ["Dull", "Balanced", "Glowy", "Glass-tier"]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Tier ladder
            VStack(spacing: 0) {
                ForEach(Array(tiers.reversed().enumerated()), id: \.offset) { index, tier in
                    HStack(spacing: 14) {
                        // Step number
                        ZStack {
                            Circle()
                                .fill(tier == "Glowy" ? Theme.accent : Color.black.opacity(0.06))
                                .frame(width: 36, height: 36)

                            Text("\(4 - index)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(tier == "Glowy" ? .white : .black.opacity(0.5))
                        }

                        Text(tier)
                            .font(.system(size: 18, weight: tier == "Glowy" ? .heavy : .medium))
                            .foregroundColor(tier == "Glowy" ? Theme.accent : .black.opacity(0.6))

                        Spacer()

                        if tier == "Glowy" {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Theme.accent)
                            Text("You")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Theme.accent)
                        }
                    }
                    .padding(.vertical, 14)

                    if index < 3 {
                        Divider()
                            .padding(.leading, 50)
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
            )
            .padding(.bottom, 40)

            Text("Chase Glass-tier.")
                .font(.system(size: 32, weight: .heavy))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.bottom, 16)

            Text("Dull \u{2192} Balanced \u{2192} Glowy \u{2192} Glass-tier\nA simple ladder users understand instantly.")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Theme.captionText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Screen 12: Current Concerns (Multi-select)

struct CurrentConcernsScreen: View {
    @Binding var selectedConcerns: Set<String>

    let concerns = [
        "Breakouts",
        "Dark spots",
        "Texture",
        "Under-eye darkness",
        "Redness",
        "Dry patches"
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("What bothers you\nright now?")
                .font(.system(size: 32, weight: .heavy))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.bottom, 28)

            VStack(spacing: 10) {
                ForEach(concerns, id: \.self) { concern in
                    Button(action: {
                        hapticFeedback(.light)
                        if selectedConcerns.contains(concern) {
                            selectedConcerns.remove(concern)
                        } else {
                            selectedConcerns.insert(concern)
                        }
                    }) {
                        HStack {
                            Text(concern)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black.opacity(0.8))

                            Spacer()

                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(
                                        selectedConcerns.contains(concern) ? Theme.accent : Color.black.opacity(0.15),
                                        lineWidth: 1.5
                                    )
                                    .frame(width: 24, height: 24)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(selectedConcerns.contains(concern) ? Theme.accent : Color.clear)
                                    )

                                if selectedConcerns.contains(concern) {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(selectedConcerns.contains(concern) ? Theme.accent.opacity(0.06) : Color.black.opacity(0.03))
                        )
                    }
                }
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Screen 13: Fit Score Teaser

struct FitScoreTeaserScreen: View {
    let categories = ["Acne-safe", "Hydration", "Irritation", "Glow Support"]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Compatibility score card
            VStack(spacing: 16) {
                Text("Compatibility")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Theme.captionText)

                Text("8/10")
                    .font(.system(size: 56, weight: .heavy, design: .rounded))
                    .foregroundColor(.black)

                // Category labels
                HStack(spacing: 8) {
                    ForEach(categories, id: \.self) { cat in
                        Text(cat)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Theme.captionText)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.black.opacity(0.04))
                            )
                    }
                }
            }
            .padding(.vertical, 28)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
            )
            .padding(.bottom, 40)

            Text("Makeup Fit Score.")
                .font(.system(size: 32, weight: .heavy))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.bottom, 16)

            Text("We rate products based on your\nskin type and concerns.")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(Theme.captionText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Screen 14: Blemishes Teaser

struct BlemishesTeaserScreen: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Face outline with dots
            ZStack {
                Circle()
                    .stroke(Color.black.opacity(0.1), lineWidth: 1.5)
                    .frame(width: 200, height: 200)

                // Blemish dots
                Circle()
                    .fill(Theme.accent.opacity(0.6))
                    .frame(width: 14, height: 14)
                    .offset(x: 30, y: 60) // chin area

                Circle()
                    .fill(Theme.statusYellow.opacity(0.7))
                    .frame(width: 10, height: 10)
                    .offset(x: -45, y: 20) // left cheek

                Circle()
                    .fill(Theme.accent.opacity(0.5))
                    .frame(width: 12, height: 12)
                    .offset(x: 50, y: 10) // right cheek

                // Small eyes for face effect
                HStack(spacing: 40) {
                    Circle()
                        .fill(Color.black.opacity(0.15))
                        .frame(width: 8, height: 8)
                    Circle()
                        .fill(Color.black.opacity(0.15))
                        .frame(width: 8, height: 8)
                }
                .offset(y: -25)
            }
            .padding(.bottom, 40)

            Text("Catch breakouts early.")
                .font(.system(size: 32, weight: .heavy))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.bottom, 16)

            Text("We surface where flare-ups\nare showing up.")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(Theme.captionText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.bottom, 16)

            Text("Small redness detected on chin.")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Theme.accent)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Theme.accent.opacity(0.08))
                )

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Screen 15: Routine Consistency

struct ConsistencyScreen: View {
    @Binding var selectedConsistency: String

    let options = [
        ("checkmark.seal", "Very consistent", "I follow a routine daily"),
        ("clock", "Sometimes", "I do it when I remember"),
        ("leaf", "Starting from scratch", "I'm just getting started")
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("How consistent are you?")
                .font(.system(size: 32, weight: .heavy))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.bottom, 32)

            VStack(spacing: 14) {
                ForEach(options, id: \.1) { icon, title, subtitle in
                    Button(action: {
                        hapticFeedback(.light)
                        selectedConsistency = title
                    }) {
                        HStack(spacing: 16) {
                            Image(systemName: icon)
                                .font(.system(size: 24, weight: .thin))
                                .foregroundColor(selectedConsistency == title ? Theme.accent : .black.opacity(0.4))
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(selectedConsistency == title ? Theme.accent.opacity(0.1) : Color.black.opacity(0.03))
                                )

                            VStack(alignment: .leading, spacing: 3) {
                                Text(title)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.black.opacity(0.85))

                                Text(subtitle)
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(Theme.captionText)
                            }

                            Spacer()

                            Circle()
                                .stroke(selectedConsistency == title ? Theme.accent : Color.black.opacity(0.15), lineWidth: 2)
                                .frame(width: 22, height: 22)
                                .overlay(
                                    Circle()
                                        .fill(selectedConsistency == title ? Theme.accent : Color.clear)
                                        .frame(width: 14, height: 14)
                                )
                        }
                        .padding(18)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(selectedConsistency == title ? Theme.accent.opacity(0.05) : Color.black.opacity(0.02))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(selectedConsistency == title ? Theme.accent.opacity(0.3) : Color.black.opacity(0.06), lineWidth: 1)
                        )
                    }
                }
            }
            .padding(.bottom, 20)

            Text("We'll match the tips to your reality.")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Theme.captionText)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Screen 16: Firmness Teaser

struct FirmnessTeaserScreen: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Firmness card
            VStack(spacing: 12) {
                HStack {
                    Text("Firmness")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Theme.captionText)
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Theme.statusGreen)
                        Text("+0.3")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Theme.statusGreen)
                    }
                }

                Text("7.4 / 10")
                    .font(.system(size: 48, weight: .heavy, design: .rounded))
                    .foregroundColor(.black)

                Text("Elasticity looks above average today.")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Theme.captionText)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
            )
            .padding(.bottom, 40)

            Text("Firmness is slow money.")
                .font(.system(size: 32, weight: .heavy))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.bottom, 16)

            Text("Tiny improvements compound\nover months.")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(Theme.captionText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Screen 11: Camera Permission

struct CameraPermissionScreen: View {
    let onGranted: () -> Void
    @State private var permissionHandled = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: "camera")
                .font(.system(size: 72, weight: .thin))
                .foregroundColor(.black.opacity(0.7))
                .padding(.bottom, 40)

            Text("Take your first scan.")
                .font(.system(size: 32, weight: .heavy))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.bottom, 16)

            Text("A selfie in good lighting\nis all you need.")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(Theme.captionText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.bottom, 28)

            Text("Your photo is used to generate\nyour skin analysis.")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Theme.captionText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black.opacity(0.03))
                )
                .padding(.bottom, 40)

            Button(action: {
                requestCameraAccess()
            }) {
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Theme.accent)
                    )
            }
            .padding(.horizontal, 40)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }

    private func requestCameraAccess() {
        guard !permissionHandled else { return }
        permissionHandled = true

        AVCaptureDevice.requestAccess(for: .video) { _ in
            DispatchQueue.main.async {
                onGranted()
            }
        }
    }
}

// MARK: - Screen 12: Lighting Instruction

struct LightingInstructionScreen: View {
    let tips: [(String, String)] = [
        ("sun.max", "Natural light"),
        ("person.crop.circle", "Face centered"),
        ("cloud.sun", "No heavy shadows")
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // 3 tiles
            HStack(spacing: 16) {
                ForEach(tips, id: \.0) { icon, label in
                    VStack(spacing: 12) {
                        Image(systemName: icon)
                            .font(.system(size: 30, weight: .thin))
                            .foregroundColor(.black.opacity(0.6))
                            .frame(width: 64, height: 64)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.black.opacity(0.03))
                            )

                        Text(label)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.black.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 44)

            Text("Better lighting.\nBetter results.")
                .font(.system(size: 32, weight: .heavy))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.bottom, 16)

            Text("Keep your face centered\nwith no heavy shadows.")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(Theme.captionText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Screen 19: Premium Framing

struct PremiumFramingScreen: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("Stop guessing.")
                .font(.system(size: 32, weight: .heavy))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.bottom, 32)

            // Two columns
            HStack(alignment: .top, spacing: 20) {
                // Before column
                VStack(alignment: .leading, spacing: 16) {
                    Text("Before")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Theme.captionText)
                        .padding(.bottom, 4)

                    ForEach(["Guessing", "Random TikTok advice", "No tracking"], id: \.self) { item in
                        HStack(spacing: 10) {
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Theme.captionText)
                            Text(item)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Theme.captionText)
                        }
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black.opacity(0.03))
                )

                // After column
                VStack(alignment: .leading, spacing: 16) {
                    Text("After")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Theme.accent)
                        .padding(.bottom, 4)

                    ForEach(["Scan", "Score", "Adjust"], id: \.self) { item in
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Theme.accent)
                            Text(item)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black.opacity(0.8))
                        }
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Theme.accent.opacity(0.15), lineWidth: 1)
                )
            }
            .padding(.bottom, 32)

            Text("Scan today. Adjust tomorrow.\nTrack the trend.")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(Theme.captionText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Screen 13: Scan or Photo Upload

struct ScanOrUploadScreen: View {
    @Binding var capturedImage: UIImage?
    @Binding var showActionSheet: Bool
    @Binding var showImagePicker: Bool
    @Binding var imagePickerSource: UIImagePickerController.SourceType

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: "camera.circle")
                .font(.system(size: 80, weight: .thin))
                .foregroundColor(.black.opacity(0.6))
                .padding(.bottom, 36)

            Text("Ready for your first scan?")
                .font(.system(size: 32, weight: .heavy))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.bottom, 16)

            Text("Use a clear selfie\nwith your full face visible.")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(Theme.captionText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.bottom, 48)

            // Camera button
            Button(action: {
                hapticFeedback(.medium)
                showActionSheet = true
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 18))
                    Text("Take Photo or Upload")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Theme.accent)
                )
            }
            .padding(.horizontal, 40)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Screen 14: Loading Screen

struct LoadingScreen: View {
    @Binding var capturedImage: UIImage?
    let onFinished: () -> Void

    @State private var progress: Double = 0
    @State private var currentStepIndex = 0
    @State private var visibleSteps: [String] = []

    let steps = [
        "Mapping facial zones...",
        "Checking texture...",
        "Reading tone balance...",
        "Estimating skin signals...",
        "Building your profile..."
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Photo preview
            if let image = capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                    )
                    .padding(.bottom, 32)
            }

            // Analysis steps
            VStack(alignment: .leading, spacing: 12) {
                ForEach(visibleSteps, id: \.self) { step in
                    HStack(spacing: 10) {
                        if step == visibleSteps.last {
                            ProgressView()
                                .scaleEffect(0.8)
                                .frame(width: 16, height: 16)
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Theme.statusGreen)
                        }

                        Text(step)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(step == visibleSteps.last ? .black : Theme.captionText)
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 40)
            .padding(.bottom, 36)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.black.opacity(0.06))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(Theme.accent)
                        .frame(width: geo.size.width * progress, height: 8)
                        .animation(.linear(duration: 0.3), value: progress)
                }
            }
            .frame(height: 8)
            .padding(.horizontal, 40)

            Spacer()
            Spacer()
        }
        .onAppear {
            startLoadingSequence()
        }
    }

    private func startLoadingSequence() {
        let stepDuration = 0.75
        for i in 0..<steps.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(i)) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    visibleSteps.append(steps[i])
                    progress = Double(i + 1) / Double(steps.count)
                }
            }
        }

        // Finish after all steps
        DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(steps.count) + 0.5) {
            onFinished()
        }
    }
}

// MARK: - Screen 15: Blurry Preview

struct BlurryPreviewScreen: View {
    @Binding var capturedImage: UIImage?
    let onUnlock: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Blurred user photo
            if let image = capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 140, height: 140)
                    .clipShape(Circle())
                    .blur(radius: 15)
                    .overlay(
                        Circle()
                            .stroke(Color.black.opacity(0.06), lineWidth: 1)
                    )
                    .padding(.bottom, 24)
            }

            // Blurred result cards
            HStack(spacing: 12) {
                ForEach(["Skin Age", "Glass Skin", "Blemishes", "Firmness"], id: \.self) { label in
                    VStack(spacing: 8) {
                        Text("--")
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                            .foregroundColor(.black)

                        Text(label)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Theme.captionText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                    )
                    .blur(radius: 6)
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 36)

            // Lock overlay text
            Image(systemName: "lock.fill")
                .font(.system(size: 28, weight: .thin))
                .foregroundColor(.black.opacity(0.6))
                .padding(.bottom, 12)

            Text("Your results are ready")
                .font(.system(size: 28, weight: .heavy))
                .foregroundColor(.black)
                .padding(.bottom, 8)

            Text("Unlock your full skin analysis.")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Theme.captionText)
                .padding(.bottom, 40)

            // CTA
            Button(action: {
                hapticFeedback(.medium)
                onUnlock()
            }) {
                Text("See My Results")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Theme.accent)
                    )
            }
            .padding(.horizontal, 40)

            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Flow Layout for Pills

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            maxX = max(maxX, currentX)
        }

        return (positions, CGSize(width: maxX, height: currentY + lineHeight))
    }
}

// MARK: - Preview

#Preview {
    OnboardingView(onComplete: {})
}
