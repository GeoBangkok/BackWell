//
//  AppRootView.swift
//  SkinGlowing
//
//  Created by standard on 1/17/26.
//

import SwiftUI
import SuperwallKit
import AppTrackingTransparency
import Combine

enum AppScreen {
    case login
    case onboarding
    case main
}

struct AppRootView: View {
    @State private var currentScreen: AppScreen = .login

    var body: some View {
        Group {
            switch currentScreen {
            case .login:
                LoginView(onContinue: {
                    currentScreen = .onboarding
                })
            case .onboarding:
                OnboardingView(onComplete: {
                    // Trigger paywall notification
                    NotificationCenter.default.post(name: Notification.Name("TriggerPaywall"), object: nil)
                })
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("TriggerPaywall"))) { _ in
                    // Checkpoint 2: Log when paywall event is fired
                    let eventName = "onboarding_complete"
                    print("SW_EVENT_FIRED – event: \(eventName)")

                    // Register Superwall placement - this triggers the paywall
                    Superwall.shared.register(placement: eventName) {
                        // This handler is called when paywall is dismissed (purchased, skipped, or closed)
                        DispatchQueue.main.async {
                            currentScreen = .main
                            }
                        }
                    }
            case .main:
                MainTabView()
            }
        }
        .animation(.easeInOut, value: currentScreen)
        .onAppear {
            // Request ATT at launch
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                ATTrackingManager.requestTrackingAuthorization { _ in }
            }
        }
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
