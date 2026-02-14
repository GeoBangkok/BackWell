//
//  InsightsView.swift
//  SkinGlowing
//
//  Insights dashboard

import SwiftUI

struct InsightsView: View {
    let PINK = Color(hex: "E8578A")
    let PURPLE = Color(hex: "8B7DFF")
    let BG = Color(hex: "F8F7FB")
    let TEXT_PRIMARY = Color(hex: "1A1A2E")
    let TEXT_SECONDARY = Color(hex: "8E8E9A")

    @State private var selectedTimeframe = "Week"
    let timeframes = ["Day", "Week", "Month", "Year"]

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(hex: "E8D5F0").opacity(0.3),
                        BG
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Insights")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(TEXT_PRIMARY)

                            Text("Track your skin's progress")
                                .font(.system(size: 14))
                                .foregroundColor(TEXT_SECONDARY)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)

                        // Timeframe selector
                        HStack {
                            ForEach(timeframes, id: \.self) { timeframe in
                                Button(action: {
                                    hapticFeedback(.light)
                                    selectedTimeframe = timeframe
                                }) {
                                    Text(timeframe)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(selectedTimeframe == timeframe ? .white : TEXT_SECONDARY)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            selectedTimeframe == timeframe ? PINK : Color.white.opacity(0.6)
                                        )
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal)

                        // Skin Score Card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Overall Skin Score")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(TEXT_PRIMARY)

                                Spacer()

                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(hex: "34C759"))

                                Text("+12%")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(Color(hex: "34C759"))
                            }

                            // Score display
                            HStack(alignment: .bottom, spacing: 8) {
                                Text("85")
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(PINK)

                                Text("/ 100")
                                    .font(.system(size: 18))
                                    .foregroundColor(TEXT_SECONDARY)
                                    .padding(.bottom, 8)
                            }

                            // Progress bar
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.1))
                                        .frame(height: 12)

                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(
                                            LinearGradient(
                                                colors: [PINK, Color(hex: "FFB6C1")],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geometry.size.width * 0.85, height: 12)
                                }
                            }
                            .frame(height: 12)
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
                        .padding(.horizontal)

                        // Key Metrics Grid
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                MetricCard(
                                    title: "Hydration",
                                    value: "78%",
                                    trend: .up,
                                    trendValue: "+5%",
                                    icon: "drop.fill",
                                    color: Color(hex: "4A90E2")
                                )

                                MetricCard(
                                    title: "Glow",
                                    value: "92%",
                                    trend: .up,
                                    trendValue: "+8%",
                                    icon: "sparkles",
                                    color: PINK
                                )
                            }

                            HStack(spacing: 12) {
                                MetricCard(
                                    title: "Clarity",
                                    value: "71%",
                                    trend: .down,
                                    trendValue: "-2%",
                                    icon: "circle.hexagongrid.fill",
                                    color: PURPLE
                                )

                                MetricCard(
                                    title: "Elasticity",
                                    value: "88%",
                                    trend: .up,
                                    trendValue: "+10%",
                                    icon: "arrow.up.arrow.down",
                                    color: Color(hex: "FF9500")
                                )
                            }
                        }
                        .padding(.horizontal)

                        // Recent Scans
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Recent Scans")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(TEXT_PRIMARY)
                                .padding(.horizontal)

                            VStack(spacing: 12) {
                                RecentScanRow(
                                    date: "Today, 8:30 AM",
                                    score: 85,
                                    improvement: "+3"
                                )

                                RecentScanRow(
                                    date: "Yesterday, 7:45 PM",
                                    score: 82,
                                    improvement: "+1"
                                )

                                RecentScanRow(
                                    date: "Dec 15, 9:00 AM",
                                    score: 81,
                                    improvement: "+4"
                                )
                            }
                            .padding(.horizontal)
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.top)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let trend: TrendDirection
    let trendValue: String
    let icon: String
    let color: Color

    enum TrendDirection {
        case up, down, neutral
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)

                Spacer()

                HStack(spacing: 2) {
                    Image(systemName: trend == .up ? "arrow.up.right" : "arrow.down.right")
                        .font(.system(size: 10))
                        .foregroundColor(trend == .up ? Color(hex: "34C759") : Color(hex: "FF3B30"))

                    Text(trendValue)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(trend == .up ? Color(hex: "34C759") : Color(hex: "FF3B30"))
                }
            }

            Text(title)
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "8E8E9A"))

            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(hex: "1A1A2E"))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

struct RecentScanRow: View {
    let date: String
    let score: Int
    let improvement: String

    let PINK = Color(hex: "E8578A")

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(date)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "1A1A2E"))

                Text("Skin Score: \(score)")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "8E8E9A"))
            }

            Spacer()

            Text(improvement)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(hex: "34C759"))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(hex: "34C759").opacity(0.1))
                .cornerRadius(12)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 1)
    }
}

#Preview {
    InsightsView()
}