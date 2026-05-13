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
            .background(Theme.blushBackground.ignoresSafeArea())
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
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 10) {
                    SGBrandMark(size: 17)

                    Text(todayHeadline)
                        .font(.system(size: 34, weight: .regular, design: .serif))
                        .foregroundColor(Theme.headline)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(todaySubhead)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Theme.bodyText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                VStack(spacing: 10) {
                    GlowScoreBadge(score: historyManager.latestFaceScan?.glowScore ?? 0)
                    SGSparkleBubble()
                }
            }

            HStack(spacing: 8) {
                MiniSignalPill(icon: "sparkles", title: "AI-Powered")
                MiniSignalPill(icon: "circle.dashed", title: "360 Analysis")
                MiniSignalPill(icon: "heart.fill", title: "Personal")
            }
        }
        .padding(18)
        .sgGlassCard()
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
        .sgGlassCard()
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
        .sgGlassCard()
    }

    private var todayHeadline: String {
        guard let scan = historyManager.latestFaceScan else { return "Your Personal\nSkin Coach" }
        if (scan.glowScore ?? 0) >= 80 { return "Your glow is trending strong." }
        if (scan.rednessScore ?? 100) < 65 { return "Calm the skin barrier today." }
        return "Build your 90-Day\nGlow Plan."
    }

    private var todaySubhead: String {
        guard let scan = historyManager.latestFaceScan else {
            return "Scan your face in full depth to unlock metrics, a personalized plan, and product compatibility."
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
                        .background(selectedMode == mode ? AnyShapeStyle(Theme.pinkButtonGradient) : AnyShapeStyle(Color.white.opacity(0.82)))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.white.opacity(0.72), lineWidth: 1))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    private var scanCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            ZStack(alignment: .bottomLeading) {
                Image("onboarding_scan_face")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 260)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            colors: [.clear, Color.white.opacity(0.92)],
                            startPoint: .center,
                            endPoint: .bottom
                        )
                    )

                ScanOverlayLines()

                VStack(alignment: .leading, spacing: 8) {
                    Text(selectedMode == .face ? "Scanning your face\nin full depth" : "Scan every cosmetic.\nImprove your glow.")
                        .font(.system(size: 30, weight: .regular, design: .serif))
                        .foregroundColor(Theme.headline)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(selectedMode.subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Theme.bodyText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(18)
            }
            .clipShape(RoundedRectangle(cornerRadius: Theme.cardCorner, style: .continuous))

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
            .padding(.horizontal, 18)
            .padding(.bottom, 18)
        }
        .sgGlassCard()
    }

    private var analyzingCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 14) {
                ProgressView()
                    .tint(Theme.accent)
                    .scaleEffect(1.2)

                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedMode == .face ? "Analyzing depth, texture, tone, and glow factors..." : "Reading product score, ingredients, and skin impact...")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Theme.headline)

                    Text("OpenAI is using your image, onboarding profile, and latest scan context.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Theme.bodyText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            HStack(spacing: 0) {
                ScanStep(icon: "face.smiling", title: "Scanning", active: true)
                ScanStep(icon: "chart.bar.fill", title: "Analyzing", active: true)
                ScanStep(icon: "sparkles", title: "Plan", active: false)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(18)
        .sgGlassCard()
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
        .sgGlassCard()
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
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your 90-Day")
                                .font(.system(size: 34, weight: .regular, design: .serif))
                                .foregroundColor(Theme.headline)
                            Text("Glow Plan")
                                .font(.system(size: 34, weight: .regular, design: .serif))
                                .foregroundColor(Theme.accent)
                        }

                        Spacer()
                        SGSparkleBubble()
                    }

                    HStack(alignment: .center, spacing: 14) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Day \(currentDay)")
                                .font(.system(size: 26, weight: .regular, design: .serif))
                                .foregroundColor(Theme.accent)
                            Text(planStatusText)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Theme.bodyText)
                        }

                        Spacer()

                        Text("\(planProgress)%")
                            .font(.system(size: 30, weight: .regular, design: .serif))
                            .foregroundColor(Theme.accent)
                    }

                    GlowPlanProgress(day: currentDay)

                    Text("Built from your onboarding answers, selfie scans, and product compatibility history.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Theme.bodyText)
                }
                .padding(18)
                .sgGlassCard()

                dailyPlanCard

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

    private var skinType: String {
        UserDefaults.standard.string(forKey: "sg_skinType") ?? "Not sure"
    }

    private var concerns: [String] {
        let goals = UserDefaults.standard.array(forKey: "sg_goals") as? [String] ?? []
        let concerns = UserDefaults.standard.array(forKey: "sg_concerns") as? [String] ?? []
        return goals + concerns
    }

    private var currentDay: Int {
        guard let scan = historyManager.latestFaceScan else { return 1 }
        let days = Calendar.current.dateComponents([.day], from: scan.timestamp.startOfDay, to: Date().startOfDay).day ?? 0
        return min(90, max(1, days + 1))
    }

    private var planProgress: Int {
        Int(round(Double(currentDay) / 90.0 * 100.0))
    }

    private var planStatusText: String {
        historyManager.latestFaceScan == nil ? "Start with your first scan." : "Sequential plan from your latest scan."
    }

    private var dailyTasks: [GlowPlanDay] {
        GlowPlanBuilder.days(
            focus: focus,
            skinType: skinType,
            concerns: concerns,
            latestScan: historyManager.latestFaceScan,
            productScan: historyManager.productScans.first
        )
    }

    private var visibleDailyTasks: [GlowPlanDay] {
        Array(dailyTasks.dropFirst(currentDay - 1).prefix(7))
    }

    private var dailyPlanCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Next 7 Days")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Theme.headline)
                    Text("Starts at Day 1 and updates after every scan.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Theme.bodyText)
                }
                Spacer()
            }

            ForEach(visibleDailyTasks) { task in
                GlowPlanDayRow(task: task, isToday: task.day == currentDay)
            }
        }
        .padding(16)
        .sgGlassCard()
    }

    private var planPhases: [PlanPhase] {
        GlowPlanBuilder.phases(focus: focus, skinType: skinType, concerns: concerns, latestScan: historyManager.latestFaceScan, productScan: historyManager.productScans.first)
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
                    .sgGlassCard()
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
        .sgGlassCard()
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
        .sgGlassCard()
    }
}

