//
//  RoutinesView.swift
//  SkinGlowing
//
//  Modern beauty routines view with white/pink design
//

import SwiftUI

struct RoutinesView: View {
    @State private var selectedRoutineType = "morning"
    @State private var showingRoutinePlayer = false
    @State private var selectedRoutine: BeautyRoutine?
    @State private var isGeneratingRoutine = false
    @State private var generatedRoutines: [BeautyRoutine] = []

    // Beauty routines with SF Symbols
    let morningRoutines = [
        BeautyRoutine(
            id: UUID(),
            name: "Glass Skin Glow",
            duration: "12 min",
            steps: 7,
            icon: "sparkle",
            description: "Korean-inspired dewy skin routine",
            difficulty: "Intermediate",
            products: ["Oil cleanser", "Water-based cleanser", "Toner", "Essence", "Serum", "Moisturizer", "SPF"]
        ),
        BeautyRoutine(
            id: UUID(),
            name: "5-Minute Fresh",
            duration: "5 min",
            steps: 4,
            icon: "clock.badge.checkmark",
            description: "Quick morning refresh",
            difficulty: "Beginner",
            products: ["Micellar water", "Vitamin C serum", "Moisturizer", "SPF"]
        ),
        BeautyRoutine(
            id: UUID(),
            name: "Gua Sha Sculpt",
            duration: "15 min",
            steps: 5,
            icon: "face.smiling",
            description: "Lymphatic drainage massage",
            difficulty: "Advanced",
            products: ["Facial oil", "Gua sha stone", "Serum", "Eye cream", "Moisturizer"]
        )
    ]

    let eveningRoutines = [
        BeautyRoutine(
            id: UUID(),
            name: "Slugging Protocol",
            duration: "10 min",
            steps: 5,
            icon: "moon.stars.fill",
            description: "Intense overnight hydration",
            difficulty: "Intermediate",
            products: ["Double cleanse", "Hydrating toner", "Hyaluronic acid", "Thick moisturizer", "Petroleum jelly"]
        ),
        BeautyRoutine(
            id: UUID(),
            name: "Retinol Power",
            duration: "8 min",
            steps: 6,
            icon: "star.fill",
            description: "Anti-aging night routine",
            difficulty: "Advanced",
            products: ["Cleansing balm", "Gentle cleanser", "Retinol treatment", "Peptide serum", "Night cream", "Eye cream"]
        ),
        BeautyRoutine(
            id: UUID(),
            name: "Barrier Repair",
            duration: "10 min",
            steps: 5,
            icon: "shield.fill",
            description: "Restore and strengthen",
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
            icon: "figure.mind.and.body",
            description: "Natural facelift exercises",
            difficulty: "Intermediate",
            products: ["Face oil for massage"]
        ),
        BeautyRoutine(
            id: UUID(),
            name: "Ice Facial",
            duration: "7 min",
            steps: 4,
            icon: "snowflake",
            description: "Pore tightening treatment",
            difficulty: "Beginner",
            products: ["Ice roller", "Hydrating serum", "Moisturizer", "Eye cream"]
        ),
        BeautyRoutine(
            id: UUID(),
            name: "Honey Glow Mask",
            duration: "25 min",
            steps: 5,
            icon: "drop.circle.fill",
            description: "DIY hydrating treatment",
            difficulty: "Beginner",
            products: ["Raw honey", "Yogurt", "Turmeric powder", "Face oil", "Moisturizer"]
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
                Color.white
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Header with gradient
                        LinearGradient(
                            colors: [
                                Color(hex: "FFE4E1").opacity(0.3),
                                Color.white
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 20)

                        // Routine type selector - Modern pills
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ModernRoutineTypeButton(
                                    title: "Morning",
                                    icon: "sun.max.fill",
                                    isSelected: selectedRoutineType == "morning",
                                    action: {
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedRoutineType = "morning"
                                        }
                                        hapticFeedback(.light)
                                    }
                                )

                                ModernRoutineTypeButton(
                                    title: "Evening",
                                    icon: "moon.fill",
                                    isSelected: selectedRoutineType == "evening",
                                    action: {
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedRoutineType = "evening"
                                        }
                                        hapticFeedback(.light)
                                    }
                                )

                                ModernRoutineTypeButton(
                                    title: "Special",
                                    icon: "star.fill",
                                    isSelected: selectedRoutineType == "special",
                                    action: {
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedRoutineType = "special"
                                        }
                                        hapticFeedback(.light)
                                    }
                                )

