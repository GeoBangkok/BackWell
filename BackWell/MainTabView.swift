//
//  MainTabView.swift
//  SkinGlowing
//
//  Main app: Today, Scan, GlowUp Plan, Arisa, Profile
//

import SwiftUI
import UIKit

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showingHistory = false
    @State private var hasPrivacyConsent = UserDefaults.standard.bool(forKey: "userDataSharingConsent")
    @ObservedObject private var historyManager = ScanHistoryManager.shared

    private var aiContext: String {
        let skinType = UserDefaults.standard.string(forKey: "sg_skinType") ?? "Not sure"
        let goals = UserDefaults.standard.array(forKey: "sg_goals") as? [String] ?? []
        let concerns = UserDefaults.standard.array(forKey: "sg_concerns") as? [String] ?? []
        let face = historyManager.latestFaceScan
        let product = historyManager.productScans.first

        return """
        SkinGlowing profile context:
        Skin type: \(skinType)
        Goals: \(goals.joined(separator: ", "))
        Concerns: \(concerns.joined(separator: ", "))
        Latest face scan: glow \(face?.glowScore ?? 0), skin age \(face?.skinAge ?? 0), glass skin \(face?.glassSkinTier.label ?? "None"), blemish score \(face?.blemishScore ?? 0), texture \(face?.textureScore ?? 0), redness \(face?.rednessScore ?? 0), hydration look \(face?.hydrationLookScore ?? 0), firmness \(String(format: "%.1f", face?.firmnessScore ?? 0)).
        Latest product scan: \(product?.productName ?? "None"), fit \(product?.compatibilityScore ?? 0)/10, breakout risk \(product?.breakoutRisk ?? 0), irritation \(product?.irritationRisk.rawValue ?? "None").
        Give consumer wellness guidance only, not diagnosis.
        """
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                TabView(selection: $selectedTab) {
                    TodayDashboardView(selectedTab: $selectedTab)
                        .tag(0)

                    UnifiedScanHubView()
                        .tag(1)

                    GlowUpPlanView(selectedTab: $selectedTab)
                        .tag(2)

                    ArisaAIView(profileContext: aiContext)
                        .tag(3)

                    ProfileHubView(showingHistory: $showingHistory)
                        .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                SGMainTabBar(selectedTab: $selectedTab)
            }
            .background(Theme.backgroundSecondary.ignoresSafeArea())
            .preferredColorScheme(.light)
            .sheet(isPresented: $showingHistory) {
                ArchiveView()
            }

            if !hasPrivacyConsent {
                PrivacyPolicyBannerView(hasConsented: $hasPrivacyConsent)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.easeInOut(duration: 0.35), value: hasPrivacyConsent)
    }
}

// MARK: - Today

struct TodayDashboardView: View {
    @Binding var selectedTab: Int
    @ObservedObject private var historyManager = ScanHistoryManager.shared

    var body: some View {
        SGScreen(title: "SkinGlowing") {
            VStack(alignment: .leading, spacing: 18) {
                hero
                latestSignalGrid
                actionRow
                focusPlanPreview
                recentProductPreview
            }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Theme.captionText)

                    Text(todayHeadline)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(Theme.headline)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                GlowScoreBadge(score: historyManager.latestFaceScan?.glowScore ?? 0)
            }

