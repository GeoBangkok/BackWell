//
//  ArchiveView.swift
//  SkinGlowing
//
//  History view: segmented control, scan rows, mini trend charts
//

import SwiftUI

struct ArchiveView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var historyManager = ScanHistoryManager.shared
    @State private var selectedSegment = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Segmented control
                Picker("Scan Type", selection: $selectedSegment) {
                    Text("Face Scans").tag(0)
                    Text("Product Scans").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 16)

                if selectedSegment == 0 {
                    faceScansTab
                } else {
                    productScansTab
                }
            }
            .background(Color.white.ignoresSafeArea())
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Theme.accent)
                }
            }
        }
    }

    // MARK: - Face Scans Tab

    private var faceScansTab: some View {
        Group {
            if historyManager.faceScans.isEmpty {
                emptyState(title: "No Face Scans", subtitle: "Your skin analysis history will appear here", icon: "camera.fill")
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Mini Trend Charts
                        if historyManager.faceScans.count >= 2 {
                            trendChartsSection
                        }

                        // Scan rows
                        VStack(alignment: .leading, spacing: 12) {
                            Text("All Scans")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Theme.headline)
                                .padding(.horizontal, 20)

                            ForEach(historyManager.faceScans) { scan in
                                FaceScanHistoryRow(scan: scan)
                                    .padding(.horizontal, 20)
                            }
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
    }

    // MARK: - Product Scans Tab

    private var productScansTab: some View {
        Group {
            if historyManager.productScans.isEmpty {
                emptyState(title: "No Product Scans", subtitle: "Scan product labels to check compatibility", icon: "barcode.viewfinder")
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("All Product Scans")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Theme.headline)
                            .padding(.horizontal, 20)
                            .padding(.top, 8)

                        ForEach(historyManager.productScans) { scan in
                            ProductScanHistoryRow(scan: scan)
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
    }

    // MARK: - Trend Charts Section

    private var trendChartsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Trends")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Theme.headline)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    // Skin Age trend
                    MiniTrendChart(
                        title: "Skin Age",
                        values: historyManager.faceScans.prefix(10).reversed().map { Double($0.skinAge) },
                        unit: "yrs",
                        color: .blue,
                        latestValue: "\(historyManager.faceScans.first?.skinAge ?? 0)"
                    )

                    // Glass Skin trend
                    MiniTrendChart(
                        title: "Glass Skin",
                        values: historyManager.faceScans.prefix(10).reversed().map { Double($0.glassSkinTier.rawValue) },
                        unit: "",
                        color: .purple,
                        latestValue: historyManager.faceScans.first?.glassSkinTier.label ?? "-"
                    )

                    // Firmness trend
                    MiniTrendChart(
                        title: "Firmness",
                        values: historyManager.faceScans.prefix(10).reversed().map { $0.firmnessScore },
                        unit: "/10",
                        color: .green,
                        latestValue: String(format: "%.1f", historyManager.faceScans.first?.firmnessScore ?? 0)
                    )
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Empty State

    private func emptyState(title: String, subtitle: String, icon: String) -> some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(Theme.accent.opacity(0.3))

            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Theme.headline)

            Text(subtitle)
                .font(.system(size: 15))
                .foregroundColor(Theme.captionText)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Face Scan History Row

struct FaceScanHistoryRow: View {
    let scan: FaceScanResult

    var body: some View {
        HStack(spacing: 16) {
            // Date
            VStack(alignment: .leading, spacing: 4) {
                Text(scan.timestamp, format: .dateTime.month(.abbreviated).day())
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Theme.headline)

                Text(scan.timestamp, format: .dateTime.hour().minute())
                    .font(.system(size: 13))
                    .foregroundColor(Theme.captionText)
            }

            Spacer()

            // Key metrics inline
            HStack(spacing: 14) {
                VStack(spacing: 2) {
                    Text("\(scan.skinAge)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Theme.headline)
                    Text("Age")
                        .font(.system(size: 10))
                        .foregroundColor(Theme.captionText)
                }

                VStack(spacing: 2) {
                    Text(scan.glassSkinTier.label)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Theme.headline)
                    Text("Glass")
                        .font(.system(size: 10))
                        .foregroundColor(Theme.captionText)
                }

                VStack(spacing: 2) {
                    Text(String(format: "%.1f", scan.firmnessScore))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Theme.headline)
                    Text("Firm")
                        .font(.system(size: 10))
                        .foregroundColor(Theme.captionText)
                }
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 13))
                .foregroundColor(Theme.mutedText)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: Theme.cardShadowColor, radius: 6, x: 0, y: 2)
        )
    }
}

