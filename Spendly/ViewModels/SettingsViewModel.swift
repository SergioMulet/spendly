import Foundation
import Observation

@Observable
final class SettingsViewModel {
    var currencyCode: String {
        didSet { defaults.set(currencyCode, forKey: "currencyCode") }
    }
    
    var language: Language {
        didSet { defaults.set(language.rawValue, forKey: "language") }
    }
    
    var iCloudSync: Bool {
        didSet { defaults.set(iCloudSync, forKey: CloudSyncSettings.key) }
    }
    
    private(set) var isSyncing = false
    var showingError = false
    private(set) var errorMessage: LocalizedStringResource = "Check your connection and try again."
    
    var faceIDLock: Bool {
        didSet { defaults.set(faceIDLock, forKey: "faceIDLock") }
    }
    
    private let defaults: UserDefaults
    private let synchronizer: ExpenseSyncing
    
    init(defaults: UserDefaults = .standard, synchronizer: ExpenseSyncing? = nil) {
        self.defaults = defaults
        self.synchronizer = synchronizer ?? ExpenseSynchronizer.standard()
        currencyCode = defaults.string(forKey: "currencyCode") ?? "EUR"
        language = defaults.string(forKey: "language").flatMap(Language.init) ?? .deviceDefault
        iCloudSync = defaults.bool(forKey: CloudSyncSettings.key)
        faceIDLock = defaults.bool(forKey: "faceIDLock")
    }
    
    /// Turning iCloud sync on downloads what is in iCloud and uploads the local changes. That also checks that the
    /// user is signed in to iCloud (there is no permission prompt); if anything fails, the switch goes back off.
    func iCloudSyncChanged() async {
        // Always off until Apple Developer program
        iCloudSync = false
        
        /*
        guard iCloudSync else { return }
        isSyncing = true
        defer { isSyncing = false }
        do {
            try await synchronizer.sync()
        } catch {
            iCloudSync = false
            errorMessage = error is CloudSyncError
                ? "Sign in to iCloud in the Settings app to sync your expenses."
                : "Check your connection and try again."
            showingError = true
        }
        */
    }
}
