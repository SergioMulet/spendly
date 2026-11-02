import Foundation
import Testing
@testable import Spendly

/// Integration tests: pending payments -> importer -> expenses, with real in-memory SwiftData repositories.
struct PendingTransactionImporterTests {
    @Test func unknownMerchantBecomesAnOtherExpense() async throws {
        let store = try TestStore()
        let payment = PendingTransaction(amount: 12.5, merchant: "Mercadona", date: .now)
        try await store.pending.add(payment)
        
        try await store.importer.importPending()
        
        let expenses = try await store.allExpenses()
        #expect(expenses.count == 1)
        #expect(expenses.first?.title == "Mercadona")
        #expect(expenses.first?.amount == 12.5)
        #expect(expenses.first?.category == .other)
        #expect(try await store.pending.fetchAll().isEmpty)
    }
    
    @Test func knownMerchantUsesTheRememberedCategory() async throws {
        let store = try TestStore()
        try await store.merchants.remember(.food, for: "Mercadona")
        try await store.pending.add(PendingTransaction(amount: 20, merchant: "MERCADONA", date: .now))
        
        try await store.importer.importPending()
        
        #expect(try await store.allExpenses().first?.category == .food)
    }
    
    @Test func importingTwiceDoesNotDuplicateExpenses() async throws {
        let store = try TestStore()
        try await store.pending.add(PendingTransaction(amount: 8, merchant: "Lidl", date: .now))
        
        try await store.importer.importPending()
        try await store.importer.importPending()
        
        #expect(try await store.allExpenses().count == 1)
    }
    
    @Test func retryAfterAnInterruptedImportDoesNotDuplicateTheExpense() async throws {
        let store = try TestStore()
        let payment = PendingTransaction(amount: 8, merchant: "Lidl", date: .now)
        try await store.pending.add(payment)
        // Simulates a crash after the expense was saved but before the pending item was removed.
        try await store.expenses.save(Expense(id: payment.id, title: payment.merchant, amount: payment.amount, date: payment.date, category: .other))
        
        try await store.importer.importPending()
        
        #expect(try await store.allExpenses().count == 1)
        #expect(try await store.pending.fetchAll().isEmpty)
    }
    
    @Test func theAppLearnsFromManuallyAddedExpenses() async throws {
        let store = try TestStore()
        let form = ExpenseViewModel(date: .now, repository: store.expenses, merchants: store.merchants)
        form.title = "Mercadona"
        form.amountText = "30"
        form.category = .food
        await form.save()
        
        try await store.pending.add(PendingTransaction(amount: 12, merchant: " mercadona ", date: .now))
        try await store.importer.importPending()
        
        let imported = try await store.allExpenses().first { $0.amount == 12 }
        #expect(imported?.category == .food)
    }
}

struct HomeViewModelRefreshTests {
    @Test func refreshImportsPendingPaymentsIntoTheMonthList() async throws {
        let store = try TestStore()
        try await store.pending.add(PendingTransaction(amount: 15, merchant: "Kiosko", date: .now))
        let home = store.homeViewModel()
        
        await home.refresh()
        
        #expect(home.groups.map(\.category) == [.other])
        #expect(home.monthTotal == 15)
    }
}
