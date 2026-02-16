//
//  SkinScanView.swift
//  SkinGlowing
//
//  Face Scan tab: camera-first skin analysis
//  States: idle → scanning → loading → results
//

import SwiftUI
import AVFoundation

// MARK: - Face Scan Tab (embedded in MainTabView)

struct FaceScanTabView: View {
    @ObservedObject private var historyManager = ScanHistoryManager.shared
    @State private var scanState: FaceScanState = .idle
    @State private var currentResult: FaceScanResult?
    @State private var scanLineOffset: CGFloat = -150
    @State private var showCamera = false
    @State private var capturedImage: UIImage?

    enum FaceScanState {
        case idle, scanning, loading, results
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                switch scanState {
                case .idle:
                    idleView
                case .scanning:
                    scanningView
                case .loading:
                    loadingView
                case .results:
                    if let result = currentResult {
                        resultsView(result)
                    }
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 120)
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(selectedImage: $capturedImage, sourceType: .camera)
        }
        .onChange(of: capturedImage) { newImage in
            if newImage != nil {
                startScanning()
            }
        }
    }

    // MARK: - Idle State

    private var idleView: some View {
        VStack(spacing: 32) {
            // Latest scan summary (if exists)
            if let latest = historyManager.latestFaceScan {
                latestScanCard(latest)
            }

            // Camera hero button
            Button(action: {
                hapticFeedback(.medium)
                showCamera = true
            }) {
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Theme.accentSoft)
                            .frame(width: 120, height: 120)

                        Circle()
                            .fill(Theme.accent)
                            .frame(width: 80, height: 80)

                        Image(systemName: "camera.fill")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(.white)
                    }

                    Text("Scan Your Face")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Theme.headline)

                    Text("Take a selfie for AI-powered\nskin analysis")
                        .font(.system(size: 15))
                        .foregroundColor(Theme.captionText)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: Theme.cardShadowColor, radius: Theme.cardShadowRadius, x: 0, y: 4)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 20)

            // What we analyze section
            VStack(alignment: .leading, spacing: 16) {
                Text("What We Analyze")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Theme.headline)
                    .padding(.horizontal, 20)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    AnalysisFeatureCard(icon: "clock.fill", title: "Skin Age", description: "Estimated biological skin age", color: .blue)
                    AnalysisFeatureCard(icon: "sparkles", title: "Glass Skin", description: "Hydration & glow tier", color: .purple)
                    AnalysisFeatureCard(icon: "circle.hexagongrid.fill", title: "Blemishes", description: "Severity & zone mapping", color: .orange)
                    AnalysisFeatureCard(icon: "hand.raised.fill", title: "Firmness", description: "Elasticity & contour score", color: .green)
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Latest Scan Card

    private func latestScanCard(_ scan: FaceScanResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Last Scan")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Theme.captionText)
                    .textCase(.uppercase)
                    .tracking(0.5)

                Spacer()

                Text(scan.timestamp, style: .relative)
                    .font(.system(size: 13))
                    .foregroundColor(Theme.mutedText)
            }

            HStack(spacing: 16) {
                MiniMetricPill(label: "Age", value: "\(scan.skinAge)", delta: scan.skinAgeDelta.map { $0 > 0 ? "+\($0)" : "\($0)" })
                MiniMetricPill(label: "Glass", value: scan.glassSkinTier.label, delta: nil)
                MiniMetricPill(label: "Firm", value: String(format: "%.1f", scan.firmnessScore), delta: scan.firmnessDelta.map { $0 > 0 ? "+\(String(format: "%.1f", $0))" : String(format: "%.1f", $0) })
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: Theme.cardCorner)
                .fill(Color.white)
                .shadow(color: Theme.cardShadowColor, radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal, 20)
    }

    // MARK: - Scanning State

    private var scanningView: some View {
        VStack(spacing: 30) {
            if let image = capturedImage {
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 280, height: 350)
                        .clipShape(RoundedRectangle(cornerRadius: 24))

                    // Red scan line
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Theme.accent)
                        .frame(height: 3)
                        .shadow(color: Theme.accent.opacity(0.6), radius: 8, x: 0, y: 0)
                        .padding(.horizontal, 8)
                        .offset(y: scanLineOffset)

                    // Corner brackets
                    ScanCornerBrackets()
                }
                .frame(width: 280, height: 350)
            }

            VStack(spacing: 8) {
                Text("Scanning...")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Theme.headline)

                Text("Analyzing skin texture, hydration & more")
                    .font(.system(size: 15))
                    .foregroundColor(Theme.captionText)
            }
        }
        .padding(.top, 40)
        .onAppear {
            scanLineOffset = -150
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                scanLineOffset = 150
            }
        }
    }

    // MARK: - Loading State

    private var loadingView: some View {
        VStack(spacing: 24) {
            Text("Generating Results")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Theme.headline)
                .padding(.top, 40)

            // Skeleton cards
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(0..<4, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(red: 0.95, green: 0.95, blue: 0.96))
                        .frame(height: 140)
                        .shimmer()
                }
            }
            .padding(.horizontal, 20)

            // Skeleton advice
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.95, green: 0.95, blue: 0.96))
                .frame(height: 80)
                .shimmer()
                .padding(.horizontal, 20)
        }
    }

    // MARK: - Results State

    private func resultsView(_ result: FaceScanResult) -> some View {
        VStack(spacing: 24) {
            // Results header
            HStack {
                Text("Your Results")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Theme.headline)

                Spacer()

                Button(action: {
                    hapticFeedback(.light)
                    resetScan()
                }) {
                    Text("New Scan")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Theme.accent)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Theme.accentSoft)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 20)

            // 4 Score Cards
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                // Skin Age
                SkinScoreCard(
                    icon: "clock.fill",
                    title: "Skin Age",
                    mainValue: "\(result.skinAge)",
                    unit: "yrs",
                    micro: result.skinAgeMicro,
                    delta: result.skinAgeDelta.map { $0 > 0 ? "+\($0)" : "\($0)" },
                    color: .blue
                )

                // Glass Skin
                SkinScoreCard(
                    icon: "sparkles",
                    title: "Glass Skin",
                    mainValue: result.glassSkinTier.label,
                    unit: nil,
                    micro: result.glassSkinMicro,
                    delta: nil,
                    color: .purple
                )

                // Blemishes
                SkinScoreCard(
                    icon: "circle.hexagongrid.fill",
                    title: "Blemishes",
                    mainValue: result.blemishSeverity.rawValue,
                    unit: nil,
                    micro: result.blemishMicro,
                    delta: nil,
                    color: .orange,
                    badge: result.blemishZone
                )

                // Firmness
                SkinScoreCard(
                    icon: "hand.raised.fill",
                    title: "Firmness",
                    mainValue: String(format: "%.1f", result.firmnessScore),
                    unit: "/10",
                    micro: result.firmnessMicro,
                    delta: result.firmnessDelta.map { $0 > 0 ? "+\(String(format: "%.1f", $0))" : String(format: "%.1f", $0) },
                    color: .green
                )
            }
            .padding(.horizontal, 20)

            // Glow Advice
            HStack(spacing: 12) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Theme.accent)

                Text(result.glowAdvice)
                    .font(.system(size: 15))
                    .foregroundColor(Theme.bodyText)
                    .lineLimit(3)

                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Theme.accentSoft)
            )
            .padding(.horizontal, 20)

            // Save button
            Button(action: {
                hapticFeedback(.medium)
                historyManager.addFaceScan(result)
                resetScan()
            }) {
                Text("Save & Close")
                    .sgAccentButton()
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Actions

    private func startScanning() {
        scanState = .scanning
        scanLineOffset = -150

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation { scanState = .loading }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                let previousScan = historyManager.latestFaceScan
                let result = SkinScoringEngine.shared.generateFaceScan(previousScan: previousScan)
                withAnimation {
                    currentResult = result
                    scanState = .results
                }
            }
        }
    }

    private func resetScan() {
        withAnimation {
            scanState = .idle
            currentResult = nil
            capturedImage = nil
            scanLineOffset = -150
        }
    }
}

