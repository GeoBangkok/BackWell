//
//  HomeView.swift
//  SkinGlowing
//
//  Modern beauty routines with iOS Health aesthetic

import SwiftUI

struct HomeView: View {
    @State private var selectedRoutineType = "morning"
    @State private var showingRoutinePlayer = false
    @State private var selectedRoutine: BeautyRoutine?
    @State private var isGeneratingRoutine = false
    @State private var generatedRoutines: [BeautyRoutine] = []

    // Beauty routines
    let morningRoutines = [
        BeautyRoutine(
            id: UUID(),
            name: "Glass Skin Glow",
            duration: "12 min",
            steps: 7,
            icon: "sparkles",
            description: "Korean-inspired dewy skin routine",
            difficulty: "Intermediate",
            products: ["Oil cleanser", "Water-based cleanser", "Toner", "Essence", "Serum", "Moisturizer", "SPF"]
        ),
        BeautyRoutine(
            id: UUID(),
            name: "5-Minute Fresh Face",
            duration: "5 min",
            steps: 4,
            icon: "clock",
            description: "Quick morning refresh for busy days",
            difficulty: "Beginner",
            products: ["Micellar water", "Vitamin C serum", "Moisturizer", "SPF"]
        ),
        BeautyRoutine(
            id: UUID(),
            name: "Gua Sha Sculpt",
            duration: "15 min",
            steps: 5,
            icon: "leaf.circle",
            description: "Lymphatic drainage and face lifting",
            difficulty: "Advanced",
            products: ["Facial oil", "Gua sha stone"]
        )
    ]

    let eveningRoutines = [
        BeautyRoutine(
            id: UUID(),
            name: "Slugging Protocol",
            duration: "10 min",
            steps: 5,
            icon: "moon.stars",
            description: "Intense overnight hydration method",
            difficulty: "Intermediate",
            products: ["Double cleanse", "Hydrating toner", "Hyaluronic acid", "Thick moisturizer", "Petroleum jelly"]
        ),
        BeautyRoutine(
            id: UUID(),
            name: "Retinol Power",
            duration: "8 min",
            steps: 6,
            icon: "bolt",
            description: "Anti-aging focused night routine",
            difficulty: "Advanced",
            products: ["Cleansing balm", "Gentle cleanser", "Retinol treatment", "Peptide serum", "Night cream", "Eye cream"]
        ),
        BeautyRoutine(
            id: UUID(),
            name: "Barrier Repair",
            duration: "10 min",
            steps: 5,
            icon: "shield",
            description: "Restore and strengthen skin barrier",
            difficulty: "Beginner",
            products: ["Gentle cleanser", "Cica toner", "Ceramide serum", "Centella cream", "Face oil"]
        )
    ]

    let specialRoutines = [
        BeautyRoutine(
            id: UUID(),
            name: "Face Yoga Flow",
            duration: "20 min",
            steps: 8,
            icon: "figure.yoga",
            description: "Natural facelift through exercises",
            difficulty: "Intermediate",
            products: ["Face oil for massage"]
        ),
        BeautyRoutine(
            id: UUID(),
            name: "Ice Facial",
            duration: "7 min",
            steps: 4,
            icon: "snowflake",
            description: "Pore tightening and de-puffing",
            difficulty: "Beginner",
            products: ["Ice roller or ice cubes", "Hydrating serum"]
        ),
        BeautyRoutine(
            id: UUID(),
            name: "Honey Glow Mask",
            duration: "25 min",
            steps: 5,
            icon: "drop.circle",
            description: "DIY hydrating and brightening treatment",
            difficulty: "Beginner",
            products: ["Raw honey", "Yogurt", "Turmeric powder"]
        )
    ]

