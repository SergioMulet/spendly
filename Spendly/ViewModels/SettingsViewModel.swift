import Foundation
import Observation

@Observable
final class SettingsViewModel {
    var currencyCode: String {
        didSet { UserDefaults.standard.set(currencyCode, forKey: "currencyCode") }
    }
    
    var language: Language {
        didSet { UserDefaults.standard.set(language.rawValue, forKey: "language") }
    }
    
    var iCloudSync: Bool {
        didSet { UserDefaults.standard.set(iCloudSync, forKey: "iCloudSync") }
    }
    
    var faceIDLock: Bool {
        didSet { UserDefaults.standard.set(faceIDLock, forKey: "faceIDLock") }
    }
    
    init() {
        let defaults = UserDefaults.standard
        currencyCode = defaults.string(forKey: "currencyCode") ?? "EUR"
        language = defaults.string(forKey: "language").flatMap(Language.init) ?? .deviceDefault
        iCloudSync = defaults.object(forKey: "iCloudSync") as? Bool ?? true
        faceIDLock = defaults.bool(forKey: "faceIDLock")
    }
}