            Text(todaySubhead)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Theme.bodyText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(8)
    }

    private var latestSignalGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            let scan = historyManager.latestFaceScan
            MetricTile(title: "Skin Age", value: scan.map { "\($0.skinAge)" } ?? "--", detail: scan?.skinAgeMicro ?? "Scan to establish baseline.", icon: "clock")
            MetricTile(title: "Glass Skin", value: "\(scan?.glassSkinScore ?? 0)", detail: scan?.glassSkinMicro ?? "Glow and reflection score.", icon: "sparkles")
            MetricTile(title: "Texture", value: "\(scan?.textureScore ?? 0)", detail: scan?.textureMicro ?? "Smoothness and visible grain.", icon: "circle.grid.3x3.fill")
            MetricTile(title: "Hydration", value: "\(scan?.hydrationLookScore ?? 0)", detail: scan?.hydrationMicro ?? "Surface plumpness signal.", icon: "drop.fill")
        }
    }

    private var actionRow: some View {
        HStack(spacing: 10) {
            Button {
                hapticFeedback(.medium)
                selectedTab = 1
            } label: {
                Label("Scan", systemImage: "viewfinder")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(SGPrimaryButtonStyle())

            Button {
                hapticFeedback(.light)
                selectedTab = 3
            } label: {
                Image(systemName: "message.fill")
                    .frame(width: 54, height: 54)
            }
            .buttonStyle(SGIconButtonStyle())
        }
    }

    private var focusPlanPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            SGSectionHeader(title: "90-Day Focus", action: "Open") {
                selectedTab = 2
            }

            let focus = historyManager.latestFaceScan?.planFocus ?? ["Hydration", "Texture", "Glow"]
            ForEach(Array(focus.prefix(3).enumerated()), id: \.offset) { index, item in
                PlanRow(dayRange: index == 0 ? "Days 1-30" : index == 1 ? "Days 31-60" : "Days 61-90", title: item)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(8)
    }

    private var recentProductPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            SGSectionHeader(title: "Product Fit", action: "Scan") {
                selectedTab = 1
            }

            if let product = historyManager.productScans.first {
                ProductFitCompact(result: product)
            } else {
                Text("Scan makeup, SPF, serums, or ingredient labels to see breakout risk, irritation risk, pore-clogging risk, and glow support.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Theme.bodyText)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(8)
    }

    private var todayHeadline: String {
        guard let scan = historyManager.latestFaceScan else { return "Start with one selfie." }
        if (scan.glowScore ?? 0) >= 80 { return "Your glow is trending strong." }
        if (scan.rednessScore ?? 100) < 65 { return "Calm the skin barrier today." }
        return "Build your glow baseline."
    }

    private var todaySubhead: String {
        guard let scan = historyManager.latestFaceScan else {
            return "Scan once to unlock your metrics, 90-day plan, and product compatibility context."
        }
        return scan.glowAdvice
    }
}

// MARK: - Scan Hub

struct UnifiedScanHubView: View {
    @ObservedObject private var historyManager = ScanHistoryManager.shared
    @State private var selectedMode: ScanMode = .face
    @State private var showImagePicker = false
    @State private var imagePickerSource: UIImagePickerController.SourceType = .camera
    @State private var capturedImage: UIImage?
    @State private var isAnalyzing = false
    @State private var faceResult: FaceScanResult?
    @State private var productResult: ProductScanResult?
    @State private var errorMessage: String?

    enum ScanMode: String, CaseIterable {
        case face = "Face"
        case product = "Product"

        var icon: String {
            switch self {
            case .face: return "face.smiling"
            case .product: return "barcode.viewfinder"
            }
        }

        var title: String {
            switch self {
            case .face: return "Skin Signal Scan"
            case .product: return "Makeup + Cosmetic Scan"
            }
        }

        var subtitle: String {
            switch self {
            case .face: return "Selfie analysis for glow, blemishes, texture, redness, tone, hydration, firmness, and under-eye signals."
            case .product: return "Scan makeup, SPF, skincare packaging, or an ingredient label for fit and risk signals."
            }
        }
    }

    var body: some View {
        SGScreen(title: "Scan") {
            VStack(alignment: .leading, spacing: 18) {
                modePicker
                scanCard

                if isAnalyzing {
                    analyzingCard
                } else if let faceResult, selectedMode == .face {
                    FaceResultSummary(result: faceResult)
                } else if let productResult, selectedMode == .product {
                    ProductResultSummary(result: productResult)
                } else {
                    metricPreview
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Theme.statusRed)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Theme.statusRed.opacity(0.08))
                        .cornerRadius(8)
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $capturedImage, sourceType: imagePickerSource)
        }
        .onChange(of: capturedImage) { image in
            guard let image else { return }
            analyze(image)
        }
    }

    private var modePicker: some View {
        HStack(spacing: 8) {
            ForEach(ScanMode.allCases, id: \.self) { mode in
                Button {
                    hapticFeedback(.light)
                    selectedMode = mode
                    errorMessage = nil
                } label: {
                    Label(mode.rawValue, systemImage: mode.icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(selectedMode == mode ? .white : Theme.bodyText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedMode == mode ? Theme.headline : Color.white)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    private var scanCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 14) {
                Image(systemName: selectedMode.icon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Theme.accent)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 6) {
                    Text(selectedMode.title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Theme.headline)

                    Text(selectedMode.subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Theme.bodyText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            HStack(spacing: 10) {
                Button {
                    hapticFeedback(.medium)
                    imagePickerSource = .camera
                    showImagePicker = true
                } label: {
                    Label("Camera", systemImage: "camera.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SGPrimaryButtonStyle())

                Button {
                    hapticFeedback(.light)
                    imagePickerSource = .photoLibrary
                    showImagePicker = true
                } label: {
                    Image(systemName: "photo")
                        .frame(width: 54, height: 54)
                }
                .buttonStyle(SGIconButtonStyle())
            }
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(8)
    }

    private var analyzingCard: some View {
        VStack(spacing: 14) {
            ProgressView()
                .tint(Theme.accent)
                .scaleEffect(1.1)

            Text(selectedMode == .face ? "Reading your skin signals..." : "Reading product fit...")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(Theme.headline)

            Text("OpenAI is analyzing the image with your onboarding profile and latest scan context.")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Theme.bodyText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(22)
        .background(Color.white)
        .cornerRadius(8)
    }

    private var metricPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(selectedMode == .face ? "Metrics Tracked" : "Product Signals")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Theme.headline)

            let items = selectedMode == .face
            ? ["Glow Score", "Skin Age", "Glass Skin", "Blemishes", "Texture", "Redness", "Even Tone", "Hydration Look", "Firmness", "Under-Eye"]
            : ["Product Fit", "Breakout Risk", "Irritation Risk", "Dryness Risk", "Pore-Clogging Risk", "Glow Support", "Makeup Match"]

            FlowTagList(items: items)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(8)
    }

    private func analyze(_ image: UIImage) {
        guard !isAnalyzing else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.82) else {
            errorMessage = "Could not prepare image. Try another photo."
            return
        }

        isAnalyzing = true
        errorMessage = nil

        let skinType = UserDefaults.standard.string(forKey: "sg_skinType") ?? ""
        let goals = UserDefaults.standard.array(forKey: "sg_goals") as? [String] ?? []
        let concerns = UserDefaults.standard.array(forKey: "sg_concerns") as? [String] ?? []
        let userConcerns = goals + concerns

        Task {
            do {
                if selectedMode == .face {
                    let result = try await OpenAIService.shared.analyzeFaceScan(
                        imageData: imageData,
                        userConcerns: userConcerns,
                        userSkinType: skinType,
                        previousScan: historyManager.latestFaceScan
                    )
                    await MainActor.run {
                        faceResult = result
                        productResult = nil
                        historyManager.addFaceScan(result)
                        isAnalyzing = false
                        capturedImage = nil
                    }
                } else {
                    let result = try await OpenAIService.shared.analyzeProductScan(
                        imageData: imageData,
                        userSkinType: skinType,
                        latestFaceScan: historyManager.latestFaceScan
                    )
                    await MainActor.run {
                        productResult = result
                        faceResult = nil
                        historyManager.addProductScan(result)
                        isAnalyzing = false
                        capturedImage = nil
                    }
                }
            } catch {
                await MainActor.run {
                    isAnalyzing = false
                    capturedImage = nil
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - Plan

struct GlowUpPlanView: View {
    @Binding var selectedTab: Int
    @ObservedObject private var historyManager = ScanHistoryManager.shared

    var body: some View {
        SGScreen(title: "GlowUp Plan") {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("90 days to visible progress.")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Theme.headline)

                    Text("Built from your onboarding answers, selfie scans, and product compatibility history.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Theme.bodyText)
                }
                .padding(18)
                .background(Color.white)
                .cornerRadius(8)

                ForEach(planPhases.indices, id: \.self) { index in
                    PlanPhaseCard(phase: planPhases[index], index: index)
                }

                Button {
                    hapticFeedback(.medium)
                    selectedTab = 1
                } label: {
                    Label("Update Plan With New Scan", systemImage: "viewfinder")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SGPrimaryButtonStyle())
            }
        }
    }

    private var focus: [String] {
        historyManager.latestFaceScan?.planFocus ?? ["Hydration", "Texture", "Glow"]
    }

    private var planPhases: [PlanPhase] {
        [
            PlanPhase(range: "Days 1-30", title: "Reset", focus: focus[safe: 0] ?? "Hydration", actions: ["Lock in SPF every morning", "Scan twice weekly", "Avoid products with high irritation risk"]),
            PlanPhase(range: "Days 31-60", title: "Build", focus: focus[safe: 1] ?? "Texture", actions: ["Track texture and redness trends", "Keep one active consistent", "Scan new makeup before daily wear"]),
            PlanPhase(range: "Days 61-90", title: "Optimize", focus: focus[safe: 2] ?? "Glow", actions: ["Compare glow score trend", "Refine products by fit score", "Ask Arisa for routine adjustments"])
        ]
    }
}

// MARK: - Profile

struct ProfileHubView: View {
    @Binding var showingHistory: Bool
    @ObservedObject private var historyManager = ScanHistoryManager.shared

    var body: some View {
        SGScreen(title: "Profile") {
            VStack(alignment: .leading, spacing: 18) {
                profileCard
                historyCard
                SettingsView()
                    .background(Color.white)
                    .cornerRadius(8)
            }
        }
    }

    private var profileCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Skin Profile")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Theme.headline)

            ProfileLine(label: "Skin type", value: UserDefaults.standard.string(forKey: "sg_skinType") ?? "Not set")
            ProfileLine(label: "Goals", value: ((UserDefaults.standard.array(forKey: "sg_goals") as? [String]) ?? []).joined(separator: ", ").nilIfEmpty ?? "Not set")
            ProfileLine(label: "Concerns", value: ((UserDefaults.standard.array(forKey: "sg_concerns") as? [String]) ?? []).joined(separator: ", ").nilIfEmpty ?? "Not set")
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(8)
    }

    private var historyCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("History")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Theme.headline)
                    Text("\(historyManager.faceScans.count) skin scans, \(historyManager.productScans.count) product scans")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Theme.bodyText)
                }

                Spacer()

                Button {
                    hapticFeedback(.light)
                    showingHistory = true
                } label: {
                    Image(systemName: "clock.arrow.circlepath")
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(SGIconButtonStyle())
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(8)
    }
}

// MARK: - Components

struct SGScreen<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                Text(title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Theme.headline)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 10)

                content
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 108)
        }
        .background(Theme.backgroundSecondary.ignoresSafeArea())
    }
}

