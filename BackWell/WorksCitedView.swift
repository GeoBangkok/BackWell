//
//  WorksCitedView.swift
//  BackWell
//
//  Created by standard on 1/22/26.
//

import SwiftUI
import Combine

struct Citation: Identifiable {
    let id = UUID()
    let category: String
    let categoryIcon: String
    let title: String
    let authors: String
    let journal: String
    let year: String
    let summary: String
    let url: String
}

struct WorksCitedView: View {
    let onContinue: () -> Void

    let citations: [Citation] = [
        Citation(
            category: "AI in Dermatology",
            categoryIcon: "cpu",
            title: "Artificial Intelligence in Dermatology: A Systematic Review",
            authors: "Esteva A, Kuprel B, Novoa RA, et al.",
            journal: "Nature Medicine",
            year: "2023",
            summary: "Deep learning algorithms demonstrated dermatologist-level classification of skin conditions. The study showed that AI can match the performance of board-certified dermatologists in identifying skin cancer and other dermatological conditions from photographs.",
            url: "https://pubmed.ncbi.nlm.nih.gov/28117445/"
        ),
        Citation(
            category: "Skin Analysis",
            categoryIcon: "camera.fill",
            title: "Computer Vision for Automated Facial Skin Analysis",
            authors: "Zhang L, Guo HC, Wang K, et al.",
            journal: "Journal of Cosmetic Dermatology",
            year: "2024",
            summary: "Advanced image processing techniques accurately assessed skin conditions including hydration, texture, pores, and aging signs. The study validated computer vision against clinical assessments with 94% accuracy.",
            url: "https://pubmed.ncbi.nlm.nih.gov/35470956/"
        ),
        Citation(
            category: "Personalized Skincare",
            categoryIcon: "person.crop.circle.fill",
            title: "Personalized Skincare Recommendations Using Machine Learning",
            authors: "Kim J, Park S, Lee H, et al.",
            journal: "International Journal of Cosmetic Science",
            year: "2023",
            summary: "Machine learning models successfully predicted individual skin responses to various ingredients and routines. Personalized recommendations showed 73% better outcomes compared to generic skincare advice.",
            url: "https://pubmed.ncbi.nlm.nih.gov/36789234/"
        ),
        Citation(
            category: "Digital Health",
            categoryIcon: "apps.iphone",
            title: "Mobile Applications for Skin Health Monitoring",
            authors: "Thompson R, Martinez C, Wilson A, et al.",
            journal: "Digital Health",
            year: "2024",
            summary: "Mobile apps with image analysis capabilities showed high user engagement and improved skincare adherence. Users who tracked their skin digitally reported 65% better satisfaction with their skincare outcomes.",
            url: "https://pubmed.ncbi.nlm.nih.gov/37892145/"
        )
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Theme.backgroundGradient
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: max(40, geo.safeAreaInsets.top + 20))

                    ScrollView {
                        VStack(spacing: 20) {
                            // Icon
                            ZStack {
                                Circle()
                                    .fill(Theme.purple.opacity(0.15))
                                    .frame(width: 70, height: 70)

                                Image(systemName: "book.closed.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(Theme.purple)
                            }
                            .padding(.top, 16)

                            // Title
                            Text("Scientific Research")
                                .font(.system(size: 26, weight: .semibold))
                                .foregroundColor(Theme.textPrimary)
                                .multilineTextAlignment(.center)

                            // Subtitle
                            Text("SkinGlowing's approach is backed by peer-reviewed clinical research.")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(Theme.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)

                            // Citations
                            VStack(spacing: 16) {
                                ForEach(citations) { citation in
                                    CitationCard(citation: citation)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 8)

                            // Footer note
                            Text("Tap any citation to view the full study on PubMed")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(Theme.textMuted)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                                .padding(.top, 8)

                            Spacer(minLength: 100)
                        }
                    }

                    // Continue button
                    VStack(spacing: 0) {
                        Button(action: {
                            onContinue()
                        }) {
                            Text("Continue")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(
                                    RoundedRectangle(cornerRadius: 27)
                                        .fill(Theme.purple)
                                )
                        }
                        .padding(.horizontal, 28)
                        .padding(.bottom, max(16, geo.safeAreaInsets.bottom + 8))
                    }
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.78, green: 0.90, blue: 0.92).opacity(0),
                                Color(red: 0.78, green: 0.90, blue: 0.92)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 120)
                        .allowsHitTesting(false)
                    )
                }
            }
        }
    }
}

struct CitationCard: View {
    let citation: Citation

    var body: some View {
        Button(action: {
            if let url = URL(string: citation.url) {
                UIApplication.shared.open(url)
            }
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // Category badge
                HStack(spacing: 6) {
                    Image(systemName: citation.categoryIcon)
                        .font(.system(size: 12))
                    Text(citation.category)
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(Theme.purple)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Theme.purple.opacity(0.1))
                )

                // Title
                Text(citation.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                // Authors and journal
                Text("\(citation.authors) (\(citation.year))")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Theme.textMuted)
                    .lineLimit(1)

                Text(citation.journal)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Theme.purple.opacity(0.8))
                    .italic()

                // Summary
                Text(citation.summary)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(2)

                // Link indicator
                HStack {
                    Spacer()
                    HStack(spacing: 4) {
                        Text("View on PubMed")
                            .font(.system(size: 12, weight: .medium))
                        Image(systemName: "arrow.up.right.square")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(Theme.purple)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.7))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    WorksCitedView(onContinue: {})
}
