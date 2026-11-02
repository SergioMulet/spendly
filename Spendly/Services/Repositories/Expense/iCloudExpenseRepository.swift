import Foundation

/// Decorates another repository, adding iCloud sync on top of it.
/// The wrapped repository stays the source of truth: every operation is done there first, and mirrored to iCloud
/// only while the "iCloud sync" setting is on. If iCloud fails, the operation still succeeds locally and the next
/// sync (`ExpenseSynchronizer`) uploads what was missed.
struct iCloudExpenseRepository: ExpenseRepository {
    static let shared = iCloudExpenseRepository(local: SwiftDataExpenseRepository.shared)
    
    private let repo: ExpenseRepository
    private let cloud: CloudExpenseStore
    private let settings: CloudSyncSettings
    private let metadata: SyncMetadata
    
    init(
        local: ExpenseRepository,
        cloud: CloudExpenseStore = CloudKitExpenseStore.shared,
        settings: CloudSyncSettings = CloudSyncSettings(),
        metadata: SyncMetadata = SyncMetadata()
    ) {
        self.repo = local
        self.cloud = cloud
        self.settings = settings
        self.metadata = metadata
    }
    
    func fetchExpenses(in interval: DateInterval) async throws -> [Expense] {
        try await repo.fetchExpenses(in: interval)
    }
    
    func save(_ expense: Expense) async throws {
        try await repo.save(expense)
        guard settings.isEnabled else { return }
        // If this fails, the expense is newer than the last sync, so the next sync uploads it.
        try? await cloud.save([expense])
    }
    
    func delete(ids: [UUID]) async throws {
        try await repo.delete(ids: ids)
        // Remembered until iCloud confirms, so a deletion made offline or with the setting off is not undone by the next sync.
        if settings.isEnabled || metadata.hasSynced {
            metadata.addPendingDeletions(ids)
        }
        guard settings.isEnabled else { return }
        if (try? await cloud.delete(ids: ids)) != nil {
            metadata.removePendingDeletions(ids)
        }
    }
}
