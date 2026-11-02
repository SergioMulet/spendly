import Foundation
import Testing
@testable import Spendly

struct iCloudExpenseRepositoryTests {
    private let store: TestStore
    private let cloud = FakeCloudStore()
    private let defaults = TestDefaults.make()
    private let metadata: SyncMetadata
    private let repository: iCloudExpenseRepository
    
    init() throws {
        store = try TestStore()
        metadata = SyncMetadata(defaults: defaults)
        repository = iCloudExpenseRepository(local: store.expenses, cloud: cloud, settings: CloudSyncSettings(defaults: defaults, isAvailable: true), metadata: metadata)
    }
    
    private func turnICloudOn() { defaults.set(true, forKey: CloudSyncSettings.key) }
    private func turnICloudOff() { defaults.set(false, forKey: CloudSyncSettings.key) }
    private var synchronizer: ExpenseSynchronizer { ExpenseSynchronizer(local: store.expenses, cloud: cloud, metadata: metadata) }
    private func expense(_ title: String = "Lunch") -> Expense {
        Expense(title: title, amount: 10, date: .now, category: .food)
    }
    
    @Test func withICloudOffOnlyTheDeviceStoresTheExpense() async throws {
        try await repository.save(expense())
        
        #expect(try await store.allExpenses().count == 1)
        #expect(await cloud.records.isEmpty)
    }
    
    @Test func withICloudOnEverySaveIsMirroredToICloud() async throws {
        turnICloudOn()
        let lunch = expense()
        
        try await repository.save(lunch)
        
        #expect(await cloud.records[lunch.id] == lunch)
        #expect(try await store.allExpenses().count == 1)
    }
    
    @Test func aFailureInICloudDoesNotFailTheSaveAndTheNextSyncUploadsIt() async throws {
        turnICloudOn()
        await cloud.setFailsOnWrite(true)
        let lunch = expense()
        
        try await repository.save(lunch)
        
        #expect(try await store.allExpenses().count == 1)
        #expect(await cloud.records.isEmpty)
        
        await cloud.setFailsOnWrite(false)
        try await synchronizer.sync()
        #expect(await cloud.records[lunch.id] == lunch)
    }
    
    @Test func withICloudOnADeletionIsMirroredAndForgotten() async throws {
        turnICloudOn()
        let lunch = expense()
        try await repository.save(lunch)
        
        try await repository.delete(ids: [lunch.id])
        
        #expect(await cloud.records.isEmpty)
        #expect(try await store.allExpenses().isEmpty)
        #expect(metadata.pendingDeletions.isEmpty)
    }
    
    @Test func aDeletionIsNotRememberedForUsersWhoNeverUsedICloud() async throws {
        let lunch = expense()
        try await repository.save(lunch)
        
        try await repository.delete(ids: [lunch.id])
        
        #expect(metadata.pendingDeletions.isEmpty)
    }
    
    @Test func aDeletionMadeWithICloudOffIsSentOnTheNextSync() async throws {
        turnICloudOn()
        let lunch = expense()
        try await repository.save(lunch)
        try await synchronizer.sync()
        
        turnICloudOff()
        try await repository.delete(ids: [lunch.id])
        #expect(await cloud.records.count == 1)
        #expect(metadata.pendingDeletions == [lunch.id])
        
        turnICloudOn()
        try await synchronizer.sync()
        
        #expect(await cloud.records.isEmpty)
        #expect(try await store.allExpenses().isEmpty)
    }
}