// MARK: - Components

struct SGScreen<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                SGBrandMark(size: 20)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 10)

                if title != "SkinGlowing" {
                    Text(title)
                        .font(.system(size: 28, weight: .regular, design: .serif))
                        .foregroundColor(Theme.headline)
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                content
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 108)
        }
        .background(Theme.blushBackground.ignoresSafeArea())
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
        .background(.ultraThinMaterial)
        .overlay(Rectangle().fill(Color.white.opacity(0.55)).frame(height: 1), alignment: .top)
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
            .background(configuration.isPressed ? AnyShapeStyle(Theme.accent.opacity(0.78)) : AnyShapeStyle(Theme.pinkButtonGradient))
            .clipShape(Capsule())
            .shadow(color: Theme.accent.opacity(configuration.isPressed ? 0.12 : 0.24), radius: 12, x: 0, y: 7)
    }
}

struct SGIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(Theme.accent)
            .background(configuration.isPressed ? Theme.accentSoft.opacity(0.7) : Color.white.opacity(0.78))
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white.opacity(0.75), lineWidth: 1))
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
        .background(Theme.pinkButtonGradient)
        .clipShape(Circle())
        .shadow(color: Theme.accent.opacity(0.28), radius: 12, x: 0, y: 8)
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
        .sgGlassCard()
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
        .background(Color.white.opacity(0.58))
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
            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Latest Skin Results")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Theme.headline)
                    Text(result.glowAdvice)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Theme.bodyText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Text("\(result.glowScore ?? 0)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 62, height: 62)
                    .background(Theme.pinkButtonGradient)
                    .clipShape(Circle())
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ResultPill(label: "Glow", value: "\(result.glowScore ?? 0)")
                ResultPill(label: "Glass", value: "\(result.glassSkinScore ?? 0)")
                ResultPill(label: "Blemishes", value: "\(result.blemishScore ?? 0)")
                ResultPill(label: "Redness", value: "\(result.rednessScore ?? 0)")
                ResultPill(label: "Even Tone", value: "\(result.evenToneScore ?? 0)")
                ResultPill(label: "Under-Eye", value: "\(result.underEyeScore ?? 0)")
                ResultPill(label: "Texture", value: "\(result.textureScore ?? 0)")
                ResultPill(label: "Hydration", value: "\(result.hydrationLookScore ?? 0)")
            }

            VStack(alignment: .leading, spacing: 10) {
                ScanInsightRow(title: "Skin Age", value: "\(result.skinAge)", detail: result.skinAgeMicro)
                ScanInsightRow(title: "Glass Skin", value: result.glassSkinTier.label, detail: result.glassSkinMicro)
                ScanInsightRow(title: "Blemish Zone", value: result.blemishZone, detail: result.blemishMicro)
                ScanInsightRow(title: "Texture", value: "\(result.textureScore ?? 0)", detail: result.textureMicro ?? "Texture detail unavailable.")
                ScanInsightRow(title: "Redness", value: "\(result.rednessScore ?? 0)", detail: result.rednessMicro ?? "Redness detail unavailable.")
                ScanInsightRow(title: "Hydration Look", value: "\(result.hydrationLookScore ?? 0)", detail: result.hydrationMicro ?? "Hydration detail unavailable.")
                ScanInsightRow(title: "Under-Eye", value: "\(result.underEyeScore ?? 0)", detail: result.underEyeMicro ?? "Under-eye detail unavailable.")
            }

            if let faceAreas = result.faceAreas, !faceAreas.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Face Areas")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Theme.headline)

                    ForEach(faceAreas) { area in
                        FaceAreaResultRow(area: area)
                    }
                }
            }

            if let focus = result.planFocus, !focus.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Plan Focus")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Theme.headline)
                    FlowTagList(items: focus)
                }
            }
        }
        .padding(16)
        .sgGlassCard()
    }
}

