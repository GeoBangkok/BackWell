//
//  ArchiveView.swift
//  SkinGlowing
//
//  Modern archive view for skin scan history
//

import SwiftUI

struct ArchiveView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedTimeRange = "All"
    @State private var searchText = ""
    @State private var selectedEntry: SkinScanResult?

    // Sample data for demonstration
    @State private var scanHistory: [SkinScanResult] = [
        SkinScanResult(
            metrics: SkinMetrics(
                overallScore: 87,
                hydration: 78,
                acne: 92,
                glow: 85,
                aging: 88,
                timestamp: Date().addingTimeInterval(-86400)
            ),
            imageData: nil,
            recommendations: ["Use vitamin C serum", "Increase water intake"],
            routineSteps: [],
            timestamp: Date().addingTimeInterval(-86400),
            userConcerns: ["Dark spots", "Dryness"],
            skinType: "Combination"
        ),
        SkinScanResult(
            metrics: SkinMetrics(
                overallScore: 83,
                hydration: 72,
                acne: 88,
                glow: 80,
                aging: 85,
                timestamp: Date().addingTimeInterval(-259200)
            ),
            imageData: nil,
            recommendations: ["Add retinol", "Use SPF daily"],
            routineSteps: [],
            timestamp: Date().addingTimeInterval(-259200),
            userConcerns: ["Fine lines", "Uneven tone"],
            skinType: "Combination"
        ),
        SkinScanResult(
            metrics: SkinMetrics(
                overallScore: 79,
                hydration: 68,
                acne: 85,
                glow: 75,
                aging: 82,
                timestamp: Date().addingTimeInterval(-604800)
            ),
            imageData: nil,
            recommendations: ["Exfoliate 2x weekly", "Hydrating mask"],
            routineSteps: [],
            timestamp: Date().addingTimeInterval(-604800),
            userConcerns: ["Dullness", "Large pores"],
            skinType: "Combination"
        )
    ]

    var filteredScans: [SkinScanResult] {
        var results = scanHistory

        // Filter by time range
        if selectedTimeRange != "All" {
            let now = Date()
            let calendar = Calendar.current

            switch selectedTimeRange {
            case "Week":
                if let weekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: now) {
                    results = results.filter { $0.timestamp >= weekAgo }
                }
            case "Month":
                if let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) {
                    results = results.filter { $0.timestamp >= monthAgo }
                }
            case "3 Months":
                if let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: now) {
                    results = results.filter { $0.timestamp >= threeMonthsAgo }
                }
            default:
                break
            }
        }

        // Filter by search
        if !searchText.isEmpty {
            results = results.filter { scan in
                scan.userConcerns.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }

        return results
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Clean white background
                Color.white
                    .ignoresSafeArea()

                if scanHistory.isEmpty {
                    // Empty state
                    VStack(spacing: 24) {
                        Image(systemName: "archivebox")
                            .font(.system(size: 60))
                            .foregroundColor(Color(hex: "FF91A4").opacity(0.5))

                        Text("No Scans Yet")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(Color(uiColor: .label))

                        Text("Your skin analysis history will appear here")
                            .font(.system(size: 16))
                            .foregroundColor(Color(uiColor: .secondaryLabel))
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
                            // Stats overview
                            HStack(spacing: 20) {
                                StatCard(
                                    value: "\(scanHistory.count)",
                                    label: "Total Scans",
                                    icon: "camera.fill",
                                    color: Color(hex: "FF91A4")
                                )

                                StatCard(
                                    value: "\(averageScore)",
                                    label: "Avg Score",
                                    icon: "chart.line.uptrend.xyaxis",
                                    color: Color(hex: "FFB6C1")
                                )

                                StatCard(
                                    value: "+\(improvement)%",
                                    label: "Improvement",
                                    icon: "arrow.up.circle.fill",
                                    color: .green
                                )
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)

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
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                            }

                            // Progress Chart placeholder
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Your Progress")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(Color(uiColor: .label))

                                // Chart placeholder
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
                                                .foregroundColor(Color(uiColor: .secondaryLabel))
                                        }
                                    )
                            }
                            .padding(.horizontal, 20)

                            // Scan history list
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Recent Scans")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(Color(uiColor: .label))
                                    .padding(.horizontal, 20)

                                ForEach(filteredScans) { scan in
                                    ScanHistoryCard(scan: scan)
                                        .onTapGesture {
                                            selectedEntry = scan
                                        }
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
            .searchable(text: $searchText, prompt: "Search concerns")
            .sheet(item: $selectedEntry) { entry in
                ScanDetailView(scan: entry)
            }
        }
    }

    private var averageScore: Int {
        guard !scanHistory.isEmpty else { return 0 }
        let total = scanHistory.reduce(0) { $0 + $1.metrics.overallScore }
        return total / scanHistory.count
    }

    private var improvement: Int {
        guard scanHistory.count >= 2 else { return 0 }
        let latest = scanHistory.first?.metrics.overallScore ?? 0
        let oldest = scanHistory.last?.metrics.overallScore ?? 0
        return max(0, latest - oldest)
    }
}

struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(uiColor: .label))

            Text(label)
                .font(.system(size: 12))
                .foregroundColor(Color(uiColor: .secondaryLabel))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct ArchiveFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(isSelected ? .white : Color(uiColor: .label))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color(hex: "FF91A4") : Color(uiColor: .systemGray6))
                )
        }
    }
}

struct ScanHistoryCard: View {
    let scan: SkinScanResult

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }

    var body: some View {
        HStack {
            // Date section
            VStack(alignment: .leading, spacing: 4) {
                Text(dateFormatter.string(from: scan.timestamp))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(uiColor: .label))

                HStack {
                    ForEach(scan.userConcerns.prefix(2), id: \.self) { concern in
                        Text(concern)
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "FF91A4"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color(hex: "FFE4E1").opacity(0.3))
                            .cornerRadius(6)
                    }
                }
            }

            Spacer()

            // Score section
            VStack(spacing: 4) {
                Text("\(scan.metrics.overallScore)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(hex: "FF91A4"))

                Text("Score")
                    .font(.system(size: 12))
                    .foregroundColor(Color(uiColor: .secondaryLabel))
            }

            // Improvement indicator
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(Color(uiColor: .tertiaryLabel))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(uiColor: .systemGray6), lineWidth: 1)
        )
    }
}

struct ScanDetailView: View {
    let scan: SkinScanResult
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    // Score
                    ZStack {
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color(hex: "FFE4E1"), Color(hex: "FFB6C1")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 12
                            )
                            .frame(width: 150, height: 150)

                        VStack {
                            Text("\(scan.metrics.overallScore)")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "FF91A4"))

                            Text("Overall Score")
                                .font(.system(size: 14))
                                .foregroundColor(Color(uiColor: .secondaryLabel))
                        }
                    }
                    .padding(.top, 20)

                    // Metrics
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ArchiveMetricDetailCard(
                            icon: "drop.fill",
                            title: "Hydration",
                            value: scan.metrics.hydration,
                            status: scan.metrics.hydrationLevel,
                            color: .blue
                        )

                        ArchiveMetricDetailCard(
                            icon: "sparkles",
                            title: "Glow",
                            value: scan.metrics.glow,
                            status: scan.metrics.glowLevel,
                            color: Color(hex: "FFD700")
                        )

                        ArchiveMetricDetailCard(
                            icon: "shield.fill",
                            title: "Clarity",
                            value: scan.metrics.acne,
                            status: scan.metrics.acneStatus,
                            color: .green
                        )

                        ArchiveMetricDetailCard(
                            icon: "clock.fill",
                            title: "Youth",
                            value: scan.metrics.aging,
                            status: scan.metrics.agingStatus,
                            color: .purple
                        )
                    }
                    .padding(.horizontal, 20)

                    // Recommendations
                    if !scan.recommendations.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recommendations")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color(uiColor: .label))

                            ForEach(scan.recommendations, id: \.self) { rec in
                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color(hex: "FF91A4"))
                                        .font(.system(size: 16))

                                    Text(rec)
                                        .font(.system(size: 15))
                                        .foregroundColor(Color(uiColor: .secondaryLabel))

                                    Spacer()
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 30)
            }
            .navigationTitle("Scan Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Color(hex: "FF91A4"))
                }
            }
        }
    }
}

struct ArchiveMetricDetailCard: View {
    let icon: String
    let title: String
    let value: Int
    let status: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)

            Text("\(value)%")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(uiColor: .label))

            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(uiColor: .secondaryLabel))

            Text(status)
                .font(.system(size: 11))
                .foregroundColor(color)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(color.opacity(0.1))
                .cornerRadius(6)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(uiColor: .systemGray6).opacity(0.5))
        .cornerRadius(16)
    }
}

#Preview {
    ArchiveView()
}