struct SGMainTabBar: View {
    @Binding var selectedTab: Int

    private let items: [(String, String)] = [
        ("house.fill", "Today"),
        ("viewfinder", "Scan"),
        ("calendar.badge.clock", "Plan"),
        ("message.fill", "Arisa"),
        ("person.crop.circle.fill", "Profile")
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items.indices, id: \.self) { index in
                SGTabItem(icon: items[index].0, title: items[index].1, isSelected: selectedTab == index) {
                    hapticFeedback(.light)
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.86)) {
                        selectedTab = index
                    }
                }
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 22)
        .background(
            Color.white
                .shadow(color: Color.black.opacity(0.07), radius: 12, x: 0, y: -2)
        )
    }
}

struct SGTabItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 21, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? Theme.accent : Theme.captionText)
                    .frame(height: 24)

                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? Theme.accent : Theme.captionText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SGPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
            .frame(height: 54)
            .background(configuration.isPressed ? Theme.accent.opacity(0.78) : Theme.accent)
            .cornerRadius(8)
    }
}

struct SGIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(Theme.accent)
            .background(configuration.isPressed ? Theme.accentSoft.opacity(0.7) : Theme.accentSoft)
            .cornerRadius(8)
    }
}

struct GlowScoreBadge: View {
    let score: Int