struct FaceAreaResultRow: View {
    let area: FaceAreaResult

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(area.area)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Theme.headline)
                    Text(area.primaryConcern)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Theme.accent)
                }

                Spacer()

                Text("\(area.score)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 38, height: 38)
                    .background(Theme.pinkButtonGradient)
                    .clipShape(Circle())
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(area.visibleSigns)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Theme.bodyText)
                    .fixedSize(horizontal: false, vertical: true)

                Text(area.recommendation)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Theme.headline)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.56))
        .cornerRadius(8)
    }
}

struct ScanInsightRow: View {
    let title: String
    let value: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Theme.headline)
                Text(detail)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Theme.bodyText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(Theme.accent)
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
        }
        .padding(12)
        .background(Color.white.opacity(0.56))
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
        .sgGlassCard()
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
        .background(Color.white.opacity(0.58))
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
                .foregroundColor(Theme.accent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                    .background(Color.white.opacity(0.72))
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

struct GlowPlanDay: Identifiable {
    let id = UUID()
    let day: Int
    let title: String
    let action: String
    let reason: String
}

enum GlowPlanBuilder {
    static func phases(focus: [String], skinType: String, concerns: [String], latestScan: FaceScanResult?, productScan: ProductScanResult?) -> [PlanPhase] {
        let primary = focus[safe: 0] ?? "Hydration"
        let secondary = focus[safe: 1] ?? "Texture"
        let tertiary = focus[safe: 2] ?? "Glow"
        let productAction = productScan == nil ? "Scan makeup or SPF before using it daily" : "Use product fit scores to avoid low-match products"

        return [
            PlanPhase(
                range: "Days 1-30",
                title: "Reset",
                focus: primary,
                actions: [
                    action(for: primary, phase: 1, skinType: skinType, scan: latestScan),
                    "Take baseline scans on Days 1, 7, 14, and 30",
                    productAction
                ]
            ),
            PlanPhase(
                range: "Days 31-60",
                title: "Build",
                focus: secondary,
                actions: [
                    action(for: secondary, phase: 2, skinType: skinType, scan: latestScan),
                    "Keep one active consistent for 3-4 weeks before judging it",
                    "Compare texture, redness, and glow trend every Sunday"
                ]
            ),
            PlanPhase(
                range: "Days 61-90",
                title: "Optimize",
                focus: tertiary,
                actions: [
                    action(for: tertiary, phase: 3, skinType: skinType, scan: latestScan),
                    "Refine routine based on the best-scoring scan weeks",
                    "Ask Arisa for adjustments when a score stalls for 2 scans"
                ]
            )
        ]
    }

    static func days(focus: [String], skinType: String, concerns: [String], latestScan: FaceScanResult?, productScan: ProductScanResult?) -> [GlowPlanDay] {
        let focusList = focus.isEmpty ? ["Hydration", "Texture", "Glow"] : focus
        return (1...90).map { day in
            let activeFocus = focusList[(day - 1) % min(focusList.count, 3)]
            return GlowPlanDay(
                day: day,
                title: dayTitle(for: day, focus: activeFocus),
                action: dayAction(for: day, focus: activeFocus, skinType: skinType, latestScan: latestScan, productScan: productScan),
                reason: dayReason(for: day, focus: activeFocus, latestScan: latestScan)
            )
        }
    }

    private static func dayTitle(for day: Int, focus: String) -> String {
        if day == 1 { return "Baseline + \(focus)" }
        if day % 7 == 0 { return "Weekly Check-In" }
        if day % 14 == 0 { return "Progress Scan" }
        return "\(focus) Day"
    }

    private static func dayAction(for day: Int, focus: String, skinType: String, latestScan: FaceScanResult?, productScan: ProductScanResult?) -> String {
        if day == 1 {
            return "Take your baseline selfie, save your current routine, and keep products unchanged for 7 days."
        }
        if day % 14 == 0 {
            return "Retake your selfie scan in the same lighting and compare glow, redness, texture, and hydration."
        }
        if day % 7 == 0 {
            return "Review the week: note irritation, breakouts, sleep, water, SPF, and any new products."
        }
        return action(for: focus, phase: day <= 30 ? 1 : day <= 60 ? 2 : 3, skinType: skinType, scan: latestScan)
    }

    private static func dayReason(for day: Int, focus: String, latestScan: FaceScanResult?) -> String {
        if let scan = latestScan {
            switch focus.lowercased() {
            case let value where value.contains("red") || value.contains("barrier") || value.contains("calm"):
                return "Your redness signal is \(scan.rednessScore ?? 0), so the plan protects barrier consistency."
            case let value where value.contains("texture"):
                return "Your texture signal is \(scan.textureScore ?? 0), so the plan favors steady, low-irritation improvement."
            case let value where value.contains("hydration"):
                return "Your hydration-look signal is \(scan.hydrationLookScore ?? 0), so the plan prioritizes plumpness and moisture retention."
            case let value where value.contains("breakout") || value.contains("blemish"):
                return "Your blemish signal is \(scan.blemishScore ?? 0), so the plan avoids product chaos."
            default:
                return "Your glow score is \(scan.glowScore ?? 0), so today's step supports visible radiance."
            }
        }
        return "This builds a clean baseline before personalization gets stronger after your first scan."
    }

    private static func action(for focus: String, phase: Int, skinType: String, scan: FaceScanResult?) -> String {
        let normalized = focus.lowercased()
        if normalized.contains("breakout") || normalized.contains("blemish") {
            return phase == 1 ? "Keep the routine simple: gentle cleanse, light moisturizer, SPF, no new actives today." : "Introduce only one acne-support step at night and track blemish score changes."
        }
        if normalized.contains("barrier") || normalized.contains("calm") || normalized.contains("red") {
            return "Avoid exfoliation today; use a calming moisturizer and keep water lukewarm."
        }
        if normalized.contains("hydration") || skinType.lowercased().contains("dry") {
            return "Layer hydration: damp skin, humectant serum, moisturizer, then SPF in the morning."
        }
        if normalized.contains("texture") || normalized.contains("pore") {
            return phase == 1 ? "Do not exfoliate yet; stabilize cleansing and SPF first." : "Use a gentle texture step only if redness and dryness stayed calm this week."
        }
        if normalized.contains("tone") || normalized.contains("spot") {
            return "Prioritize SPF and avoid picking; tone progress depends on daily UV consistency."
        }
        return "Protect the glow basics: cleanse gently, moisturize, SPF, and avoid adding new products today."
    }
}

struct GlowPlanDayRow: View {
    let task: GlowPlanDay
    let isToday: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 2) {
                Text("Day")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(isToday ? .white.opacity(0.82) : Theme.accent)
                Text("\(task.day)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isToday ? .white : Theme.accent)
            }
            .frame(width: 48, height: 48)
            .background(isToday ? AnyShapeStyle(Theme.pinkButtonGradient) : AnyShapeStyle(Color.white.opacity(0.70)))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 5) {
                Text(task.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Theme.headline)
                Text(task.action)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Theme.bodyText)
                    .fixedSize(horizontal: false, vertical: true)
                Text(task.reason)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Theme.captionText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .background(isToday ? Theme.accentSoft.opacity(0.72) : Color.white.opacity(0.52))
        .cornerRadius(8)
    }
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
                    .font(.system(size: 20, weight: .regular, design: .serif))
                    .foregroundColor(Theme.headline)
                }

                Spacer()

                Text("\(index + 1)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 38, height: 38)
                    .background(Theme.pinkButtonGradient)
                    .clipShape(Circle())
            }

            ForEach(phase.actions, id: \.self) { action in
                Label(action, systemImage: "checkmark.circle.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Theme.bodyText)
            }
        }
        .padding(16)
        .sgGlassCard()
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

