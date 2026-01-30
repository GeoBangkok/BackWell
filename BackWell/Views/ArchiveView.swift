//
//  ArchiveView.swift
//  SkinGlowing
//
//  Archive of previous skin scan results
//

import SwiftUI

struct ArchiveView: View {
    @EnvironmentObject var skinService: SkinAnalysisService
    @State private var selectedTimeRange = "All"
    @State private var searchText = ""
    @State private var selectedEntry: ArchiveEntry?
    @State private var showingDetail = false

    let timeRanges = ["All", "This Week", "This Month", "Last 3 Months"]

    // Mock data for demonstration
    let mockHistory: [ArchiveEntry] = [
        ArchiveEntry(
            scanResult: SkinScanResult(
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
            notes: "Skin looking better after new routine",
            isFavorite: true
        ),
        ArchiveEntry(
            scanResult: SkinScanResult(
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
            notes: nil,
            isFavorite: false
        ),
        ArchiveEntry(
            scanResult: SkinScanResult(
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
            ),
            notes: "Started new skincare routine",
            isFavorite: false
        )
    ]

    var filteredHistory: [ArchiveEntry] {
        var entries = skinService.scanHistory.isEmpty ? mockHistory : skinService.scanHistory

        // Filter by time range
        if selectedTimeRange != "All" {
            let now = Date()
            let calendar = Calendar.current

            switch selectedTimeRange {
            case "This Week":
                if let weekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: now) {
                    entries = entries.filter { $0.scanResult.timestamp >= weekAgo }
                }
            case "This Month":
                if let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) {
                    entries = entries.filter { $0.scanResult.timestamp >= monthAgo }
                }
            case "Last 3 Months":
                if let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: now) {
                    entries = entries.filter { $0.scanResult.timestamp >= threeMonthsAgo }
                }
            default:
                break
            }
        }

        // Filter by search
        if !searchText.isEmpty {
            entries = entries.filter { entry in
                entry.notes?.localizedCaseInsensitiveContains(searchText) ?? false ||
                entry.scanResult.userConcerns.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }

        return entries
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Theme.purpleUltraLight, Color.white],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header with stats
                    ArchiveHeader(totalScans: filteredHistory.count)

                    // Filter controls
                    VStack(spacing: 15) {
                        // Search bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Theme.textMuted)

                            TextField("Search notes or concerns...", text: $searchText)
                                .textFieldStyle(PlainTextFieldStyle())

                            if !searchText.isEmpty {
                                Button(action: { searchText = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(Theme.textMuted)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Theme.shadow, radius: 3, x: 0, y: 2)

                        // Time range filter
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(timeRanges, id: \.self) { range in
                                    TimeRangeChip(
                                        title: range,
                                        isSelected: selectedTimeRange == range,
                                        action: { selectedTimeRange = range }
                                    )
                                }
                            }
                        }
                    }
                    .padding()

                    // History list
                    if filteredHistory.isEmpty {
                        EmptyArchiveView()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 15) {
                                ForEach(filteredHistory) { entry in
                                    ArchiveCard(entry: entry)
                                        .onTapGesture {
                                            selectedEntry = entry
                                            showingDetail = true
                                        }
                                }
                            }
                            .padding()
                            .padding(.bottom, 100)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingDetail) {
                if let entry = selectedEntry {
                    ArchiveDetailView(entry: entry)
                }
            }
        }
    }
}

struct ArchiveHeader: View {
    let totalScans: Int

    var body: some View {
        VStack(spacing: 20) {
            Text("Scan Archive")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Theme.textPrimary)

            HStack(spacing: 40) {
                StatisticView(value: "\(totalScans)", label: "Total Scans", icon: "camera.fill")
                StatisticView(value: "87", label: "Avg Score", icon: "chart.line.uptrend.xyaxis")
                StatisticView(value: "+5", label: "Improvement", icon: "arrow.up.circle.fill")
            }
        }
        .padding()
        .background(Color.white)
        .shadow(color: Theme.shadow, radius: 5, x: 0, y: 2)
    }
}

struct StatisticView: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Theme.purple)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Theme.textPrimary)

            Text(label)
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
        }
    }
}

struct TimeRangeChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body)
                .foregroundColor(isSelected ? .white : Theme.textPrimary)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(isSelected ? Theme.purple : Color.white)
                .cornerRadius(20)
                .shadow(color: Theme.shadow, radius: 3, x: 0, y: 2)
        }
    }
}

struct ArchiveCard: View {
    let entry: ArchiveEntry
    @State private var isFavorite: Bool

    init(entry: ArchiveEntry) {
        self.entry = entry
        self._isFavorite = State(initialValue: entry.isFavorite)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(entry.formattedDate)
                        .font(.headline)
                        .foregroundColor(Theme.textPrimary)

                    Text(formatTime(entry.scanResult.timestamp))
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                }

                Spacer()

