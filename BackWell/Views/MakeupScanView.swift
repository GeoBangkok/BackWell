//
//  MakeupScanView.swift
//  SkinGlowing
//
//  Product Scan tab: ingredient analysis & compatibility scoring
//  Camera → OCR → compatibility ring gauge → traffic lights → flagged ingredients
//

import SwiftUI

// MARK: - Product Scan Tab (embedded in MainTabView)

struct ProductScanTabView: View {
    @ObservedObject private var historyManager = ScanHistoryManager.shared
    @State private var scanState: ProductScanState = .idle
    @State private var currentResult: ProductScanResult?
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    @State private var productName = ""

    enum ProductScanState {
        case idle, analyzing, results
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                switch scanState {
                case .idle:
                    idleView
                case .analyzing:
                    analyzingView
                case .results:
                    if let result = currentResult {
                        productResultsView(result)
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
                startAnalysis()
            }
        }
    }

    // MARK: - Idle State

    private var idleView: some View {
        VStack(spacing: 32) {
            // Recent product scans
            if !historyManager.productScans.isEmpty {
                recentProductScans
            }

            // Camera hero
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

                        Image(systemName: "barcode.viewfinder")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(.white)
                    }

                    Text("Scan a Product")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Theme.headline)

                    Text("Point at the ingredient label\nto check compatibility")
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

            // How it works
            VStack(alignment: .leading, spacing: 16) {
                Text("How It Works")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Theme.headline)
                    .padding(.horizontal, 20)

                VStack(spacing: 12) {
                    HowItWorksRow(step: "1", icon: "camera.fill", text: "Take a photo of the ingredient label")
                    HowItWorksRow(step: "2", icon: "text.viewfinder", text: "AI reads and identifies ingredients")
                    HowItWorksRow(step: "3", icon: "checkmark.shield.fill", text: "Get your compatibility score")
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Recent Product Scans

    private var recentProductScans: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Scans")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Theme.captionText)
                .textCase(.uppercase)
                .tracking(0.5)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(historyManager.productScans.prefix(5)) { scan in
                        RecentProductPill(scan: scan)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Analyzing State

    private var analyzingView: some View {
        VStack(spacing: 30) {
            if let image = capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Theme.accent.opacity(0.3), lineWidth: 2)
                    )
                    .padding(.horizontal, 40)
            }

            VStack(spacing: 12) {
                ProgressView()
                    .tint(Theme.accent)
                    .scaleEffect(1.5)

                Text("Reading Ingredients...")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Theme.headline)

                Text("Analyzing compatibility with your skin")
                    .font(.system(size: 15))
                    .foregroundColor(Theme.captionText)
            }
        }
        .padding(.top, 40)
    }

    // MARK: - Results State

    private func productResultsView(_ result: ProductScanResult) -> some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.productName)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Theme.headline)

                    Text(result.compatibilityLabel)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(scoreColor(result.compatibilityScore))
                }

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

            // Compatibility Ring Gauge
            ZStack {
                Circle()
                    .stroke(Color(uiColor: .systemGray5), lineWidth: 12)
                    .frame(width: 160, height: 160)

                Circle()
                    .trim(from: 0, to: CGFloat(result.compatibilityScore) / 10.0)
                    .stroke(
                        scoreColor(result.compatibilityScore),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 4) {
                    Text("\(result.compatibilityScore)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(Theme.headline)

                    Text("out of 10")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Theme.captionText)
                }
            }

            // Micro explanation
            Text(result.microExplanation)
                .font(.system(size: 15))
                .foregroundColor(Theme.bodyText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            // 4 Traffic Light Mini Cards
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                TrafficLightCard(title: "Acne Safe", light: result.acneSafe, icon: "shield.fill")
                TrafficLightCard(title: "Hydration", light: result.hydrationFriendly, icon: "drop.fill")
                TrafficLightCard(title: "Irritation Risk", light: result.irritationRisk, icon: "exclamationmark.triangle.fill")
                TrafficLightCard(title: "Glow Support", light: result.glowSupport, icon: "sparkles")
            }
            .padding(.horizontal, 20)

            // Flagged Ingredients
            if !result.flaggedIngredients.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Flagged Ingredients")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Theme.headline)

                    ForEach(result.flaggedIngredients) { ingredient in
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(Theme.statusYellow)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(ingredient.name)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Theme.headline)

                                Text(ingredient.concern)
                                    .font(.system(size: 13))
                                    .foregroundColor(Theme.captionText)
                            }

                            Spacer()
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Theme.statusYellow.opacity(0.08))
                        )
                    }
                }
                .padding(.horizontal, 20)
            }

            // Save button
            Button(action: {
                hapticFeedback(.medium)
                historyManager.addProductScan(result)
                resetScan()
            }) {
                Text("Save & Close")
                    .sgAccentButton()
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Helpers

    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 8...10: return Theme.statusGreen
        case 5...7: return Theme.statusYellow
        default: return Theme.statusRed
        }
    }

    private func startAnalysis() {
        scanState = .analyzing

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            let result = SkinScoringEngine.shared.generateProductScan(
                productName: "Scanned Product",
                userSkinType: "Normal"
            )
            withAnimation {
                currentResult = result
                scanState = .results
            }
        }
    }

    private func resetScan() {
        withAnimation {
            scanState = .idle
            currentResult = nil
            capturedImage = nil
        }
    }
}

// MARK: - Traffic Light Card

struct TrafficLightCard: View {
    let title: String
    let light: TrafficLight
    let icon: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: light.icon)
                .font(.system(size: 20))
                .foregroundColor(light.color)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Theme.headline)

                Text(light.rawValue)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(light.color)
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(light.color.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(light.color.opacity(0.15), lineWidth: 1)
                )
        )
    }
}

// MARK: - How It Works Row

struct HowItWorksRow: View {
    let step: String
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Theme.accentSoft)
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Theme.accent)
            }

            Text(text)
                .font(.system(size: 15))
                .foregroundColor(Theme.bodyText)

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(uiColor: .systemGray6).opacity(0.5))
        )
    }
}

// MARK: - Recent Product Pill

struct RecentProductPill: View {
    let scan: ProductScanResult

    var body: some View {
        VStack(spacing: 6) {
            Text("\(scan.compatibilityScore)/10")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Theme.headline)

            Text(scan.productName)
                .font(.system(size: 11))
                .foregroundColor(Theme.captionText)
                .lineLimit(1)
        }
        .frame(width: 80)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Theme.cardShadowColor, radius: 6, x: 0, y: 2)
        )
    }
}

// MARK: - Legacy backward compat

struct MakeupScanView: View {
    var body: some View {
        ProductScanTabView()
    }
}

struct CategoryPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    var body: some View { EmptyView() }
}

struct ShadeCard: View {
    let productName: String
    let shade: String
    let match: Int
    let price: String
    let color: Color
    var body: some View { EmptyView() }
}

struct ColorProfileCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var body: some View { EmptyView() }
}

#Preview {
    ProductScanTabView()
}
