//
//  NewArchiveView.swift
//  SkinGlowing
//
//  Archive view for skin scan history - iOS Health style

import SwiftUI

struct NewArchiveView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedTimeRange = "All"
    @State private var searchText = ""

    // Sample data - would be loaded from storage
    let sampleScans: [SkinScanResult] = []

    var filteredScans: [SkinScanResult] {
        // Filter logic would go here
        return sampleScans
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Clean white background
                Color(uiColor: UIColor.systemBackground)
                    .ignoresSafeArea()

                if sampleScans.isEmpty {
                    // Empty state
                    VStack(spacing: 24) {
                        Image(systemName: "archivebox")
                            .font(.system(size: 60))
                            .foregroundColor(Color(hex: "FF91A4").opacity(0.5))

                        Text("No Scans Yet")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(Color(uiColor: UIColor.label))

                        Text("Your skin analysis history will appear here")
                            .font(.system(size: 16))
                            .foregroundColor(Color(uiColor: UIColor.secondaryLabel))
                            .multilineTextAlignment(.center)

                        Button(action: {
                            dismiss()
                        }) {
                            Text("Take Your First Scan")
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
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Time range filter
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(["All", "Week", "Month", "3 Months"], id: \.self) { range in
                                        FilterChip(
                                            title: range,
                                            isSelected: selectedTimeRange == range,
                                            action: {
                                                withAnimation {
                                                    selectedTimeRange = range
                                                }
                                                hapticFeedback(.light)
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            .padding(.top, 10)

                            // Progress Chart
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Your Progress")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(Color(uiColor: UIColor.label))

                                // Placeholder for chart
                                RoundedRectangle(cornerRadius: 16)
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
                                    .frame(height: 200)
                                    .overlay(
                                        VStack {
                                            Image(systemName: "chart.line.uptrend.xyaxis")
                                                .font(.system(size: 40))
                                                .foregroundColor(Color(hex: "FF91A4"))
                                            Text("Progress Chart")
                                                .font(.system(size: 16))
                                                .foregroundColor(Color(uiColor: UIColor.secondaryLabel))
                                        }
                                    )
                            }
                            .padding(.horizontal, 20)

                            // Scan History List
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Recent Scans")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(Color(uiColor: UIColor.label))
                                    .padding(.horizontal, 20)

                                ForEach(0..<3, id: \.self) { index in
                                    ScanHistoryCard(
                                        date: Date().addingTimeInterval(Double(-index * 86400)),
                                        score: 85 - (index * 3),
                                        improvement: index == 0 ? "+3%" : "+\(5 - index)%"
                                    )
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                        .padding(.vertical, 20)
                    }
                }
            }
            .navigationTitle("Scan History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "FF91A4"))
                }
            }
            .searchable(text: $searchText, prompt: "Search scans")
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(isSelected ? .white : Color(uiColor: UIColor.label))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color(hex: "FF91A4") : Color(uiColor: UIColor.systemGray6))
                )
        }
    }
}

struct ScanHistoryCard: View {
    let date: Date
    let score: Int
    let improvement: String

    var body: some View {
        HStack {
            // Date section
            VStack(alignment: .leading, spacing: 4) {
                Text(date.formatted(.dateTime.weekday(.abbreviated).month().day()))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(uiColor: UIColor.label))

                Text(date.formatted(.dateTime.hour().minute()))
                    .font(.system(size: 14))
                    .foregroundColor(Color(uiColor: UIColor.secondaryLabel))
            }

            Spacer()

            // Score section
            VStack(spacing: 4) {
                Text("\(score)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(hex: "FF91A4"))

                Text("Score")
                    .font(.system(size: 12))
                    .foregroundColor(Color(uiColor: UIColor.secondaryLabel))
            }

            // Improvement indicator
            HStack(spacing: 4) {
                Image(systemName: improvement.hasPrefix("+") ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(improvement.hasPrefix("+") ? .green : .red)

                Text(improvement)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(improvement.hasPrefix("+") ? .green : .red)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(uiColor: UIColor.systemGray6), lineWidth: 1)
        )
    }
}

#Preview {
    NewArchiveView()
}