//
//  SkinScanView.swift
//  SkinGlowing
//
//  Main skin scanning interface
//

import SwiftUI
import PhotosUI

struct SkinScanView: View {
    @EnvironmentObject var skinService: SkinAnalysisService
    @State private var showingPhotoPicker = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var isAnalyzing = false
    @State private var showResults = false
    @State private var currentMetrics: SkinMetrics?
    @State private var showingError = false
    @State private var errorMessage = ""

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

                ScrollView {
                    VStack(spacing: 25) {
                        // Current Score Card
                        if let metrics = currentMetrics {
                            CurrentScoreCard(metrics: metrics)
                                .padding(.horizontal)
                                .padding(.top, 10)
                        } else {
                            WelcomeCard()
                                .padding(.horizontal)
                                .padding(.top, 10)
                        }

                        // Scan Button
                        VStack(spacing: 20) {
                            Button(action: { showingPhotoPicker = true }) {
                                HStack(spacing: 15) {
                                    Image(systemName: "camera.fill")
                                        .font(.title2)
                                    Text("Start New Scan")
                                        .font(.headline)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(Theme.buttonGradient)
                                .cornerRadius(15)
                                .shadow(color: Theme.purple.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                            .padding(.horizontal)

                            Text("Take a clear selfie for instant AI analysis")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                        }

                        // Metrics Grid
                        if let metrics = currentMetrics {
                            MetricsGrid(metrics: metrics)
                                .padding(.horizontal)
                        }

                        // Quick Tips
                        QuickTipsSection()
                            .padding(.horizontal)
                            .padding(.bottom, 100)
                    }
                }

                // Analysis Overlay
                if isAnalyzing {
                    AnalysisOverlay()
                }
            }
            .navigationBarHidden(true)
            .photosPicker(
                isPresented: $showingPhotoPicker,
                selection: $selectedPhoto,
                matching: .images,
                photoLibrary: .shared()
            )
            .onChange(of: selectedPhoto) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImage = image
                        await analyzeSkin(imageData: data)
                    }
                }
            }
            .sheet(isPresented: $showResults) {
                if let metrics = currentMetrics {
                    ResultsView(metrics: metrics)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    func analyzeSkin(imageData: Data) async {
        isAnalyzing = true

        do {
            // Use the real API integration
            let result = try await skinService.analyzeSkinWithAPI(
                imageData: imageData,
                concerns: ["General skin health", "Texture", "Tone"],
                skinType: "To be determined"
            )

            await MainActor.run {
                currentMetrics = result.metrics
                isAnalyzing = false
                showResults = true
            }
        } catch {
            await MainActor.run {
                print("Analysis failed: \(error.localizedDescription)")
                isAnalyzing = false

                // Show error alert
                showingError = true
                errorMessage = "Failed to analyze image. Please try again."
            }
        }
    }
}

struct WelcomeCard: View {
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "sparkles.rectangle.stack")
                .font(.system(size: 50))
                .foregroundColor(Theme.purple)
                .padding(.top, 10)

            Text("Welcome to SkinGlowing")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Theme.textPrimary)

            Text("Get your AI-powered skin analysis in seconds")
                .font(.body)
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            HStack(spacing: 30) {
                VStack {
                    Text("95%")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.purple)
                    Text("Accuracy")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                }

                VStack {
                    Text("5")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.purple)
                    Text("Metrics")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                }

                VStack {
                    Text("30s")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.purple)
                    Text("Analysis")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                }
            }
            .padding(.vertical, 10)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Theme.shadow, radius: 10, x: 0, y: 5)
    }
}

struct CurrentScoreCard: View {
    let metrics: SkinMetrics

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Your Current Score")
                        .font(.headline)
                        .foregroundColor(Theme.textSecondary)
                    Text("\(metrics.overallScore)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.purple)
                }

                Spacer()

                CircularProgressView(
                    progress: Double(metrics.overallScore) / 100,
                    lineWidth: 8,
                    color: Theme.purple
                )
                .frame(width: 80, height: 80)
            }

            HStack {
                Label("Last scan: Today", systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)

                Spacer()

                Text(metrics.overallGrade)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.success)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Theme.success.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Theme.shadow, radius: 10, x: 0, y: 5)
    }
}

struct MetricsGrid: View {
    let metrics: SkinMetrics

