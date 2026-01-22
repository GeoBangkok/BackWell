//
//  WorksCitedView.swift
//  BackWell
//
//  Created by standard on 1/22/26.
//

import SwiftUI

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
            category: "Exercise Therapy",
            categoryIcon: "figure.strengthtraining.traditional",
            title: "Exercise therapy for chronic low back pain",
            authors: "Hayden JA, Ellis J, Ogilvie R, et al.",
            journal: "Cochrane Database of Systematic Reviews",
            year: "2021",
            summary: "A comprehensive review of 249 trials found moderate-certainty evidence that exercise treatment is more effective for chronic low back pain compared to no treatment, usual care, or placebo. The review demonstrated clinically important differences in pain reduction.",
            url: "https://pubmed.ncbi.nlm.nih.gov/34580864/"
        ),
        Citation(
            category: "Mindfulness & Mental Wellness",
            categoryIcon: "brain.head.profile",
            title: "Effect of Mindfulness-Based Stress Reduction vs Cognitive Behavioral Therapy or Usual Care on Back Pain",
            authors: "Cherkin DC, Sherman KJ, Balderson BH, et al.",
            journal: "JAMA",
            year: "2016",
            summary: "A randomized clinical trial of 342 adults found that mindfulness-based stress reduction resulted in greater improvement in back pain and functional limitations. At 26 weeks, 60.5% of MBSR participants showed clinically meaningful improvement compared to 44.1% with usual care.",
            url: "https://pubmed.ncbi.nlm.nih.gov/27002445/"
        ),
        Citation(
            category: "Breathing Exercises",
            categoryIcon: "wind",
            title: "Effect of Adding Diaphragmatic Breathing Exercises to Core Stabilization Exercises on Pain and Disability",
            authors: "Mohamed RA, Yousef AM, Mohamed MM, et al.",
            journal: "Journal of Manipulative and Physiological Therapeutics",
            year: "2024",
            summary: "A randomized controlled trial found that adding diaphragmatic breathing exercises to core stabilization exercises significantly improved pain, muscle activity, disability, and sleep quality in patients with chronic low back pain after 12 sessions over 4 weeks.",
            url: "https://pubmed.ncbi.nlm.nih.gov/38205226/"
        ),
        Citation(
            category: "Breathing Exercises",
            categoryIcon: "wind",
            title: "Effects of breathing exercises on chronic low back pain: A systematic review and meta-analysis",
            authors: "Song Y, Li L, Li Z, et al.",
            journal: "Complementary Therapies in Clinical Practice",
            year: "2023",
            summary: "A meta-analysis of 13 studies (677 participants) found that breathing exercises have a positive effect on alleviating chronic low back pain. Results showed significantly higher effective rates and lower pain and disability scores compared to control groups.",
            url: "https://pubmed.ncbi.nlm.nih.gov/37718775/"
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
                                    .fill(Theme.teal.opacity(0.15))
                                    .frame(width: 70, height: 70)

                                Image(systemName: "book.closed.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(Theme.teal)
                            }
                            .padding(.top, 16)

                            // Title
                            Text("Scientific Research")
                                .font(.system(size: 26, weight: .semibold))
                                .foregroundColor(Theme.textPrimary)
                                .multilineTextAlignment(.center)

                            // Subtitle
                            Text("BackWell's approach is backed by peer-reviewed clinical research.")
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
                                        .fill(Theme.teal)
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
                .foregroundColor(Theme.teal)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Theme.teal.opacity(0.1))
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
                    .foregroundColor(Theme.teal.opacity(0.8))
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
                    .foregroundColor(Theme.teal)
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