                // Score badge
                Text("\(entry.scanResult.metrics.overallScore)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(scoreGradient(for: entry.scanResult.metrics.overallScore))
                    )

                Button(action: { isFavorite.toggle() }) {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .foregroundColor(Theme.warning)
                        .font(.title3)
                }
            }

            // Metrics row
            HStack(spacing: 20) {
                MiniMetric(icon: "drop.fill", value: entry.scanResult.metrics.hydration, color: Color(hex: "#87CEEB"))
                MiniMetric(icon: "face.smiling", value: entry.scanResult.metrics.acne, color: Color(hex: "#98FB98"))
                MiniMetric(icon: "sparkles", value: entry.scanResult.metrics.glow, color: Color(hex: "#FFD700"))
                MiniMetric(icon: "hourglass", value: entry.scanResult.metrics.aging, color: Color(hex: "#FFB6C1"))
            }

            // Concerns
            if !entry.scanResult.userConcerns.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(entry.scanResult.userConcerns, id: \.self) { concern in
                            Text(concern)
                                .font(.caption)
                                .foregroundColor(Theme.purple)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Theme.purpleUltraLight)
                                .cornerRadius(10)
                        }
                    }
                }
            }

            // Notes
            if let notes = entry.notes {
                Text(notes)
                    .font(.body)
                    .foregroundColor(Theme.textSecondary)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Theme.shadow, radius: 5, x: 0, y: 2)
    }

    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    func scoreGradient(for score: Int) -> LinearGradient {
        let colors: [Color] = score >= 80 ?
            [Theme.success, Theme.success.opacity(0.8)] :
            score >= 60 ?
            [Theme.warning, Theme.warning.opacity(0.8)] :
            [Theme.error, Theme.error.opacity(0.8)]

        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

struct MiniMetric: View {
    let icon: String
    let value: Int
    let color: Color

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.footnote)
                .foregroundColor(color)

            Text("\(value)")
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundColor(Theme.textPrimary)
        }
    }
}

struct EmptyArchiveView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundColor(Theme.purple.opacity(0.5))

            Text("No scan history yet")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(Theme.textPrimary)

            Text("Your scan results will appear here")
                .font(.body)
                .foregroundColor(Theme.textSecondary)

            Spacer()
        }
    }
}

struct ArchiveDetailView: View {
    let entry: ArchiveEntry
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Theme.onboardingBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 25) {
                        // Score section
                        VStack(spacing: 15) {
                            Text("Skin Score")
                                .font(.title3)
                                .foregroundColor(Theme.textSecondary)

                            Text("\(entry.scanResult.metrics.overallScore)")
                                .font(.system(size: 72, weight: .bold, design: .rounded))
                                .foregroundColor(Theme.purple)

                            Text(entry.scanResult.metrics.overallGrade)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Theme.success)
                        }
                        .padding(.top, 20)

                        // Full metrics
                        VStack(spacing: 15) {
                            MetricDetailRow(title: "Hydration", value: entry.scanResult.metrics.hydration, status: entry.scanResult.metrics.hydrationLevel, color: Color(hex: "#87CEEB"))
                            MetricDetailRow(title: "Acne", value: entry.scanResult.metrics.acne, status: entry.scanResult.metrics.acneStatus, color: Color(hex: "#98FB98"))
                            MetricDetailRow(title: "Glow", value: entry.scanResult.metrics.glow, status: entry.scanResult.metrics.glowLevel, color: Color(hex: "#FFD700"))
                            MetricDetailRow(title: "Aging", value: entry.scanResult.metrics.aging, status: entry.scanResult.metrics.agingStatus, color: Color(hex: "#FFB6C1"))
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .padding(.horizontal)

                        // Recommendations
                        if !entry.scanResult.recommendations.isEmpty {
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Recommendations")
                                    .font(.headline)
                                    .foregroundColor(Theme.textPrimary)

                                ForEach(entry.scanResult.recommendations, id: \.self) { rec in
                                    HStack(alignment: .top, spacing: 10) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(Theme.success)
                                            .font(.footnote)

                                        Text(rec)
                                            .font(.body)
                                            .foregroundColor(Theme.textPrimary)

                                        Spacer()
                                    }
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                            .padding(.horizontal)
                        }

                        // Notes
                        if let notes = entry.notes {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Notes")
                                    .font(.headline)
                                    .foregroundColor(Theme.textPrimary)

                                Text(notes)
                                    .font(.body)
                                    .foregroundColor(Theme.textSecondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle(entry.formattedDate)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Theme.purple)
                }
            }
        }
    }
}

struct MetricDetailRow: View {
    let title: String
    let value: Int
    let status: String
    let color: Color

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)

                Text(status)
                    .font(.caption)
                    .foregroundColor(color)
            }

            Spacer()

            Text("\(value)%")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Theme.textPrimary)
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    ArchiveView()
        .environmentObject(SkinAnalysisService.shared)
}