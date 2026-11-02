import Foundation

/// Everything that came from iCloud since the last sync.
nonisolated struct CloudChanges: Sendable {
    var expenses: [Expense] = []
    var deletedIDs: [UUID] = []
    /// Opaque marker to pass to the next `fetchChanges` call.
    var token: Data?
}

enum CloudSyncError: Error {
    /// The user is not signed in to iCloud, or iCloud is restricted on this device.
    case accountUnavailable
}

/// The iCloud side of the sync. `iCloudExpenseRepository` and `ExpenseSynchronizer` only know this protocol.
nonisolated protocol CloudExpenseStore: Sendable {
    /// Checks that iCloud can be used and returns an identifier of the signed-in account.
    func prepare() async throws -> String
    func fetchChanges(since token: Data?) async throws -> CloudChanges
    func save(_ expenses: [Expense]) async throws
    func delete(ids: [UUID]) async throws
}
