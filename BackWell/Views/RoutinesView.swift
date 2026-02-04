//
//  RoutinesView.swift
//  SkinGlowing
//
//  Beauty routines view with step-by-step timers

import SwiftUI

struct RoutinesView: View {
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
                Color(uiColor: UIColor.systemBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
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
                            .padding(.horizontal, 20)
                        }
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
                                    .foregroundColor(Color(uiColor: UIColor.secondaryLabel))
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
            .navigationTitle("Beauty Routines")
            .navigationBarTitleDisplayMode(.large)
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

#Preview {
    RoutinesView()
}