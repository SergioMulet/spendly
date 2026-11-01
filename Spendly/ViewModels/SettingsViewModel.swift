import Foundation
import Observation

@Observable
final class SettingsViewModel {
    var currencyCode: String {
        didSet { UserDefaults.standard.set(currencyCode, forKey: "currencyCode") }
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
        iCloudSync = defaults.object(forKey: "iCloudSync") as? Bool ?? true
        faceIDLock = defaults.bool(forKey: "faceIDLock")
    }
}