                                ModernRoutineTypeButton(
                                    title: "AI Made",
                                    icon: "wand.and.stars",
                                    isSelected: selectedRoutineType == "generated",
                                    action: {
                                        withAnimation(.spring(response: 0.3)) {
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
                        .padding(.vertical, 20)

                        // Routines list
                        if selectedRoutineType == "generated" && isGeneratingRoutine {
                            // Loading state for AI generation
                            VStack(spacing: 20) {
                                ZStack {
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                colors: [Color(hex: "FF91A4"), Color(hex: "FFB6C1")],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 3
                                        )
                                        .frame(width: 60, height: 60)
                                        .rotationEffect(.degrees(360))
                                        .animation(
                                            Animation.linear(duration: 1)
                                                .repeatForever(autoreverses: false),
                                            value: isGeneratingRoutine
                                        )

                                    Image(systemName: "wand.and.stars")
                                        .font(.system(size: 24))
                                        .foregroundColor(Color(hex: "FF91A4"))
                                }

                                Text("Creating personalized routines...")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color(hex: "FF91A4"))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 300)
                        } else {
                            LazyVStack(spacing: 16) {
                                ForEach(currentRoutines) { routine in
                                    ModernRoutineCard(routine: routine) {
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
            ModernRoutinePlayerView(routine: routine)
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
                        description: "Customized for your skin",
                        difficulty: "Personalized",
                        products: ["Gentle foam cleanser", "PH balancing toner", "Niacinamide serum", "Peptide moisturizer", "Mineral SPF 50"]
                    ),
                    BeautyRoutine(
                        id: UUID(),
                        name: "Targeted Treatment",
                        duration: "15 min",
                        steps: 7,
                        icon: "target",
                        description: "Address specific concerns",
                        difficulty: "Personalized",
                        products: ["Micellar water", "BHA toner", "Vitamin C serum", "Retinol alternative", "Barrier cream"]
                    ),
                    BeautyRoutine(
                        id: UUID(),
                        name: "Weekly Reset",
                        duration: "30 min",
                        steps: 9,
                        icon: "arrow.clockwise",
                        description: "Deep treatment ritual",
                        difficulty: "Personalized",
                        products: ["Oil cleanser", "Enzyme exfoliant", "Clay mask", "Hydrating mask", "Face oil"]
                    )
                ]
                isGeneratingRoutine = false
            }
        }
    }
}

// Modern Routine Type Button
struct ModernRoutineTypeButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))

                Text(title)
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(isSelected ? .white : Color(hex: "FF91A4"))
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                isSelected ?
                LinearGradient(
                    colors: [Color(hex: "FF91A4"), Color(hex: "FFB6C1")],
                    startPoint: .leading,
                    endPoint: .trailing
                ) :
                LinearGradient(
                    colors: [Color.white, Color.white],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected ? Color.clear : Color(hex: "FFB6C1"),
                        lineWidth: 1.5
                    )
            )
            .shadow(
                color: isSelected ? Color(hex: "FF91A4").opacity(0.3) : Color.black.opacity(0.05),
                radius: isSelected ? 8 : 4,
                x: 0,
                y: isSelected ? 4 : 2
            )
        }
    }
}

// Modern Routine Card
struct ModernRoutineCard: View {
    let routine: BeautyRoutine
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                // Top section with icon and title
                HStack(spacing: 16) {
                    // Icon with gradient background
                    ZStack {
                        LinearGradient(
                            colors: [
                                Color(hex: "FFE4E1").opacity(0.5),
                                Color(hex: "FFB6C1").opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(width: 50, height: 50)
                        .cornerRadius(15)

                        Image(systemName: routine.icon)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(Color(hex: "FF91A4"))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(routine.name)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(uiColor: .label))

                        Text(routine.description)
                            .font(.system(size: 14))
                            .foregroundColor(Color(uiColor: .secondaryLabel))
                    }

                    Spacer()

                    // Start button
                    ZStack {
                        Circle()
                            .fill(Color(hex: "FF91A4"))
                            .frame(width: 40, height: 40)

                        Image(systemName: "play.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                }
                .padding(20)

                // Bottom section with details
                HStack(spacing: 20) {
                    // Duration
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "FF91A4"))
                        Text(routine.duration)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(uiColor: .label))
                    }

                    // Steps
                    HStack(spacing: 6) {
                        Image(systemName: "list.number")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "FF91A4"))
                        Text("\(routine.steps) steps")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(uiColor: .label))
                    }

                    Spacer()

                    // Difficulty badge
                    Text(routine.difficulty)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(difficultyColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(difficultyColor.opacity(0.1))
                        .cornerRadius(10)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .background(
                    Color(hex: "FFE4E1").opacity(0.1)
                )
            }
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color(hex: "FF91A4").opacity(0.1), radius: 10, x: 0, y: 5)
        }
    }

    private var difficultyColor: Color {
        switch routine.difficulty {
        case "Beginner":
            return Color(hex: "4CAF50")
        case "Intermediate":
            return Color(hex: "FF9800")
        case "Advanced":
            return Color(hex: "F44336")
        case "Personalized":
            return Color(hex: "FF91A4")
        default:
            return Color(uiColor: .label)
        }
    }
}

#Preview {
    RoutinesView()
}