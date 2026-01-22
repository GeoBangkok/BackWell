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
    @State private var selectedDayProgram: DayProgram? = nil
    @State private var showSubscriptionRequired = false
    @State private var showCitations = false

    @ObservedObject private var storeManager = StoreManager.shared

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundGradient
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Your 28-Day Challenge")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(Theme.textPrimary)

                            Text("Day \(currentDay) of 28")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(Theme.textSecondary)

                            // Citations button
                            Button(action: {
                                showCitations = true
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "book.closed.fill")
                                        .font(.system(size: 12))
                                    Text("View Research")
                                        .font(.system(size: 13, weight: .medium))
                                }
                                .foregroundColor(Theme.teal)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Theme.teal.opacity(0.1))
                                )
                            }
                            .padding(.top, 4)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 10)

                        // Progress bar
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Progress")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Theme.textSecondary)

                                Spacer()

                                Text("\(completedDays.count)/28")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Theme.teal)
                            }

                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white.opacity(0.5))
                                        .frame(height: 8)

                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Theme.teal)
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
                                        // Check if user has access to this day
                                        if storeManager.hasAccessToDay(day) {
                                            selectedDayProgram = ExerciseDatabase.getDay(day)
                                        } else {
                                            // Show subscription required alert
                                            showSubscriptionRequired = true
                                        }
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
                                    .foregroundColor(Theme.textPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Text("Continue your journey with hundreds more exercises")
                                    .font(.system(size: 15, weight: .regular))
                                    .foregroundColor(Theme.textSecondary)
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
                                        title: "Flexibility + Mobility",
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
            .navigationDestination(item: $selectedDayProgram) { dayProgram in
                ExercisePlayerView(dayProgram: dayProgram)
                    .navigationBarBackButtonHidden(true)
                    .onDisappear {
                        // Mark day as completed when player is dismissed
                        completedDays.insert(dayProgram.day)
                        // Move to next day if current
                        if dayProgram.day == currentDay && currentDay < 28 {
                            currentDay += 1
                        }
                    }
            }
            .alert("Subscription Required", isPresented: $showSubscriptionRequired) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Days 4-28 require an active subscription. Subscribe to continue your journey!")
            }
            .sheet(isPresented: $showCitations) {
                WorksCitedView(onContinue: {
                    showCitations = false
                })
            }
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
                        Theme.teal :
                        isCurrent ?
                        Color.white.opacity(0.8) :
                        Color.white.opacity(0.4)
                    )
                    .frame(height: 80)
                    .shadow(
                        color: isCurrent ? Theme.teal.opacity(0.3) : Color.clear,
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
                            .foregroundColor(Theme.textMuted.opacity(0.5))
                    } else {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Theme.teal)
                    }

                    Text("Day \(day)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(
                            isCompleted ? .white :
                            isLocked ? Theme.textMuted.opacity(0.5) :
                            Theme.textPrimary
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
                    .fill(Theme.teal.opacity(0.1))
                    .frame(width: 60, height: 60)

                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(Theme.teal)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)

                Text("\(exerciseCount) exercises")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Theme.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 16))
                .foregroundColor(Theme.textMuted)
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
