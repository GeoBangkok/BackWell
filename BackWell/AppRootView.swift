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
    case worksCited
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
                    currentScreen = .disclaimer
                })
            case .disclaimer:
                MedicalDisclaimerView(onAccept: {
                    currentScreen = .worksCited
                })
            case .worksCited:
                WorksCitedView(onContinue: {
                    currentScreen = .onboarding
                })
            case .onboarding:
                OnboardingView(onContinue: {
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
