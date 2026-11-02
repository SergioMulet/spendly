import Foundation

/// The "iCloud sync" switch of the Settings screen.
nonisolated struct CloudSyncSettings: Sendable {
    static let key = "iCloudSync"
    
    /// iCloud sync is paused: it needs the iCloud capability, which needs the paid Apple Developer Program.
    /// While this is false the app never talks to iCloud, whatever the stored setting says.
    /// TODO: set it to true (or remove it) once the capability is added.
    static let iCloudCapabilityAvailable = false
    
    nonisolated(unsafe) var defaults = UserDefaults.standard
    var isAvailable = Self.iCloudCapabilityAvailable
    
    var isEnabled: Bool {
        isAvailable && defaults.bool(forKey: Self.key)
    }
}
