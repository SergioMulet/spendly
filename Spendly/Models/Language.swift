import Foundation

enum Language: String, CaseIterable {
    case english = "en"
    case spanish = "es"
    
    /// Name shown in its own language, so it is recognizable whatever the app language is.
    var displayName: String {
        switch self {
        case .english: "English"
        case .spanish: "Español"
        }
    }
    
    var locale: Locale {
        Locale(identifier: rawValue)
    }
    
    /// The device language when supported, English otherwise.
    static var deviceDefault: Language {
        Locale.current.language.languageCode.flatMap { Language(rawValue: $0.identifier) } ?? .english
    }
}
