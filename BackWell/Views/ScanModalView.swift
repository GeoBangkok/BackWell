//
//  ScanModalView.swift
//  SkinGlowing
//
//  Scan options modal

import SwiftUI

struct ScanModalView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedOption: ScanOption?
    @State private var showingScanView = false

    let PINK = Color(hex: "E8578A")
    let TEXT_PRIMARY = Color(hex: "1A1A2E")
    let TEXT_SECONDARY = Color(hex: "8E8E9A")

    enum ScanOption {
        case face
        case product
        case chat
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(PINK)

                    Spacer()

                    Text("New Scan")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(TEXT_PRIMARY)

                    Spacer()

                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.clear)
                    .disabled(true)
                }
                .padding()

                // Scan Options
                VStack(spacing: 20) {
                    Text("What would you like to scan?")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(TEXT_PRIMARY)
                        .padding(.top, 20)

                    VStack(spacing: 16) {
                        // Face Scan Option
                        ScanOptionCard(
                            icon: "face.smiling",
                            title: "Face Scan",
                            description: "Analyze your skin condition with AI",
                            color: PINK,
                            action: {
                                hapticFeedback(.medium)
                                selectedOption = .face
                                showingScanView = true
                            }
                        )

                        // Product Scan Option
                        ScanOptionCard(
                            icon: "barcode.viewfinder",
                            title: "Product Scan",
                            description: "Check if products match your skin",
                            color: Color(hex: "8B7DFF"),
                            action: {
                                hapticFeedback(.medium)
                                selectedOption = .product
                                showingScanView = true
                            }
                        )

                        // Talk with AI Option
                        ScanOptionCard(
                            icon: "message.fill",
                            title: "Talk with SkinGlowing",
                            description: "Get personalized skincare advice",
                            color: Color(hex: "4A90E2"),
                            action: {
                                hapticFeedback(.medium)
                                selectedOption = .chat
                                // Navigate to AI chat
                                dismiss()
                            }
                        )
                    }
                    .padding(.horizontal, 20)

                    Spacer()
                }
                .padding(.top, 20)
            }
            .background(Color(hex: "F8F7FB"))
        }
        .sheet(isPresented: $showingScanView) {
            if selectedOption == .face {
                // Use existing SkinScanView for face scanning
                SkinScanView()
            } else if selectedOption == .product {
                // Product scan view
                ProductScanView()
            }
        }
    }
}

struct ScanOptionCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 56, height: 56)

                    Image(systemName: icon)
                        .font(.system(size: 26))
                        .foregroundColor(color)
                }

                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "1A1A2E"))

                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "8E8E9A"))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "C7C7CC"))
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Placeholder for Product Scan View
struct ProductScanView: View {
    @Environment(\.dismiss) var dismiss
    @State private var isScanning = false
    @State private var scannedProduct: String?

    let PINK = Color(hex: "E8578A")

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(PINK)

                    Spacer()

                    Text("Product Scan")
                        .font(.system(size: 18, weight: .semibold))

                    Spacer()

                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.clear)
                    .disabled(true)
                }
                .padding()

                // Scan area
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
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
                        .frame(height: 300)

                    VStack(spacing: 20) {
                        Image(systemName: "barcode.viewfinder")
                            .font(.system(size: 60))
                            .foregroundColor(PINK.opacity(0.6))

                        Text("Point camera at product")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "8E8E9A"))
                    }
                }
                .padding(.horizontal)

                // Instructions
                VStack(spacing: 12) {
                    Text("Scan product barcode or ingredients")
                        .font(.system(size: 18, weight: .semibold))

                    Text("We'll analyze if it's suitable for your skin type")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "8E8E9A"))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 40)

                Spacer()

                // Scan button
                Button(action: {
                    hapticFeedback(.medium)
                    isScanning = true
                    // Simulate scanning
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isScanning = false
                        scannedProduct = "Sample Product"
                        // Show results
                    }
                }) {
                    HStack {
                        if isScanning {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 18))
                        }

                        Text(isScanning ? "Scanning..." : "Start Scan")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [PINK, Color(hex: "FFB6C1")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(28)
                }
                .disabled(isScanning)
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
            .background(Color(hex: "F8F7FB"))
        }
    }
}

#Preview {
    ScanModalView()
}