//
//  HomeView.swift
//  SkinGlowing
//
//  Home view with skin scanning functionality

import SwiftUI
import PhotosUI

struct HomeView: View {
    @State private var showingScanView = false
    @State private var showingArchive = false
    @State private var latestScan: SkinScanResult?
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var scanImage: UIImage?

    var body: some View {
        NavigationStack {
            ZStack {
                // Clean white background
                Color(uiColor: UIColor.systemBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Welcome card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Welcome back!")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(Color(uiColor: UIColor.label))

                                    Text("Ready for your skin analysis?")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color(uiColor: UIColor.secondaryLabel))
                                }

                                Spacer()

                                Image(systemName: "sparkles")
                                    .font(.system(size: 32))
                                    .foregroundColor(Color(hex: "FF91A4"))
                            }
                        }
                        .padding(20)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(hex: "FFE4E1").opacity(0.3),
                                    Color(hex: "FFB6C1").opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(20)
                        .padding(.horizontal, 20)

                        // Scan button
                        Button(action: {
                            showingScanView = true
                            hapticFeedback(.light)
                        }) {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color(hex: "FF91A4"), Color(hex: "FFB6C1")],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 60, height: 60)

                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 26))
                                        .foregroundColor(.white)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("New Skin Scan")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(Color(uiColor: UIColor.label))

                                    Text("Analyze your skin condition")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(uiColor: UIColor.secondaryLabel))
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(Color(hex: "FF91A4"))
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(uiColor: UIColor.systemBackground))
                                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color(uiColor: UIColor.systemGray6), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 20)

                        // Latest Scan Results (if available)
                        if let scan = latestScan {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Latest Analysis")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(Color(uiColor: UIColor.label))

                                // Metrics Grid
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                    MetricCard(
                                        icon: "drop.fill",
                                        title: "Hydration",
                                        value: scan.metrics.hydration,
                                        color: Color.blue
                                    )

                                    MetricCard(
                                        icon: "sparkles",
                                        title: "Glow",
                                        value: scan.metrics.glow,
                                        color: Color(hex: "FFB6C1")
                                    )

                                    MetricCard(
                                        icon: "shield.fill",
                                        title: "Clarity",
                                        value: scan.metrics.acne,
                                        color: Color.green
                                    )

                                    MetricCard(
                                        icon: "clock.fill",
                                        title: "Anti-Aging",
                                        value: scan.metrics.aging,
                                        color: Color.purple
                                    )
                                }

                                // View History Button
                                Button(action: {
                                    showingArchive = true
                                }) {
                                    HStack {
                                        Image(systemName: "clock.arrow.circlepath")
                                            .font(.system(size: 18))
                                        Text("View History")
                                            .font(.system(size: 16, weight: .medium))
                                    }
                                    .foregroundColor(Color(hex: "FF91A4"))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color(hex: "FF91A4"), lineWidth: 1.5)
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }

                        // Quick Actions
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Quick Actions")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(uiColor: UIColor.label))

                            HStack(spacing: 12) {
                                QuickActionCard(
                                    icon: "chart.line.uptrend.xyaxis",
                                    title: "Progress",
                                    color: Color.green,
                                    action: {
                                        showingArchive = true
                                    }
                                )

                                QuickActionCard(
                                    icon: "lightbulb.fill",
                                    title: "Tips",
                                    color: Color.orange,
                                    action: {
                                        // Show tips
                                    }
                                )

                                QuickActionCard(
                                    icon: "calendar",
                                    title: "Routine",
                                    color: Color(hex: "FF91A4"),
                                    action: {
                                        // Navigate to routines
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)

                        Spacer(minLength: 100)
                    }
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Skin Analysis")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                trailing: Button(action: {
                    showingArchive = true
                }) {
                    Image(systemName: "archivebox")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "FF91A4"))
                }
            )
        }
        .sheet(isPresented: $showingScanView) {
            SkinScanView()
        }
        .sheet(isPresented: $showingArchive) {
            ArchiveView()
        }
        .onAppear {
            loadLatestScan()
        }
    }

    private func loadLatestScan() {
        // Load from UserDefaults or storage
        // This is placeholder - would load actual data
    }
}

struct MetricCard: View {
    let icon: String
    let title: String
    let value: Int
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)

            Text("\(value)%")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color(uiColor: UIColor.label))

            Text(title)
                .font(.system(size: 14))
                .foregroundColor(Color(uiColor: UIColor.secondaryLabel))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: UIColor.systemGray6))
        )
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)

                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(uiColor: UIColor.label))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(uiColor: UIColor.systemBackground))
                    .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
            )
        }
    }
}

#Preview {
    HomeView()
}