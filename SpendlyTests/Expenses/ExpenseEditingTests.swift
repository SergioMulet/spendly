import Foundation
import Testing
@testable import Spendly

struct ExpenseEditingTests {
    @Test func editingUpdatesTheExpenseInsteadOfAddingANewOne() async throws {
        let store = try TestStore()
        let original = Expense(title: "Lunch", amount: 10, date: .now, category: .restaurant)
        try await store.expenses.save(original)
        let form = ExpenseViewModel(expense: original, repository: store.expenses, merchants: store.merchants)
        
        form.title = "Dinner"
        form.amountText = "25"
        form.category = .food
        await form.save()
        
        let expenses = try await store.allExpenses()
        #expect(expenses.count == 1)
        #expect(expenses.first?.id == original.id)
        #expect(expenses.first?.title == "Dinner")
        #expect(expenses.first?.amount == 25)
        #expect(expenses.first?.category == .food)
        #expect(form.didSave)
    }
    
    @Test func theFormStartsWithTheExpenseValues() throws {
        let store = try TestStore()
        let expense = Expense(title: "Gym", amount: 40, date: .now, category: .sport)
        
        let form = ExpenseViewModel(expense: expense, repository: store.expenses, merchants: store.merchants)
        
        #expect(form.title == "Gym")
        #expect(form.amount == 40)
        #expect(form.category == .sport)
        #expect(form.canSave)
    }
    
    @Test func recategorizingAnImportedPaymentTeachesTheApp() async throws {
        let store = try TestStore()
        try await store.pending.add(PendingTransaction(amount: 12, merchant: "Mercadona", date: .now))
        try await store.importer.importPending()
        let imported = try #require(try await store.allExpenses().first)
        #expect(imported.category == .other)
        
        let form = ExpenseViewModel(expense: imported, repository: store.expenses, merchants: store.merchants)
        form.category = .food
        await form.save()
        
        try await store.pending.add(PendingTransaction(amount: 30, merchant: "Mercadona", date: .now))
        try await store.importer.importPending()
        let next = try #require(try await store.allExpenses().first { $0.amount == 30 })
        #expect(next.category == .food)
    }
}