struct SGBrandMark: View {
    let size: CGFloat

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "sparkle")
                .font(.system(size: size, weight: .bold))
                .foregroundColor(Theme.accent)

            Text("SkinGlowing")
                .font(.system(size: size + 6, weight: .regular, design: .serif))
                .foregroundColor(Theme.accent)
        }
    }
}

struct SGSparkleBubble: View {
    var body: some View {
        Image(systemName: "sparkles")
            .font(.system(size: 22, weight: .semibold))
            .foregroundColor(Theme.accent)
            .frame(width: 58, height: 58)
            .background(Color.white.opacity(0.72))
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white.opacity(0.85), lineWidth: 1))
            .shadow(color: Theme.accent.opacity(0.12), radius: 12, x: 0, y: 8)
    }
}

struct MiniSignalPill: View {
    let icon: String
    let title: String

    var body: some View {
        Label(title, systemImage: icon)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(Theme.headline)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .padding(.horizontal, 9)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.62))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.75), lineWidth: 1))
    }
}

struct ScanOverlayLines: View {
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height

            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.78), lineWidth: 2)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 22)

                Path { path in
                    path.move(to: CGPoint(x: width * 0.50, y: height * 0.18))
                    path.addLine(to: CGPoint(x: width * 0.50, y: height * 0.76))
                    path.move(to: CGPoint(x: width * 0.22, y: height * 0.50))
                    path.addLine(to: CGPoint(x: width * 0.78, y: height * 0.50))
                }
                .stroke(Color.white.opacity(0.82), style: StrokeStyle(lineWidth: 1.2, lineCap: .round, dash: [4, 7]))

                ForEach(0..<4) { index in
                    Circle()
                        .fill(Color.white.opacity(0.92))
                        .frame(width: 6, height: 6)
                        .position(
                            x: [0.34, 0.50, 0.62, 0.72][index] * width,
                            y: [0.42, 0.30, 0.56, 0.48][index] * height
                        )
                }
            }
        }
        .allowsHitTesting(false)
    }
}

