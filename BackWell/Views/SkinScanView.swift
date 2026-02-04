//
//  SkinScanView.swift
//  SkinGlowing
//
//  Modern skin scanning interface with AI analysis
//

import SwiftUI
import PhotosUI
import AVFoundation

struct SkinScanView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var isAnalyzing = false
    @State private var showResults = false
    @State private var currentMetrics: SkinMetrics?
    @State private var analysisProgress: Double = 0
    @State private var currentAnalysisStep = ""
    @State private var recommendations: [String] = []

    // Analysis steps for visual feedback
    let analysisSteps = [
        "Detecting face...",
        "Analyzing skin texture...",
        "Measuring hydration levels...",
        "Checking for blemishes...",
        "Evaluating skin tone...",
        "Calculating glow factor...",
        "Generating recommendations..."
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                // Clean white background
                Color.white
                    .ignoresSafeArea()

                if !isAnalyzing && !showResults {
                    // Photo selection view
                    VStack(spacing: 0) {
                        // Hero section
                        VStack(spacing: 20) {
                            Image(systemName: "camera.metering.multispot")
                                .font(.system(size: 60))
                                .foregroundColor(Color(hex: "FF91A4"))
                                .padding(.top, 40)

                            Text("Take a selfie for analysis")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Color(uiColor: .label))

                            Text("Our AI will analyze your skin and provide personalized recommendations")
                                .font(.system(size: 16))
                                .foregroundColor(Color(uiColor: .secondaryLabel))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }

                        Spacer()

                        // Selected image preview
                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 250, height: 250)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                colors: [Color(hex: "FF91A4"), Color(hex: "FFB6C1")],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 4
                                        )
                                )
                                .shadow(color: Color(hex: "FF91A4").opacity(0.3), radius: 20, x: 0, y: 10)
                                .padding(.bottom, 30)
                        } else {
                            // Empty state
                            ZStack {
                                Circle()
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
                                    .frame(width: 250, height: 250)

                                VStack(spacing: 12) {
                                    Image(systemName: "person.crop.circle.badge.plus")
                                        .font(.system(size: 50))
                                        .foregroundColor(Color(hex: "FF91A4"))

                                    Text("No photo selected")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color(uiColor: .tertiaryLabel))
                                }
                            }
                            .padding(.bottom, 30)
                        }

                        Spacer()

                        // Action buttons
                        VStack(spacing: 16) {
                            PhotosPicker(selection: $selectedPhoto) {
                                Label("Choose from Library", systemImage: "photo.on.rectangle")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        LinearGradient(
                                            colors: [Color(hex: "FF91A4"), Color(hex: "FFB6C1")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(16)
                            }

                            if selectedImage != nil {
                                Button(action: startAnalysis) {
                                    HStack {
                                        Image(systemName: "wand.and.stars")
                                            .font(.system(size: 18))
                                        Text("Analyze Skin")
                                            .font(.system(size: 17, weight: .semibold))
                                    }
                                    .foregroundColor(Color(hex: "FF91A4"))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color(hex: "FFE4E1").opacity(0.3))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color(hex: "FF91A4"), lineWidth: 2)
                                    )
                                    .cornerRadius(16)
                                }
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.bottom, 40)
                    }

                } else if isAnalyzing {
                    // Analysis in progress
                    VStack(spacing: 40) {
                        // Animated face scanning effect
                        ZStack {
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 200, height: 200)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                LinearGradient(
                                                    colors: [Color(hex: "FF91A4"), Color(hex: "FFB6C1")],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 3
                                            )
                                            .scaleEffect(1.2)
                                            .opacity(0.6)
                                            .animation(
                                                Animation.easeInOut(duration: 1.5)
                                                    .repeatForever(autoreverses: true),
                                                value: isAnalyzing
                                            )
                                    )
                            }
                        }

                        VStack(spacing: 16) {
                            Text("Analyzing Your Skin")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(uiColor: .label))

                            Text(currentAnalysisStep)
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "FF91A4"))
                                .animation(.easeInOut, value: currentAnalysisStep)
                        }

                        // Progress bar
                        ProgressView(value: analysisProgress)
                            .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "FF91A4")))
                            .scaleEffect(y: 2)
                            .padding(.horizontal, 50)
                    }

                } else if showResults, let metrics = currentMetrics {
                    // Results view
                    ScrollView {
                        VStack(spacing: 30) {
                            // Score circle
                            ZStack {
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color(hex: "FFE4E1"), Color(hex: "FFB6C1")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 15
                                    )
                                    .frame(width: 180, height: 180)

                                VStack(spacing: 8) {
                                    Text("\(metrics.overallScore)")
                                        .font(.system(size: 60, weight: .bold, design: .rounded))
                                        .foregroundColor(Color(hex: "FF91A4"))

                                    Text("Skin Score")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(Color(uiColor: .secondaryLabel))
                                }
                            }
                            .padding(.top, 30)

                            // Metrics Grid
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                                MetricResultCard(
                                    icon: "drop.fill",
                                    title: "Hydration",
                                    value: metrics.hydration,
                                    status: metrics.hydrationLevel,
                                    color: .blue
                                )

                                MetricResultCard(
                                    icon: "sparkles",
                                    title: "Glow",
                                    value: metrics.glow,
                                    status: metrics.glowLevel,
                                    color: Color(hex: "FFD700")
                                )

                                MetricResultCard(
                                    icon: "shield.fill",
                                    title: "Clarity",
                                    value: metrics.acne,
                                    status: metrics.acneStatus,
                                    color: .green
                                )

                                MetricResultCard(
                                    icon: "clock.fill",
                                    title: "Youth",
                                    value: metrics.aging,
                                    status: metrics.agingStatus,
                                    color: .purple
                                )
                            }
                            .padding(.horizontal, 20)

                            // Recommendations
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Recommendations")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(Color(uiColor: .label))

                                ForEach(recommendations, id: \.self) { recommendation in
                                    HStack(alignment: .top, spacing: 12) {
                                        Image(systemName: "star.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(Color(hex: "FF91A4"))

                                        Text(recommendation)
                                            .font(.system(size: 16))
                                            .foregroundColor(Color(uiColor: .secondaryLabel))

                                        Spacer()
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                                    .background(Color(hex: "FFE4E1").opacity(0.2))
                                    .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal, 20)

                            // Action buttons
                            HStack(spacing: 16) {
                                Button(action: {
                                    showResults = false
                                    selectedImage = nil
                                    selectedPhoto = nil
                                    currentMetrics = nil
                                }) {
                                    Text("Scan Again")
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(Color(hex: "FF91A4"))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color(hex: "FF91A4"), lineWidth: 2)
                                        )
                                }

                                Button(action: saveResults) {
                                    Text("Save Results")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(
                                            LinearGradient(
                                                colors: [Color(hex: "FF91A4"), Color(hex: "FFB6C1")],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(16)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 30)
                        }
                    }
                }
            }
            .navigationTitle("Skin Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                        .foregroundColor(Color(hex: "FF91A4"))
                }
            }
        }
        .onChange(of: selectedPhoto) { newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    selectedImage = image
                }
            }
        }
    }

    private func startAnalysis() {
        isAnalyzing = true
        analysisProgress = 0

        // Simulate analysis with random results
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            analysisProgress += 0.15
            let stepIndex = Int(analysisProgress * Double(analysisSteps.count))
            if stepIndex < analysisSteps.count {
                currentAnalysisStep = analysisSteps[stepIndex]
            }

            if analysisProgress >= 1.0 {
                timer.invalidate()
                completeAnalysis()
            }
        }
    }

    private func completeAnalysis() {
        // Generate random metrics for demo
        currentMetrics = SkinMetrics(
            overallScore: Int.random(in: 75...95),
            hydration: Int.random(in: 65...90),
            acne: Int.random(in: 70...95),
            glow: Int.random(in: 60...88),
            aging: Int.random(in: 70...92),
            timestamp: Date()
        )

        // Generate recommendations based on scores
        recommendations = [
            "Use a hydrating serum with hyaluronic acid",
            "Apply SPF 50+ sunscreen daily",
            "Consider adding retinol to your PM routine",
            "Drink at least 8 glasses of water daily"
        ]

        withAnimation {
            isAnalyzing = false
            showResults = true
        }
    }

    private func saveResults() {
        // Save to UserDefaults or storage
        dismiss()
    }
}

struct MetricResultCard: View {
    let icon: String
    let title: String
    let value: Int
    let status: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)

            Text("\(value)%")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(uiColor: .label))

            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(uiColor: .secondaryLabel))

            Text(status)
                .font(.system(size: 12))
                .foregroundColor(color)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(color.opacity(0.1))
                .cornerRadius(8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    SkinScanView()
}