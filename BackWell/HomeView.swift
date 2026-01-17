//
//  HomeView.swift
//  BackWell
//
//  Created by standard on 1/17/26.
//

import SwiftUI

struct HomeView: View {
    @State private var currentDay = 1 // Track user's current day
    @State private var completedDays: Set<Int> = [] // Days completed

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationView {
            ZStack {
                // Same calming gradient
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

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Your 28-Day Challenge")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.5))

                            Text("Day \(currentDay) of 28")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.6))
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 10)

                        // Progress bar
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Progress")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.6))

                                Spacer()

                                Text("\(completedDays.count)/28")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(red: 0.3, green: 0.6, blue: 0.7))
                            }

                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white.opacity(0.5))
                                        .frame(height: 8)

                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(red: 0.3, green: 0.6, blue: 0.7))
                                        .frame(width: geometry.size.width * (CGFloat(completedDays.count) / 28.0), height: 8)
                                }
                            }
                            .frame(height: 8)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 12)

                        // 28-Day Grid
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(1...28, id: \.self) { day in
                                DayCard(
                                    day: day,
                                    isCompleted: completedDays.contains(day),
                                    isCurrent: day == currentDay,
                                    isLocked: day > currentDay
                                )
                                .onTapGesture {
                                    if day <= currentDay {
                                        // Navigate to day's exercises
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)

                        // More Exercises section (shown after day 28)
                        if currentDay > 28 {
                            VStack(spacing: 16) {
                                Divider()
                                    .padding(.vertical, 8)

                                Text("More Exercises")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.5))
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Text("Continue your journey with hundreds more exercises")
                                    .font(.system(size: 15, weight: .regular))
                                    .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.6))
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                // Exercise categories
                                VStack(spacing: 12) {
                                    ExerciseCategoryCard(
                                        title: "Lower Back Relief",
                                        exerciseCount: 45,
                                        icon: "figure.walk"
                                    )

                                    ExerciseCategoryCard(
                                        title: "Core Strengthening",
                                        exerciseCount: 38,
                                        icon: "figure.strengthtraining.traditional"
                                    )

                                    ExerciseCategoryCard(
                                        title: "Flexibility & Mobility",
                                        exerciseCount: 52,
                                        icon: "figure.flexibility"
                                    )

                                    ExerciseCategoryCard(
                                        title: "Posture Correction",
                                        exerciseCount: 29,
                                        icon: "figure.stand"
                                    )
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                        }

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct DayCard: View {
    let day: Int
    let isCompleted: Bool
    let isCurrent: Bool
    let isLocked: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isCompleted ?
                        Color(red: 0.3, green: 0.6, blue: 0.7) :
                        isCurrent ?
                        Color.white.opacity(0.8) :
                        Color.white.opacity(0.4)
                    )
                    .frame(height: 80)
                    .shadow(
                        color: isCurrent ? Color(red: 0.3, green: 0.6, blue: 0.7).opacity(0.3) : Color.clear,
                        radius: 8,
                        x: 0,
                        y: 4
                    )

                VStack(spacing: 4) {
                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    } else if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(red: 0.5, green: 0.6, blue: 0.65).opacity(0.5))
                    } else {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(red: 0.3, green: 0.6, blue: 0.7))
                    }

                    Text("Day \(day)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(
                            isCompleted ? .white :
                            isLocked ? Color(red: 0.5, green: 0.6, blue: 0.65).opacity(0.5) :
                            Color(red: 0.2, green: 0.4, blue: 0.5)
                        )
                }
            }
        }
    }
}

struct ExerciseCategoryCard: View {
    let title: String
    let exerciseCount: Int
    let icon: String

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.3, green: 0.6, blue: 0.7).opacity(0.1))
                    .frame(width: 60, height: 60)

                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(Color(red: 0.3, green: 0.6, blue: 0.7))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.5))

                Text("\(exerciseCount) exercises")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.6))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 16))
                .foregroundColor(Color(red: 0.5, green: 0.6, blue: 0.65))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.6))
        )
    }
}

#Preview {
    HomeView()
}
