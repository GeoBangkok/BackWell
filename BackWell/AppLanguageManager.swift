//
//  AppLanguageManager.swift
//  SkinGlowing
//

import SwiftUI
import Combine

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case spanishMexico = "es-MX"
    case thai = "th"
    case french = "fr"
    case chineseSimplified = "zh-Hans"
    case german = "de"
    case portugueseBrazil = "pt-BR"

    var id: String { rawValue }

    var localeIdentifier: String { rawValue }

    var flag: String {
        switch self {
        case .english: return "🇺🇸"
        case .spanishMexico: return "🇲🇽"
        case .thai: return "🇹🇭"
        case .french: return "🇫🇷"
        case .chineseSimplified: return "🇨🇳"
        case .german: return "🇩🇪"
        case .portugueseBrazil: return "🇧🇷"
        }
    }

    var displayName: LocalizedStringKey {
        switch self {
        case .english: return "English"
        case .spanishMexico: return "Spanish"
        case .thai: return "Thai"
        case .french: return "French"
        case .chineseSimplified: return "Chinese"
        case .german: return "German"
        case .portugueseBrazil: return "Portuguese"
        }
    }

    var aiLanguageName: String {
        switch self {
        case .english: return "English"
        case .spanishMexico: return "Mexican Spanish"
        case .thai: return "Thai"
        case .french: return "French"
        case .chineseSimplified: return "Simplified Chinese"
        case .german: return "German"
        case .portugueseBrazil: return "Brazilian Portuguese"
        }
    }

    var jsonResponseInstruction: String {
        """
        App language: \(aiLanguageName).
        Keep JSON keys and required enum/category values exactly as requested in English.
        Translate every user-facing explanation, recommendation, advice, routine description, and plan label into \(aiLanguageName).
        """
    }

    var chatResponseInstruction: String {
        "Always reply in \(aiLanguageName), matching the user's selected app language unless the user explicitly asks for another language."
    }

    static func bestMatch(for preferredLanguages: [String]) -> AppLanguage {
        for preferredLanguage in preferredLanguages {
            let normalized = preferredLanguage.lowercased()
            if normalized.hasPrefix("es") { return .spanishMexico }
            if normalized.hasPrefix("th") { return .thai }
            if normalized.hasPrefix("fr") { return .french }
            if normalized.hasPrefix("zh") { return .chineseSimplified }
            if normalized.hasPrefix("de") { return .german }
            if normalized.hasPrefix("pt") { return .portugueseBrazil }
            if normalized.hasPrefix("en") { return .english }
        }
        return .english
    }
}

final class AppLanguageManager: ObservableObject {
    static let shared = AppLanguageManager()
    private let storageKey = "sg_selected_language"

    @Published var selectedLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(selectedLanguage.rawValue, forKey: storageKey)
        }
    }

    private init() {
        let savedLanguageCode = UserDefaults.standard.string(forKey: storageKey) ?? ""
        if let savedLanguage = AppLanguage(rawValue: savedLanguageCode) {
            selectedLanguage = savedLanguage
        } else {
            selectedLanguage = AppLanguage.bestMatch(for: Locale.preferredLanguages)
            UserDefaults.standard.set(selectedLanguage.rawValue, forKey: storageKey)
        }
    }

    func select(_ language: AppLanguage) {
        selectedLanguage = language
    }

    func localized(_ key: String) -> String {
        selectedLanguage.localized(key)
    }
}

extension AppLanguage {
    func localized(_ key: String) -> String {
        let bundle = Bundle.main.path(forResource: localeIdentifier, ofType: "lproj")
            .flatMap { Bundle(path: $0) }
        return bundle?.localizedString(forKey: key, value: key, table: nil) ?? key
    }
}