    var body: some View {
        VStack(spacing: 2) {
            Text(score > 0 ? "\(score)" : "--")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            Text("Glow")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white.opacity(0.9))
        }
        .frame(width: 70, height: 70)
        .background(Theme.accent)
        .clipShape(Circle())
    }
}

struct MetricTile: View {
    let title: String
    let value: String
    let detail: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Theme.accent)
                Spacer()
                Text(value)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Theme.headline)
            }

            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Theme.headline)

            Text(detail)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Theme.bodyText)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 118, alignment: .topLeading)
        .padding(14)
        .background(Color.white)
        .cornerRadius(8)
    }
}

struct SGSectionHeader: View {
    let title: String
    let action: String
    let onAction: () -> Void

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Theme.headline)
            Spacer()
            Button(action) {
                hapticFeedback(.light)
                onAction()
            }
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(Theme.accent)
        }
    }
}

struct PlanRow: View {
    let dayRange: String
    let title: String

    var body: some View {
        HStack(spacing: 12) {
            Text(dayRange)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Theme.accent)
                .frame(width: 82, alignment: .leading)

            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Theme.headline)

            Spacer()
        }
        .padding(12)
        .background(Theme.backgroundSecondary)
        .cornerRadius(8)
    }
}

struct ProductFitCompact: View {
    let result: ProductScanResult

