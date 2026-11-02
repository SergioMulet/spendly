import Foundation

/// What the app remembers between syncs: when it last synced and where it stopped, per iCloud account,
/// and the expenses deleted locally that iCloud has not been told about yet.
nonisolated struct SyncMetadata: Sendable {
    // UserDefaults is safe to use from any thread, but the SDK does not mark it as Sendable.
    nonisolated(unsafe) private let defaults: UserDefaults
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    /// True once any sync has finished, so deletions are only remembered for users who use iCloud.
    var hasSynced: Bool {
        defaults.bool(forKey: "cloudHasSynced")
    }
    
    func lastSyncedAt(account: String) -> Date {
        defaults.object(forKey: "cloudLastSyncedAt.\(account)") as? Date ?? .distantPast
    }
    
    func setLastSyncedAt(_ date: Date, account: String) {
        defaults.set(date, forKey: "cloudLastSyncedAt.\(account)")
        defaults.set(true, forKey: "cloudHasSynced")
    }
    
    /// Opaque marker of the last change received from iCloud, so the next sync only asks for what is new.
    func changeToken(account: String) -> Data? {
        defaults.data(forKey: "cloudChangeToken.\(account)")
    }
    
    func setChangeToken(_ token: Data?, account: String) {
        defaults.set(token, forKey: "cloudChangeToken.\(account)")
    }
    
    var pendingDeletions: Set<UUID> {
        Set((defaults.stringArray(forKey: "cloudPendingDeletions") ?? []).compactMap(UUID.init))
    }
    
    func addPendingDeletions(_ ids: [UUID]) {
        save(pendingDeletions.union(ids))
    }
    
    func removePendingDeletions(_ ids: some Collection<UUID>) {
        save(pendingDeletions.subtracting(ids))
    }
    
    private func save(_ ids: Set<UUID>) {
        defaults.set(ids.map(\.uuidString), forKey: "cloudPendingDeletions")
    }
}