    var currentRoutines: [BeautyRoutine] {
        switch selectedRoutineType {
        case "morning":
            return morningRoutines
        case "evening":
            return eveningRoutines
        case "special":
            return specialRoutines
        case "generated":
            return generatedRoutines
        default:
            return morningRoutines
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Clean white background
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        // Header
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Beauty Routines")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(Color(UIColor.label))

                            // Routine type selector
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    RoutineTypeButton(
                                        title: "Morning",
                                        icon: "sun.max.fill",
                                        isSelected: selectedRoutineType == "morning",
                                        action: {
                                            withAnimation(.spring()) {
                                                selectedRoutineType = "morning"
                                            }
                                            hapticFeedback(.light)
                                        }
                                    )

                                    RoutineTypeButton(
                                        title: "Evening",
                                        icon: "moon.fill",
                                        isSelected: selectedRoutineType == "evening",
                                        action: {
                                            withAnimation(.spring()) {
                                                selectedRoutineType = "evening"
                                            }
                                            hapticFeedback(.light)
                                        }
                                    )

                                    RoutineTypeButton(
                                        title: "Special",
                                        icon: "star.fill",
                                        isSelected: selectedRoutineType == "special",
                                        action: {
                                            withAnimation(.spring()) {
                                                selectedRoutineType = "special"
                                            }
                                            hapticFeedback(.light)
                                        }
                                    )

                                    RoutineTypeButton(
                                        title: "AI Generated",
                                        icon: "wand.and.stars",
                                        isSelected: selectedRoutineType == "generated",
                                        action: {
                                            withAnimation(.spring()) {
                                                selectedRoutineType = "generated"
                                                if generatedRoutines.isEmpty {
                                                    generateRoutines()
                                                }
                                            }
                                            hapticFeedback(.light)
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 24)

                        // Routines grid
                        if selectedRoutineType == "generated" && isGeneratingRoutine {
                            // Loading state for AI generation
                            VStack(spacing: 20) {
                                ProgressView()
                                    .scaleEffect(1.2)
                                    .tint(Color(hex: "FF91A4"))

                                Text("Creating personalized routines...")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(UIColor.secondaryLabel))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 300)
                        } else {
                            LazyVStack(spacing: 16) {
                                ForEach(currentRoutines) { routine in
                                    RoutineCard(routine: routine) {
                                        selectedRoutine = routine
                                        showingRoutinePlayer = true
                                        hapticFeedback(.light)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 30)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(item: $selectedRoutine) { routine in
            RoutinePlayerView(routine: routine)
        }
    }

    private func generateRoutines() {
        isGeneratingRoutine = true

        // Simulate AI generation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                generatedRoutines = [
                    BeautyRoutine(
                        id: UUID(),
                        name: "Your Perfect Morning",
                        duration: "10 min",
                        steps: 6,
                        icon: "sparkle",
                        description: "Customized based on your skin analysis",
                        difficulty: "Personalized",
                        products: ["Gentle foam cleanser", "PH balancing toner", "Niacinamide serum", "Peptide moisturizer", "Mineral SPF 50"]
                    ),
                    BeautyRoutine(
                        id: UUID(),
                        name: "Targeted Treatment",
                        duration: "15 min",
                        steps: 7,
                        icon: "target",
                        description: "Addresses your specific concerns",
                        difficulty: "Personalized",
                        products: ["Micellar water", "BHA toner", "Vitamin C serum", "Retinol alternative", "Barrier cream"]
                    ),
                    BeautyRoutine(
                        id: UUID(),
                        name: "Weekly Reset",
                        duration: "30 min",
                        steps: 9,
                        icon: "arrow.clockwise",
                        description: "Deep treatment for optimal results",
                        difficulty: "Personalized",
                        products: ["Oil cleanser", "Enzyme exfoliant", "Clay mask", "Hydrating mask", "Face oil"]
                    )
                ]
                isGeneratingRoutine = false
            }
        }
    }
}

// MARK: - Supporting Views

struct BeautyRoutine: Identifiable {
    let id: UUID
    let name: String
    let duration: String
    let steps: Int
    let icon: String
    let description: String
    let difficulty: String
    let products: [String]
}

struct RoutineTypeButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))

                Text(title)
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(isSelected ? .white : Color(UIColor.label))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ?
                          LinearGradient(colors: [Color(hex: "FF91A4"), Color(hex: "FFB6C1")],
                                       startPoint: .leading, endPoint: .trailing) :
                          LinearGradient(colors: [Color(UIColor.systemGray6), Color(UIColor.systemGray6)],
                                       startPoint: .leading, endPoint: .trailing))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.clear : Color(UIColor.systemGray5), lineWidth: 1)
            )
        }
    }
}

struct RoutineCard: View {
    let routine: BeautyRoutine
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "FFE4E1"), Color(hex: "FFB6C1").opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 48, height: 48)

                        Image(systemName: routine.icon)
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(Color(hex: "FF91A4"))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(routine.name)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(UIColor.label))

                        HStack(spacing: 12) {
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.system(size: 12))
                                Text(routine.duration)
                                    .font(.system(size: 13))
                            }

                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle")
                                    .font(.system(size: 12))
                                Text("\(routine.steps) steps")
                                    .font(.system(size: 13))
                            }

                            Spacer()

                            Text(routine.difficulty)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(hex: "FF91A4"))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color(hex: "FF91A4").opacity(0.1))
                                )
                        }
                        .foregroundColor(Color(UIColor.secondaryLabel))
                    }

                    Spacer()

                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(Color(hex: "FF91A4"))
                }

                Text(routine.description)
                    .font(.system(size: 14))
                    .foregroundColor(Color(UIColor.secondaryLabel))

                // Product preview
                if !routine.products.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(routine.products.prefix(3), id: \.self) { product in
                                Text(product)
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(UIColor.secondaryLabel))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(UIColor.systemGray6))
                                    )
                            }

                            if routine.products.count > 3 {
                                Text("+\(routine.products.count - 3) more")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color(hex: "FF91A4"))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(hex: "FF91A4").opacity(0.1))
                                    )
                            }
                        }
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(UIColor.systemGray6), lineWidth: 1)
            )
        }
    }
}

