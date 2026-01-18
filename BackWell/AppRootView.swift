//
//  AppRootView.swift
//  BackWell
//
//  Created by standard on 1/17/26.
//

import SwiftUI

enum AppScreen {
    case login
    case onboarding
    case paywall
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
                OnboardingView(onContinue: {
                    currentScreen = .paywall
                })
            case .paywall:
                PaywallView(onContinue: {
                    currentScreen = .main
                })
            case .main:
                MainAppView()
            }
        }
        .animation(.easeInOut, value: currentScreen)
    }
}

#Preview {
    AppRootView()
}
