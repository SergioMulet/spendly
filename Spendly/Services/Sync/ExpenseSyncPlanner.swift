import Foundation

/// What a sync has to do to make this device and iCloud agree.
nonisolated struct SyncPlan: Equatable {
    var saveLocally: [Expense] = []
    var deleteLocally: [UUID] = []
    var saveToCloud: [Expense] = []
    var deleteFromCloud: [UUID] = []
}

/// The merge rules of the sync. It only decides; it never touches storage, so it is easy to test.
nonisolated enum ExpenseSyncPlanner {
    /// - Parameters:
    ///   - local: every expense on this device.
    ///   - remoteChanged: expenses created or changed in iCloud since the last sync.
    ///   - remoteDeleted: expenses deleted in iCloud since the last sync.
    ///   - lastSyncedAt: when this device last synced; anything changed after it still has to be uploaded.
    ///   - pendingDeletions: expenses deleted on this device that iCloud still has.
    static func plan(
        local: [Expense],
        remoteChanged: [Expense],
        remoteDeleted: [UUID],
        lastSyncedAt: Date,
        pendingDeletions: Set<UUID>
    ) -> SyncPlan {
        var plan = SyncPlan()
        let localByID = Dictionary(local.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        var handled = Set<UUID>()
        
        // Changed in iCloud: the most recent version wins.
        for remote in remoteChanged where !pendingDeletions.contains(remote.id) {
            handled.insert(remote.id)
            guard let mine = localByID[remote.id] else {
                plan.saveLocally.append(remote)
                continue
            }
            if remote.updatedAt > mine.updatedAt {
                plan.saveLocally.append(remote)
            } else if mine.updatedAt > remote.updatedAt {
                plan.saveToCloud.append(mine)
            }
        }
        
        // Deleted in iCloud: delete it here too, unless it was edited here after the last sync.
        for id in remoteDeleted where !pendingDeletions.contains(id) {
            handled.insert(id)
            guard let mine = localByID[id] else { continue }
            if mine.updatedAt > lastSyncedAt {
                plan.saveToCloud.append(mine)
            } else {
                plan.deleteLocally.append(id)
            }
        }
        
        // Created or edited here since the last sync.
        for mine in local where !handled.contains(mine.id) && mine.updatedAt > lastSyncedAt {
            plan.saveToCloud.append(mine)
        }
        
        plan.deleteFromCloud = Array(pendingDeletions)
        return plan
    }
}
