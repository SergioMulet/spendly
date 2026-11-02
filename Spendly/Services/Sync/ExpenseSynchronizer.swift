import Foundation

nonisolated protocol ExpenseSyncing: Sendable {
    func sync() async throws
}

/// Makes this device and iCloud agree: downloads what is new in iCloud, then uploads the local changes.
nonisolated struct ExpenseSynchronizer: ExpenseSyncing {
    /// The device's own storage, not the iCloud decorator, so applying iCloud changes does not upload them again.
    private let local: ExpenseRepository
    private let cloud: CloudExpenseStore
    private let metadata: SyncMetadata
    
    init(local: ExpenseRepository, cloud: CloudExpenseStore, metadata: SyncMetadata = SyncMetadata()) {
        self.local = local
        self.cloud = cloud
        self.metadata = metadata
    }
    
    func sync() async throws {
        let startedAt = Date()
        let account = try await cloud.prepare()
        let changes = try await cloud.fetchChanges(since: metadata.changeToken(account: account))
        let expenses = try await local.fetchExpenses(in: DateInterval(start: .distantPast, end: .distantFuture))
        let pendingDeletions = metadata.pendingDeletions
        
        let plan = ExpenseSyncPlanner.plan(
            local: expenses,
            remoteChanged: changes.expenses,
            remoteDeleted: changes.deletedIDs,
            lastSyncedAt: metadata.lastSyncedAt(account: account),
            pendingDeletions: pendingDeletions
        )
        
        for expense in plan.saveLocally {
            try await local.save(expense)
        }
        try await local.delete(ids: plan.deleteLocally)
        try await cloud.save(plan.saveToCloud)
        try await cloud.delete(ids: plan.deleteFromCloud)
        
        // Only after everything worked, so a failed sync is retried from the same point.
        metadata.removePendingDeletions(pendingDeletions)
        metadata.setChangeToken(changes.token, account: account)
        metadata.setLastSyncedAt(startedAt, account: account)
    }
}

extension ExpenseSynchronizer {
    /// The synchronizer the app uses: this device's SwiftData storage and the user's private iCloud database.
    @MainActor static func standard() -> ExpenseSynchronizer {
        ExpenseSynchronizer(local: SwiftDataExpenseRepository.shared, cloud: CloudKitExpenseStore.shared)
    }
}