// MARK: - Product Scan History Row

struct ProductScanHistoryRow: View {
    let scan: ProductScanResult

    private var scoreColor: Color {
        switch scan.compatibilityScore {
        case 8...10: return Theme.statusGreen
        case 5...7: return Theme.statusYellow
        default: return Theme.statusRed
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            // Score badge
            ZStack {
                Circle()
                    .fill(scoreColor.opacity(0.1))
                    .frame(width: 44, height: 44)

                Text("\(scan.compatibilityScore)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(scoreColor)
            }

            // Product info
            VStack(alignment: .leading, spacing: 4) {
                Text(scan.productName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Theme.headline)

                Text(scan.compatibilityLabel)
                    .font(.system(size: 13))
                    .foregroundColor(Theme.captionText)
            }

            Spacer()

            // Traffic lights mini
            HStack(spacing: 6) {
                Circle().fill(scan.acneSafe.color).frame(width: 8, height: 8)
                Circle().fill(scan.hydrationFriendly.color).frame(width: 8, height: 8)
                Circle().fill(scan.irritationRisk.color).frame(width: 8, height: 8)
                Circle().fill(scan.glowSupport.color).frame(width: 8, height: 8)
            }

            Text(scan.timestamp, format: .dateTime.month(.abbreviated).day())
                .font(.system(size: 12))
                .foregroundColor(Theme.mutedText)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: Theme.cardShadowColor, radius: 6, x: 0, y: 2)
        )
    }
}

// MARK: - Mini Trend Chart

struct MiniTrendChart: View {
    let title: String
    let values: [Double]
    let unit: String
    let color: Color
    let latestValue: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Theme.captionText)
                .textCase(.uppercase)
                .tracking(0.3)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(latestValue)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Theme.headline)

                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Theme.captionText)
                }
            }

            // Sparkline
            if values.count >= 2 {
                SparklineView(values: values, color: color)
                    .frame(height: 40)
            }
        }
        .frame(width: 140)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(color.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(color.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Sparkline

struct SparklineView: View {
    let values: [Double]
    let color: Color

    var body: some View {
        GeometryReader { geo in
            let minVal = values.min() ?? 0
            let maxVal = values.max() ?? 1
            let range = max(maxVal - minVal, 0.1)

            Path { path in
                for (index, value) in values.enumerated() {
                    let x = geo.size.width * CGFloat(index) / CGFloat(max(values.count - 1, 1))
                    let y = geo.size.height * (1 - CGFloat((value - minVal) / range))

                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))

            // Dot on latest
            let lastX = geo.size.width
            let lastY = geo.size.height * (1 - CGFloat(((values.last ?? 0) - minVal) / range))

            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
                .position(x: lastX, y: lastY)
        }
    }
}

// MARK: - Legacy backward compat stubs

struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    var body: some View { EmptyView() }
}

struct ArchiveFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    var body: some View { EmptyView() }
}

struct ArchiveScanCard: View {
    let scan: SkinScanResult
    var body: some View { EmptyView() }
}

struct ScanDetailView: View {
    let scan: SkinScanResult
    var body: some View { EmptyView() }
}

struct ArchiveMetricDetailCard: View {
    let icon: String
    let title: String
    let value: Int
    let status: String
    let color: Color
    var body: some View { EmptyView() }
}

#Preview {
    ArchiveView()
}
