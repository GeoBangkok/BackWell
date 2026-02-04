//
//  RoutineComponents.swift
//  SkinGlowing
//
//  Reusable components for beauty routines
//

import SwiftUI

// MARK: - Routine Type Button
struct RoutineTypeButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : Color(hex: "FF91A4"))

                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .white : Color(uiColor: UIColor.label))
            }
            .frame(width: 80, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color(hex: "FF91A4") : Color(uiColor: UIColor.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.clear : Color(uiColor: UIColor.systemGray5), lineWidth: 1)
            )
        }
    }
}

// MARK: - Routine Card
struct RoutineCard: View {
    let routine: BeautyRoutine
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "FFE4E1"), Color(hex: "FFB6C1")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)

                    Image(systemName: routine.icon)
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: "FF91A4"))
                }

                // Content
                VStack(alignment: .leading, spacing: 6) {
                    Text(routine.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(uiColor: UIColor.label))

                    Text(routine.description)
                        .font(.system(size: 14))
                        .foregroundColor(Color(uiColor: UIColor.secondaryLabel))
                        .lineLimit(1)

                    HStack(spacing: 12) {
                        // Duration
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 12))
                            Text(routine.duration)
                                .font(.system(size: 12))
                        }
                        .foregroundColor(Color(uiColor: UIColor.tertiaryLabel))

                        // Steps
                        HStack(spacing: 4) {
                            Image(systemName: "list.number")
                                .font(.system(size: 12))
                            Text("\(routine.steps) steps")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(Color(uiColor: UIColor.tertiaryLabel))

                        // Difficulty
                        Text(routine.difficulty)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(difficultyColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(difficultyColor.opacity(0.1))
                            .cornerRadius(8)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(Color(uiColor: UIColor.tertiaryLabel))
            }
            .padding(16)
            .background(Color(uiColor: UIColor.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }

    private var difficultyColor: Color {
        switch routine.difficulty {
        case "Beginner":
            return .green
        case "Intermediate":
            return .orange
        case "Advanced":
            return Color(hex: "FF91A4")
        case "Personalized":
            return .purple
        default:
            return Color(uiColor: UIColor.label)
        }
    }
}

