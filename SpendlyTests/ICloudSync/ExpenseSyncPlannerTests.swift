import Foundation
import Testing
@testable import Spendly

struct ExpenseSyncPlannerTests {
    private func expense(_ title: String, updated: Double, id: UUID = UUID()) -> Expense {
        Expense(id: id, title: title, amount: 1, date: .now, category: .food, updatedAt: Date(timeIntervalSince1970: updated))
    }
    
    private func plan(local: [Expense] = [], changed: [Expense] = [], deleted: [UUID] = [], lastSynced: Double = 0, pending: Set<UUID> = []) -> SyncPlan {
        ExpenseSyncPlanner.plan(local: local, remoteChanged: changed, remoteDeleted: deleted, lastSyncedAt: Date(timeIntervalSince1970: lastSynced), pendingDeletions: pending)
    }
    
    @Test func anExpenseOnlyInICloudIsSavedLocally() {
        let remote = expense("Remote", updated: 100)
        #expect(plan(changed: [remote]) == SyncPlan(saveLocally: [remote]))
    }
    
    @Test func theNewerRemoteVersionReplacesTheLocalOne() {
        let id = UUID()
        let remote = expense("New", updated: 200, id: id)
        let mine = expense("Old", updated: 100, id: id)
        #expect(plan(local: [mine], changed: [remote], lastSynced: 1000) == SyncPlan(saveLocally: [remote]))
    }
    
    @Test func theNewerLocalVersionIsUploaded() {
        let id = UUID()
        let remote = expense("Old", updated: 100, id: id)
        let mine = expense("New", updated: 200, id: id)
        #expect(plan(local: [mine], changed: [remote], lastSynced: 1000) == SyncPlan(saveToCloud: [mine]))
    }
    
    @Test func sameVersionOnBothSidesNeedsNothing() {
        let id = UUID()
        let both = expense("Same", updated: 100, id: id)
        #expect(plan(local: [both], changed: [both], lastSynced: 1000) == SyncPlan())
    }
    
    @Test func localChangesSinceTheLastSyncAreUploaded() {
        let mine = expense("Mine", updated: 2000)
        #expect(plan(local: [mine], lastSynced: 1000) == SyncPlan(saveToCloud: [mine]))
    }
    
    @Test func localExpensesNotChangedSinceTheLastSyncAreLeftAlone() {
        let mine = expense("Mine", updated: 500)
        #expect(plan(local: [mine], lastSynced: 1000) == SyncPlan())
    }
    
    @Test func anExpenseDeletedInICloudIsDeletedLocally() {
        let mine = expense("Mine", updated: 500)
        #expect(plan(local: [mine], deleted: [mine.id], lastSynced: 1000) == SyncPlan(deleteLocally: [mine.id]))
    }
    
    @Test func aLocalEditMadeAfterTheLastSyncBeatsADeletionInICloud() {
        let mine = expense("Mine", updated: 2000)
        #expect(plan(local: [mine], deleted: [mine.id], lastSynced: 1000) == SyncPlan(saveToCloud: [mine]))
    }
    
    @Test func aDeletionOfSomethingWeNeverHadIsIgnored() {
        #expect(plan(deleted: [UUID()], lastSynced: 1000) == SyncPlan())
    }
    
    @Test func anExpenseDeletedHereIsDeletedFromICloudAndNotRestored() {
        let id = UUID()
        let remote = expense("Deleted here", updated: 100, id: id)
        #expect(plan(changed: [remote], pending: [id]) == SyncPlan(deleteFromCloud: [id]))
    }
}