struct ScanStep: View {
    let icon: String
    let title: String
    let active: Bool

    var body: some View {
        VStack(spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(active ? .white : Theme.accent.opacity(0.45))
                .frame(width: 34, height: 34)
                .background(active ? AnyShapeStyle(Theme.pinkButtonGradient) : AnyShapeStyle(Color.white.opacity(0.64)))
                .clipShape(Circle())

            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(active ? Theme.accent : Theme.captionText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }
}

struct GlowPlanProgress: View {
    let day: Int

    var body: some View {
        VStack(spacing: 12) {
            GeometryReader { proxy in
                let progress = min(1, max(0.01, Double(day) / 90.0))
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Theme.accent.opacity(0.14))
                    Capsule()
                        .fill(Theme.pinkButtonGradient)
                        .frame(width: proxy.size.width * progress)
                    Circle()
                        .fill(Color.white)
                        .frame(width: 18, height: 18)
                        .overlay(Circle().stroke(Theme.accent, lineWidth: 4))
                        .offset(x: max(0, proxy.size.width * progress - 9))
                }
            }
            .frame(height: 9)

            HStack {
                Text("Day 1")
                Spacer()
                Text("Day 45")
                Spacer()
                Text("Day 90")
            }
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(Theme.bodyText)
        }
    }
}

struct SGGlassCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .background(Color.white.opacity(0.70))
            .clipShape(RoundedRectangle(cornerRadius: Theme.cardCorner, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardCorner, style: .continuous)
                    .stroke(Theme.glassStroke, lineWidth: 1)
            )
            .shadow(color: Theme.cardShadowColor, radius: Theme.cardShadowRadius, x: 0, y: 8)
    }
}

extension View {
    func sgGlassCard() -> some View {
        modifier(SGGlassCardModifier())
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

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
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