// MARK: - Skin Score Card

struct SkinScoreCard: View {
    let icon: String
    let title: String
    let mainValue: String
    let unit: String?
    let micro: String
    let delta: String?
    let color: Color
    var badge: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)

                Spacer()

                if let delta = delta {
                    Text(delta)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(delta.hasPrefix("-") ? Theme.statusGreen : Theme.statusYellow)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color(uiColor: .systemGray6)))
                }
            }

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(mainValue)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Theme.headline)

                if let unit = unit {
                    Text(unit)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Theme.captionText)
                }
            }

            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Theme.captionText)
                .textCase(.uppercase)
                .tracking(0.3)

            if let badge = badge {
                Text(badge)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(color.opacity(0.1))
                    .clipShape(Capsule())
            }

            Text(micro)
                .font(.system(size: 12))
                .foregroundColor(Theme.mutedText)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Theme.cardShadowColor, radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Analysis Feature Card

struct AnalysisFeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 26))
                .foregroundColor(color)

            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Theme.headline)

            Text(description)
                .font(.system(size: 12))
                .foregroundColor(Theme.captionText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.06))
        )
    }
}

// MARK: - Mini Metric Pill

struct MiniMetricPill: View {
    let label: String
    let value: String
    let delta: String?

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Theme.captionText)
                .textCase(.uppercase)

            Text(value)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(Theme.headline)

            if let delta = delta {
                Text(delta)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(delta.hasPrefix("-") ? Theme.statusGreen : Theme.statusYellow)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(uiColor: .systemGray6).opacity(0.5))
        )
    }
}