// MARK: - Routine Player View

struct RoutinePlayerView: View {
    let routine: BeautyRoutine
    @Environment(\.dismiss) var dismiss

    @State private var currentStep = 0
    @State private var timeRemaining = 60
    @State private var isPlaying = false
    @State private var timer: Timer?
    @State private var showProducts = false

    // Sample steps for each routine
    var routineSteps: [BeautyRoutineStep] {
        switch routine.name {
        case "Glass Skin Glow":
            return [
                BeautyRoutineStep(name: "Oil Cleanse", duration: 60, instruction: "Massage oil cleanser in circular motions", product: "Oil-based cleanser"),
                BeautyRoutineStep(name: "Water Cleanse", duration: 45, instruction: "Foam up water cleanser and massage gently", product: "Foaming cleanser"),
                BeautyRoutineStep(name: "Tone", duration: 30, instruction: "Pat toner into skin with hands", product: "Hydrating toner"),
                BeautyRoutineStep(name: "Essence", duration: 30, instruction: "Press essence into skin", product: "First treatment essence"),
                BeautyRoutineStep(name: "Serum", duration: 45, instruction: "Apply serum and pat until absorbed", product: "Hyaluronic acid serum"),
                BeautyRoutineStep(name: "Moisturize", duration: 60, instruction: "Apply moisturizer in upward strokes", product: "Gel moisturizer"),
                BeautyRoutineStep(name: "SPF", duration: 60, instruction: "Apply SPF evenly to face and neck", product: "Mineral SPF 50")
            ]
        case "5-Minute Fresh Face":
            return [
                BeautyRoutineStep(name: "Cleanse", duration: 60, instruction: "Swipe micellar water across face", product: "Micellar water"),
                BeautyRoutineStep(name: "Vitamin C", duration: 45, instruction: "Apply vitamin C serum to face", product: "Vitamin C serum"),
                BeautyRoutineStep(name: "Moisturize", duration: 60, instruction: "Apply lightweight moisturizer", product: "Day cream"),
                BeautyRoutineStep(name: "SPF", duration: 60, instruction: "Apply sun protection", product: "SPF 30+")
            ]
        case "Gua Sha Sculpt":
            return [
                BeautyRoutineStep(name: "Oil Prep", duration: 30, instruction: "Apply facial oil generously", product: "Facial oil"),
                BeautyRoutineStep(name: "Neck Drainage", duration: 120, instruction: "Sweep gua sha down neck 10 times each side", product: "Gua sha stone"),
                BeautyRoutineStep(name: "Jawline Sculpt", duration: 180, instruction: "Glide along jawline from chin to ear", product: "Gua sha stone"),
                BeautyRoutineStep(name: "Cheek Lift", duration: 180, instruction: "Sweep from nose to temple in upward motion", product: "Gua sha stone"),
                BeautyRoutineStep(name: "Eye Area", duration: 90, instruction: "Gentle sweeps under eyes outward", product: "Gua sha stone")
            ]
        default:
            return [
                BeautyRoutineStep(name: "Cleanse", duration: 60, instruction: "Cleanse face thoroughly", product: "Cleanser"),
                BeautyRoutineStep(name: "Treat", duration: 60, instruction: "Apply treatment product", product: "Treatment"),
                BeautyRoutineStep(name: "Moisturize", duration: 60, instruction: "Apply moisturizer", product: "Moisturizer")
            ]
        }
    }

    var currentStepData: BeautyRoutineStep? {
        guard currentStep < routineSteps.count else { return nil }
        return routineSteps[currentStep]
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: {
                            timer?.invalidate()
                            dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(Color(UIColor.systemGray3))
                        }

                        Spacer()

                        Text(routine.name)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color(UIColor.label))

                        Spacer()

