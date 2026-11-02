import Foundation
import Testing
@testable import Spendly

/// Integration tests: real SwiftData storage on this side, an in-memory iCloud on the other.
struct ExpenseSynchronizerTests {
    private let store: TestStore
    private let cloud = FakeCloudStore()
    private let metadata = SyncMetadata(defaults: TestDefaults.make())
    private let synchronizer: ExpenseSynchronizer
    
    init() throws {
        store = try TestStore()
        synchronizer = ExpenseSynchronizer(local: store.expenses, cloud: cloud, metadata: metadata)
    }
    
    private func expense(_ title: String, updatedAt: Date = .now, id: UUID = UUID()) -> Expense {
        Expense(id: id, title: title, amount: 10, date: .now, category: .food, updatedAt: updatedAt)
    }
    
    @Test func theFirstSyncMergesBothSides() async throws {
        let fromAnotherDevice = expense("In iCloud")
        let local = expense("On this device")
        try await cloud.save([fromAnotherDevice])
        try await store.expenses.save(local)
        
        try await synchronizer.sync()
        
        #expect(Set(try await store.allExpenses().map(\.title)) == ["In iCloud", "On this device"])
        #expect(Set(await cloud.records.values.map(\.title)) == ["In iCloud", "On this device"])
    }
    
    @Test func theMostRecentVersionWinsInBothDirections() async throws {
        let id = UUID()
        let now = Date.now
        try await cloud.save([expense("Cloud is newer", updatedAt: now, id: id)])
        try await store.expenses.save(expense("Old local", updatedAt: now.addingTimeInterval(-60), id: id))
        let otherID = UUID()
        try await cloud.save([expense("Old cloud", updatedAt: now.addingTimeInterval(-60), id: otherID)])
        try await store.expenses.save(expense("Local is newer", updatedAt: now, id: otherID))
        
        try await synchronizer.sync()
        
        let local = try await store.allExpenses()
        #expect(local.first { $0.id == id }?.title == "Cloud is newer")
        #expect(await cloud.records[otherID]?.title == "Local is newer")
    }
    
    @Test func aDeletionMadeInICloudReachesThisDeviceOnTheNextSync() async throws {
        let shared = expense("Shared", updatedAt: .now.addingTimeInterval(-60))
        try await cloud.save([shared])
        try await synchronizer.sync()
        #expect(try await store.allExpenses().count == 1)
        
        try await cloud.delete(ids: [shared.id])
        try await synchronizer.sync()
        
        #expect(try await store.allExpenses().isEmpty)
    }
    
    @Test func anExpenseEditedHereAfterBeingDeletedInICloudComesBack() async throws {
        let shared = expense("Shared", updatedAt: .now.addingTimeInterval(-60))
        try await cloud.save([shared])
        try await synchronizer.sync()
        try await cloud.delete(ids: [shared.id])
        var edited = shared
        edited.title = "Edited here"
        edited.updatedAt = .now.addingTimeInterval(60)
        try await store.expenses.save(edited)
        
        try await synchronizer.sync()
        
        #expect(await cloud.records[shared.id]?.title == "Edited here")
        #expect(try await store.allExpenses().count == 1)
    }
    
    @Test func anExpenseDeletedHereIsDeletedFromICloudAndNotRestored() async throws {
        let doomed = expense("Doomed", updatedAt: .now.addingTimeInterval(-60))
        try await cloud.save([doomed])
        try await synchronizer.sync()
        
        try await store.expenses.delete(ids: [doomed.id])
        metadata.addPendingDeletions([doomed.id])
        try await synchronizer.sync()
        
        #expect(await cloud.records.isEmpty)
        #expect(try await store.allExpenses().isEmpty)
        #expect(metadata.pendingDeletions.isEmpty)
    }
    
    @Test func withoutAnICloudAccountNothingChangesAndItFailsClearly() async throws {
        await cloud.setAccountAvailable(false)
        try await store.expenses.save(expense("Local"))
        
        await #expect(throws: CloudSyncError.self) { try await synchronizer.sync() }
        
        #expect(await cloud.records.isEmpty)
        #expect(try await store.allExpenses().count == 1)
        #expect(!metadata.hasSynced)
    }
    
    @Test func aFailedSyncIsRetriedFromTheSamePoint() async throws {
        try await store.expenses.save(expense("Local"))
        await cloud.setFailsOnWrite(true)
        await #expect(throws: Error.self) { try await synchronizer.sync() }
        #expect(!metadata.hasSynced)
        
        await cloud.setFailsOnWrite(false)
        try await synchronizer.sync()
        
        #expect(await cloud.records.count == 1)
        #expect(metadata.hasSynced)
    }
}
