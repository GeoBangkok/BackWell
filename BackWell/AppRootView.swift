//
//  AppRootView.swift
//  BackWell
//
//  Created by standard on 1/17/26.
//

import SwiftUI
import SuperwallKit

enum AppScreen {
    case login
    case disclaimer
    case onboarding
    case main
}

struct AppRootView: View {
    @State private var currentScreen: AppScreen = .login
    @State private var paywallStartTime: Date?
    @State private var userMadePurchase: Bool = false

    var body: some View {
        Group {
            switch currentScreen {
            case .login:
                LoginView(onContinue: {
                    currentScreen = .disclaimer
                })
            case .disclaimer:
                MedicalDisclaimerView(onAccept: {
                    currentScreen = .onboarding
                })
            case .onboarding:
                OnboardingView(onContinue: {
                    // Checkpoint 2: Log when paywall event is fired
                    let eventName = "onboarding_complete"
                    print("SW_EVENT_FIRED – event: \(eventName)")

                    // Start tracking paywall view time
                    // PaywallViewed event fires in didPresentPaywall delegate (BackWellApp.swift)
                    // This ensures we only track when paywall ACTUALLY shows
                    paywallStartTime = Date()

                    // Register Superwall placement - this triggers the paywall
                    Superwall.shared.register(placement: eventName) {
                        // This handler is called when paywall is dismissed (purchased, skipped, or closed)
                        // Check if user made a purchase
                        let hadPurchase = StoreManager.shared.isSubscribed

                        // Track paywall dismissal
                        let timeOnPaywall = paywallStartTime.map { Date().timeIntervalSince($0) }
                        FacebookEventTracker.shared.trackPaywallDismissed(
                            hadPurchase: hadPurchase,
                            timeOnPaywall: timeOnPaywall
                        )

                        // DON'T track StartTrial here - race condition risk
                        // StartTrial fires in MainAppView.onAppear when user first accesses app
                        // This avoids false positives from async StoreKit transaction processing

                        DispatchQueue.main.async {
                            currentScreen = .main
                        }
                    }
                })
            case .main:
                MainAppView()
            }
        }
        .animation(.easeInOut, value: currentScreen)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LogOut"))) { _ in
            withAnimation {
                currentScreen = .login
            }
        }
    }
}

#Preview {
    AppRootView()
}
