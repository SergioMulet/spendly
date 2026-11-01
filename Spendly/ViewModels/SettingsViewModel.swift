import Foundation
import Observation

@Observable
final class SettingsViewModel {
    var currencyCode: String {
        didSet { UserDefaults.standard.set(currencyCode, forKey: "currencyCode") }
    }
    
    var iCloudSync: Bool {
        didSet { UserDefaults.standard.set(currencyCode, forKey: "currencyCode") }
    }
    
    var faceIDLock: Bool {
        didSet { UserDefaults.standard.set(currencyCode, forKey: "currencyCode") }
    }
    
    init() {
        let defaults = UserDefaults.standard
        currencyCode = defaults.string(forKey: "currencyCode") ?? "EUR"
        iCloudSync = defaults.object(forKey: "iCloudSync") as? Bool ?? true
        faceIDLock = defaults.bool(forKey: "faceIDLock")
    }
}
