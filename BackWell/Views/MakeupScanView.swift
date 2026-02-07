//
//  MakeupScanView.swift
//  SkinGlowing
//
//  Makeup analysis and virtual try-on

import SwiftUI

struct MakeupScanView: View {
    @State private var selectedCategory = 0
    @State private var showCamera = false

    let categories = ["Foundation", "Blush", "Lipstick", "Eyeshadow", "Contour"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 25) {
                // Header
                VStack(spacing: 8) {
                    Text("Makeup Studio")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "FF91A4"), Color(hex: "DA70D6")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Text("Find your perfect shades with AI")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                }
                .padding(.top, 60)

                // Try-On Card
                Button(action: { showCamera = true }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 25)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "FFB6C1"),
                                        Color(hex: "DA70D6")
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color(hex: "DA70D6").opacity(0.3), radius: 20, x: 0, y: 10)

                        VStack(spacing: 16) {
                            Image(systemName: "camera.filters")
                                .font(.system(size: 50))
                                .foregroundColor(.white)

                            Text("Virtual Try-On")
                                .font(.system(size: 24, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)

                            Text("Try makeup looks instantly")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.vertical, 35)
                    }
                    .frame(height: 200)
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal, 20)

                // Category Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(categories.enumerated()), id: \.offset) { index, category in
                            CategoryPill(
                                title: category,
                                isSelected: selectedCategory == index,
                                action: { selectedCategory = index }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }

                // Shade Recommendations
                VStack(alignment: .leading, spacing: 16) {
                    Text("Recommended Shades")
                        .font(.system(size: 20, weight: .semibold))
                        .padding(.horizontal, 20)

                    VStack(spacing: 12) {
                        ShadeCard(
                            productName: "Perfect Match Foundation",
                            shade: "Natural Beige 02",
                            match: 98,
                            price: "$42",
                            color: Color(hex: "F5DEB3")
                        )

                        ShadeCard(
                            productName: "Glow Enhancer",
                            shade: "Warm Ivory 01",
                            match: 95,
                            price: "$38",
                            color: Color(hex: "FFE4C4")
                        )

                        ShadeCard(
                            productName: "Dewy Foundation",
                            shade: "Light Sand 03",
                            match: 92,
                            price: "$35",
                            color: Color(hex: "F4A460")
                        )
                    }
                    .padding(.horizontal, 20)
                }

                // Color Analysis
                VStack(spacing: 16) {
                    Text("Your Color Profile")
                        .font(.system(size: 20, weight: .semibold))

                    HStack(spacing: 12) {
                        ColorProfileCard(
                            title: "Undertone",
                            value: "Warm",
                            icon: "sun.max.fill",
                            color: Color.orange
                        )

                        ColorProfileCard(
                            title: "Season",
                            value: "Spring",
                            icon: "leaf.fill",
                            color: Color.green
                        )

                        ColorProfileCard(
                            title: "Contrast",
                            value: "Medium",
                            icon: "circle.lefthalf.filled",
                            color: Color.gray
                        )
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 100)
            }
        }
        .ignoresSafeArea(edges: .top)
        .sheet(isPresented: $showCamera) {
            BeautifulSkinScanView()
        }
    }
}

// MARK: - Category Pill
struct CategoryPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .gray)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color(hex: "DA70D6") : Color.gray.opacity(0.1))
                )
        }
    }
}

// MARK: - Shade Card
struct ShadeCard: View {
    let productName: String
    let shade: String
    let match: Int
    let price: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            // Color Preview
            RoundedRectangle(cornerRadius: 12)
                .fill(color)
                .frame(width: 60, height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )

            // Product Info
            VStack(alignment: .leading, spacing: 6) {
                Text(productName)
                    .font(.system(size: 16, weight: .semibold))

                Text(shade)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)

                HStack(spacing: 12) {
                    // Match Percentage
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.green)

                        Text("\(match)% match")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.green)
                    }

                    // Price
                    Text(price)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "DA70D6"))
                }
            }

            Spacer()

            // Try Button
            Button(action: {}) {
                Text("Try")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(hex: "DA70D6"))
                    )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
}

// MARK: - Color Profile Card
struct ColorProfileCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)

            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.gray)

            Text(value)
                .font(.system(size: 16, weight: .semibold))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.1))
        )
    }
}

#Preview {
    MakeupScanView()
}