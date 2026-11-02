import Foundation
import Testing
@testable import Spendly

struct PendingTransactionRepositoryTests {
    @Test func fetchReturnsAddedTransactionsOldestFirst() async throws {
        let store = try TestStore()
        let newer = PendingTransaction(amount: 5, merchant: "B", date: Date(timeIntervalSince1970: 200))
        let older = PendingTransaction(amount: 3, merchant: "A", date: Date(timeIntervalSince1970: 100))
        try await store.pending.add(newer)
        try await store.pending.add(older)
        
        let fetched = try await store.pending.fetchAll()
        
        #expect(fetched.map(\.merchant) == ["A", "B"])
    }
    
    @Test func removeOnlyDeletesTheGivenTransaction() async throws {
        let store = try TestStore()
        let kept = PendingTransaction(amount: 1, merchant: "Kept", date: .now)
        let removed = PendingTransaction(amount: 2, merchant: "Removed", date: .now)
        try await store.pending.add(kept)
        try await store.pending.add(removed)
        
        try await store.pending.remove(id: removed.id)
        
        #expect(try await store.pending.fetchAll().map(\.id) == [kept.id])
    }
}

struct MerchantCategoryRepositoryTests {
    @Test func unknownMerchantHasNoCategory() async throws {
        let store = try TestStore()
        #expect(try await store.merchants.category(for: "Mercadona") == nil)
    }
    
    @Test func rememberedCategoryIsFoundIgnoringCaseAndAccents() async throws {
        let store = try TestStore()
        try await store.merchants.remember(.food, for: "Café Central")
        #expect(try await store.merchants.category(for: "CAFE   CENTRAL") == .food)
    }
    
    @Test func rememberingAgainReplacesTheCategory() async throws {
        let store = try TestStore()
        try await store.merchants.remember(.food, for: "Amazon")
        try await store.merchants.remember(.gifts, for: "amazon")
        #expect(try await store.merchants.category(for: "Amazon") == .gifts)
    }
    
    @Test func emptyMerchantIsIgnored() async throws {
        let store = try TestStore()
        try await store.merchants.remember(.food, for: "   ")
        #expect(try await store.merchants.category(for: "") == nil)
    }
}
