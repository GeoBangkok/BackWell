//
//  ProductsView.swift
//  SkinGlowing
//
//  Products screen with fit percentages

import SwiftUI

struct ProductCard {
    let id: String
    let name: String
    let brand: String
    let category: String
    let fit: Int
    let image: String
    let verified: Bool
}

struct ProductsView: View {
    @State private var selectedCategory = "All"
    @State private var favorites: Set<String> = []
    @State private var searchText = ""

    let PINK = Color(hex: "E8578A")
    let INDIGO = Color(hex: "5B5FC7")
    let BG = Color(hex: "F8F7FB")
    let TEXT_PRIMARY = Color(hex: "1A1A2E")
    let TEXT_SECONDARY = Color(hex: "8E8E9A")
    let TEXT_MUTED = Color(hex: "B8B8C4")
    let GREEN = Color(hex: "34C759")

    let categories = ["All", "Cleanser", "Moisturizer", "Serum", "Sunscreen", "Treatment"]

    let sampleProducts = [
        ProductCard(id: "1", name: "Madecassoside Blemish Pad", brand: "MEDIHEAL", category: "Treatment", fit: 80, image: "product1", verified: true),
        ProductCard(id: "2", name: "Aqua Bomb Cream", brand: "belif", category: "Moisturizer", fit: 99, image: "product2", verified: true),
        ProductCard(id: "3", name: "Green Tea Seed Serum", brand: "innisfree", category: "Serum", fit: 92, image: "product3", verified: false),
        ProductCard(id: "4", name: "Snail Mucin Essence", brand: "COSRX", category: "Essence", fit: 88, image: "product4", verified: true),
        ProductCard(id: "5", name: "Rice Water Cleanser", brand: "THE FACE SHOP", category: "Cleanser", fit: 95, image: "product5", verified: false),
        ProductCard(id: "6", name: "Centella Sunscreen SPF50+", brand: "SKIN1004", category: "Sunscreen", fit: 97, image: "product6", verified: true),
    ]

    var filteredProducts: [ProductCard] {
        let categoryFiltered = selectedCategory == "All" ? sampleProducts : sampleProducts.filter { $0.category == selectedCategory }

        if searchText.isEmpty {
            return categoryFiltered
        } else {
            return categoryFiltered.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.brand.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(hex: "E8D5F0").opacity(0.3),
                        Color(hex: "D5D0F0").opacity(0.2),
                        BG
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Products")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(TEXT_PRIMARY)

                            Text("Recommended for your skin")
                                .font(.system(size: 14))
                                .foregroundColor(TEXT_SECONDARY)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)

                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(TEXT_MUTED)

                            TextField("Search products...", text: $searchText)
                                .font(.system(size: 14))
                                .foregroundColor(TEXT_PRIMARY)
                        }
                        .padding(14)
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.black.opacity(0.04), lineWidth: 1)
                        )
                        .padding(.horizontal)

                        // Category Pills
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(categories, id: \.self) { category in
                                    Button(action: {
                                        hapticFeedback(.light)
                                        selectedCategory = category
                                    }) {
                                        Text(category)
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(selectedCategory == category ? .white : TEXT_SECONDARY)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(
                                                selectedCategory == category ? INDIGO : Color.white.opacity(0.6)
                                            )
                                            .cornerRadius(20)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }

                        // Products Grid
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ],
                            spacing: 12
                        ) {
                            ForEach(filteredProducts, id: \.id) { product in
                                ProductCardView(
                                    product: product,
                                    isFavorite: favorites.contains(product.id),
                                    onToggleFavorite: {
                                        hapticFeedback(.light)
                                        if favorites.contains(product.id) {
                                            favorites.remove(product.id)
                                        } else {
                                            favorites.insert(product.id)
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct ProductCardView: View {
    let product: ProductCard
    let isFavorite: Bool
    let onToggleFavorite: () -> Void

    let PINK = Color(hex: "E8578A")
    let INDIGO = Color(hex: "5B5FC7")
    let TEXT_PRIMARY = Color(hex: "1A1A2E")
    let TEXT_MUTED = Color(hex: "B8B8C4")
    let GREEN = Color(hex: "34C759")

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Product Image with badges
            ZStack(alignment: .topLeading) {
                // Placeholder image
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "FFE4E1").opacity(0.3),
                                Color(hex: "FFB6C1").opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 140)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 30))
                            .foregroundColor(PINK.opacity(0.3))
                    )

                // Verified Badge
                if product.verified {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.white)

                        Text("Verified")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(INDIGO)
                    .cornerRadius(10)
                    .padding(8)
                }

                // Heart button
                Button(action: onToggleFavorite) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 18))
                        .foregroundColor(isFavorite ? PINK : TEXT_MUTED)
                        .frame(width: 32, height: 32)
                        .background(Color.white.opacity(0.9))
                        .clipShape(Circle())
                }
                .padding(8)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }

            // Product Info
            VStack(alignment: .leading, spacing: 6) {
                // Brand
                Text(product.brand)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(INDIGO)
                    .textCase(.uppercase)

                // Product Name
                Text(product.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(TEXT_PRIMARY)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                // Fit Badge
                HStack {
                    Text("\(product.fit)% fit")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(product.fit >= 90 ? GREEN : INDIGO)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            product.fit >= 90 ?
                            Color(hex: "34C759").opacity(0.12) :
                            Color(hex: "5B5FC7").opacity(0.12)
                        )
                        .cornerRadius(10)
                }
            }
            .padding(12)
        }
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    ProductsView()
}