    var body: some View {
        VStack(spacing: 15) {
            HStack(spacing: 15) {
                SkinMetricCard(
                    title: "Hydration",
                    value: metrics.hydration,
                    status: metrics.hydrationLevel,
                    icon: "drop.fill",
                    color: Color(hex: "#87CEEB")
                )

                SkinMetricCard(
                    title: "Acne",
                    value: metrics.acne,
                    status: metrics.acneStatus,
                    icon: "face.smiling",
                    color: Color(hex: "#98FB98")
                )
            }

            HStack(spacing: 15) {
                SkinMetricCard(
                    title: "Glow",
                    value: metrics.glow,
                    status: metrics.glowLevel,
                    icon: "sparkles",
                    color: Color(hex: "#FFD700")
                )

                SkinMetricCard(
                    title: "Aging",
                    value: metrics.aging,
                    status: metrics.agingStatus,
                    icon: "hourglass",
                    color: Color(hex: "#FFB6C1")
                )
            }
        }
    }
}

struct SkinMetricCard: View {
    let title: String
    let value: Int
    let status: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)

                Spacer()

                Text("\(value)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimary)
            }

            Text(title)
                .font(.footnote)
                .foregroundColor(Theme.textSecondary)

            Text(status)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(color)

            ProgressView(value: Double(value), total: 100)
                .tint(color)
                .scaleEffect(x: 1, y: 0.5)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Theme.shadow, radius: 5, x: 0, y: 2)
    }
}

struct QuickTipsSection: View {
    let tips = [
        ("Stay Hydrated", "Drink 8 glasses of water daily", "drop.fill"),
        ("Sun Protection", "Apply SPF 30+ every morning", "sun.max.fill"),
        ("Clean Routine", "Remove makeup before bed", "moon.fill"),
        ("Gentle Care", "Avoid harsh scrubbing", "hand.raised.fill")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Quick Tips")
                .font(.headline)
                .foregroundColor(Theme.textPrimary)

            ForEach(tips, id: \.0) { tip in
                HStack(spacing: 15) {
                    Image(systemName: tip.2)
                        .font(.title3)
                        .foregroundColor(Theme.purple)
                        .frame(width: 30)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(tip.0)
                            .font(.footnote)
                            .fontWeight(.medium)
                            .foregroundColor(Theme.textPrimary)

                        Text(tip.1)
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)
                    }

                    Spacer()
                }
                .padding()
                .background(Theme.purpleUltraLight)
                .cornerRadius(12)
            }
        }
    }
}

struct AnalysisOverlay: View {
    @State private var rotation = 0.0

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Image(systemName: "sparkles.rectangle.stack")
                    .font(.system(size: 60))
                    .foregroundColor(Theme.purple)
                    .rotationEffect(.degrees(rotation))
                    .onAppear {
                        withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                            rotation = 360
                        }
                    }

                Text("Analyzing Your Skin")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("This will take just a moment...")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))

                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
            .padding()
            .background(Theme.purple)
            .cornerRadius(20)
        }
    }
}

struct ResultsView: View {
    let metrics: SkinMetrics
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Theme.onboardingBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 25) {
                        // Score Display
                        VStack(spacing: 15) {
                            Text("Your Skin Score")
                                .font(.title2)
                                .foregroundColor(Theme.textSecondary)

                            Text("\(metrics.overallScore)")
                                .font(.system(size: 80, weight: .bold, design: .rounded))
                                .foregroundColor(Theme.purple)

                            Text(metrics.overallGrade)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Theme.success)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(Theme.success.opacity(0.1))
                                .cornerRadius(12)
                        }
                        .padding(.top, 20)

                        // Metrics
                        MetricsGrid(metrics: metrics)
                            .padding(.horizontal)

                        // Recommendations
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Recommendations")
                                .font(.headline)
                                .foregroundColor(Theme.textPrimary)

                            ForEach(["Use a gentle cleanser twice daily",
                                    "Apply vitamin C serum in the morning",
                                    "Never skip sunscreen",
                                    "Hydrate with hyaluronic acid"], id: \.self) { rec in
                                HStack(spacing: 10) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Theme.success)

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

                        Button(action: { dismiss() }) {
                            Text("Done")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.buttonGradient)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct CircularProgressView: View {
    let progress: Double
    let lineWidth: CGFloat
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, lineWidth: lineWidth)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)
        }
    }
}

#Preview {
    SkinScanView()
        .environmentObject(SkinAnalysisService.shared)
}