                        Button(action: {
                            showProducts.toggle()
                            hapticFeedback(.light)
                        }) {
                            Image(systemName: "bag.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(Color(hex: "FF91A4"))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)

                    // Progress
                    HStack(spacing: 4) {
                        ForEach(0..<routineSteps.count, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(index <= currentStep ? Color(hex: "FF91A4") : Color(UIColor.systemGray5))
                                .frame(height: 4)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)

                    if let step = currentStepData {
                        // Current step display
                        VStack(spacing: 32) {
                            // Timer circle
                            ZStack {
                                Circle()
                                    .stroke(Color(UIColor.systemGray6), lineWidth: 8)
                                    .frame(width: 200, height: 200)

                                Circle()
                                    .trim(from: 0, to: CGFloat(timeRemaining) / CGFloat(step.duration))
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color(hex: "FF91A4"), Color(hex: "FFB6C1")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                    )
                                    .frame(width: 200, height: 200)
                                    .rotationEffect(Angle(degrees: -90))

                                VStack(spacing: 8) {
                                    Text("\(timeRemaining)")
                                        .font(.system(size: 48, weight: .bold, design: .rounded))
                                        .foregroundColor(Color(UIColor.label))

                                    Text("seconds")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color(UIColor.secondaryLabel))
                                }
                            }

                            // Step info
                            VStack(spacing: 16) {
                                Text("Step \(currentStep + 1) of \(routineSteps.count)")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: "FF91A4"))

                                Text(step.name)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(Color(UIColor.label))

                                Text(step.instruction)
                                    .font(.system(size: 17))
                                    .foregroundColor(Color(UIColor.secondaryLabel))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)

                                if !step.product.isEmpty {
                                    HStack {
                                        Image(systemName: "drop.circle.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color(hex: "FFB6C1"))

                                        Text("Using: \(step.product)")
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(Color(UIColor.secondaryLabel))
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color(UIColor.systemGray6))
                                    )
                                }
                            }

                            Spacer()

                            // Control buttons
                            HStack(spacing: 32) {
                                Button(action: previousStep) {
                                    Image(systemName: "backward.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(currentStep > 0 ? Color(hex: "FF91A4") : Color(UIColor.systemGray4))
                                }
                                .disabled(currentStep == 0)

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
                                            .frame(width: 80, height: 80)

                                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                            .font(.system(size: 30))
                                            .foregroundColor(.white)
                                            .offset(x: isPlaying ? 0 : 3)
                                    }
                                }

                                Button(action: nextStep) {
                                    Image(systemName: "forward.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(Color(hex: "FF91A4"))
                                }
                            }

                            Spacer()
                        }
                    } else {
                        // Completion view
                        VStack(spacing: 32) {
                            Spacer()

                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(Color(hex: "FF91A4"))

                            VStack(spacing: 8) {
                                Text("Routine Complete!")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(Color(UIColor.label))

                                Text("Your skin is glowing!")
                                    .font(.system(size: 17))
                                    .foregroundColor(Color(UIColor.secondaryLabel))
                            }

                            Button(action: { dismiss() }) {
                                Text("Done")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 200, height: 50)
                                    .background(
                                        LinearGradient(
                                            colors: [Color(hex: "FF91A4"), Color(hex: "FFB6C1")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 25))
                            }

                            Spacer()
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showProducts) {
            ProductListView(products: routine.products)
        }
        .onAppear {
            if let step = currentStepData {
                timeRemaining = step.duration
            }
        }
    }

    private func togglePlayPause() {
        hapticFeedback(.light)
        isPlaying.toggle()

        if isPlaying {
            startTimer()
        } else {
            timer?.invalidate()
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                nextStep()
            }
        }
    }

    private func nextStep() {
        hapticFeedback(.light)
        timer?.invalidate()
        isPlaying = false

        if currentStep < routineSteps.count - 1 {
            currentStep += 1
            if let step = currentStepData {
                timeRemaining = step.duration
            }
        } else {
            currentStep = routineSteps.count // Show completion
            let notificationGenerator = UINotificationFeedbackGenerator()
            notificationGenerator.prepare()
            notificationGenerator.notificationOccurred(.success)
        }
    }

    private func previousStep() {
        hapticFeedback(.light)
        timer?.invalidate()
        isPlaying = false

        if currentStep > 0 {
            currentStep -= 1
            if let step = currentStepData {
                timeRemaining = step.duration
            }
        }
    }
}

struct BeautyRoutineStep {
    let name: String
    let duration: Int
    let instruction: String
    let product: String
}

struct ProductListView: View {
    let products: [String]
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            headerView
            productScrollView
        }
        .background(Color(UIColor.systemBackground))
    }

    private var headerView: some View {
        HStack {
            Text("Products Needed")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(UIColor.label))

            Spacer()

            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(UIColor.systemGray3))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
    }

    private var productScrollView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(products.enumerated()), id: \.offset) { index, product in
                    productRow(index: index, product: product)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func productRow(index: Int, product: String) -> some View {
        HStack(spacing: 16) {
            Text("\(index + 1)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(Color(hex: "FF91A4"))
                )

            Text(product)
                .font(.system(size: 17))
                .foregroundColor(Color(UIColor.label))

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemGray6))
        )
    }
}

func hapticFeedback(_ type: UINotificationFeedbackGenerator.FeedbackType) {
    let generator = UINotificationFeedbackGenerator()
    generator.prepare()
    generator.notificationOccurred(type)
}

#Preview {
    HomeView()
}