// MARK: - Scan Corner Brackets

struct ScanCornerBrackets: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let len: CGFloat = 30
            let lw: CGFloat = 3
            let pad: CGFloat = 4

            Path { p in
                p.move(to: CGPoint(x: pad, y: pad + len))
                p.addLine(to: CGPoint(x: pad, y: pad))
                p.addLine(to: CGPoint(x: pad + len, y: pad))
            }.stroke(Theme.accent, lineWidth: lw)

            Path { p in
                p.move(to: CGPoint(x: w - pad - len, y: pad))
                p.addLine(to: CGPoint(x: w - pad, y: pad))
                p.addLine(to: CGPoint(x: w - pad, y: pad + len))
            }.stroke(Theme.accent, lineWidth: lw)

            Path { p in
                p.move(to: CGPoint(x: pad, y: h - pad - len))
                p.addLine(to: CGPoint(x: pad, y: h - pad))
                p.addLine(to: CGPoint(x: pad + len, y: h - pad))
            }.stroke(Theme.accent, lineWidth: lw)

            Path { p in
                p.move(to: CGPoint(x: w - pad - len, y: h - pad))
                p.addLine(to: CGPoint(x: w - pad, y: h - pad))
                p.addLine(to: CGPoint(x: w - pad, y: h - pad - len))
            }.stroke(Theme.accent, lineWidth: lw)
        }
    }
}

// MARK: - Image Picker (UIKit wrapper)

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    let sourceType: UIImagePickerController.SourceType

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = UIImagePickerController.isSourceTypeAvailable(sourceType) ? sourceType : .photoLibrary
        picker.delegate = context.coordinator
        if sourceType == .camera {
            picker.cameraDevice = .front
        }
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Legacy backward compat

struct SkinScanView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            FaceScanTabView()
                .navigationTitle("Skin Analysis")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") { dismiss() }
                            .foregroundColor(Theme.accent)
                    }
                }
        }
    }
}

struct MetricResultCard: View {
    let icon: String
    let title: String
    let value: Int
    let status: String
    let color: Color
    var body: some View { EmptyView() }
}

#Preview {
    FaceScanTabView()
}