    var body: some View {
        HStack(spacing: 12) {
            Text("\(result.compatibilityScore)/10")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 64, height: 64)
                .background(Theme.headline)
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 5) {
                Text(result.productName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Theme.headline)
                    .lineLimit(1)

                Text(result.microExplanation)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Theme.bodyText)
                    .lineLimit(2)
            }

            Spacer()
        }
    }
}

struct FaceResultSummary: View {
    let result: FaceScanResult

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Latest Skin Results")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Theme.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ResultPill(label: "Glow", value: "\(result.glowScore ?? 0)")
                ResultPill(label: "Glass", value: "\(result.glassSkinScore ?? 0)")
                ResultPill(label: "Blemishes", value: "\(result.blemishScore ?? 0)")
                ResultPill(label: "Redness", value: "\(result.rednessScore ?? 0)")
                ResultPill(label: "Even Tone", value: "\(result.evenToneScore ?? 0)")
                ResultPill(label: "Under-Eye", value: "\(result.underEyeScore ?? 0)")
            }

            Text(result.glowAdvice)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Theme.bodyText)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(8)
    }
}

struct ProductResultSummary: View {
    let result: ProductScanResult

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(result.productName)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Theme.headline)

            ProductFitCompact(result: result)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ResultPill(label: "Breakout Risk", value: "\(result.breakoutRisk ?? 0)")
                ResultPill(label: "Dryness Risk", value: "\(result.drynessRisk ?? 0)")
                ResultPill(label: "Pore Risk", value: "\(result.poreCloggingRisk ?? 0)")
                ResultPill(label: "Makeup Match", value: "\(result.makeupMatchScore ?? 0)")
            }

            if let advice = result.usageAdvice {
                Text(advice)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Theme.bodyText)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(8)
    }
}

struct ResultPill: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Theme.bodyText)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Spacer()
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Theme.headline)
        }
        .padding(12)
        .background(Theme.backgroundSecondary)
        .cornerRadius(8)
    }
}

struct FlowTagList: View {
    let items: [String]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 116), spacing: 8)], spacing: 8) {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Theme.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Theme.backgroundSecondary)
                    .cornerRadius(8)
            }
        }
    }
}

struct PlanPhase {
    let range: String
    let title: String
    let focus: String
    let actions: [String]
}

struct PlanPhaseCard: View {
    let phase: PlanPhase
    let index: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(phase.range)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Theme.accent)
                    Text("\(phase.title): \(phase.focus)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Theme.headline)
                }

                Spacer()

                Text("\(index + 1)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 38, height: 38)
                    .background(Theme.headline)
                    .clipShape(Circle())
            }

            ForEach(phase.actions, id: \.self) { action in
                Label(action, systemImage: "checkmark.circle.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Theme.bodyText)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(8)
    }
}

struct ProfileLine: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Theme.captionText)
                .frame(width: 78, alignment: .leading)

            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Theme.headline)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}

// MARK: - Backward Compatibility Stubs

struct ModernTabBar: View {
    @Binding var selectedTab: Int
    @Binding var showingScanModal: Bool
    let namespace: Namespace.ID
    var body: some View { EmptyView() }
}

struct TabBarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    var body: some View { EmptyView() }
}

#Preview {
    MainTabView()
}
