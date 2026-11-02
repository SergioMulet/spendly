import Foundation
import Testing
@testable import Spendly

struct ExpenseDeletionTests {
    @Test func deleteRemovesOnlyThatExpense() async throws {
        let store = try TestStore()
        let kept = Expense(title: "Kept", amount: 1, date: .now, category: .food)
        let removed = Expense(title: "Removed", amount: 2, date: .now, category: .food)
        try await store.expenses.save(kept)
        try await store.expenses.save(removed)
        
        try await store.expenses.delete(ids: [removed.id])
        
        #expect(try await store.allExpenses().map(\.id) == [kept.id])
    }
    
    @Test func deletingAnUnknownExpenseDoesNothing() async throws {
        let store = try TestStore()
        try await store.expenses.save(Expense(title: "Kept", amount: 1, date: .now, category: .food))
        
        try await store.expenses.delete(ids: [UUID()])
        
        #expect(try await store.allExpenses().count == 1)
    }
    
    @Test func homeViewModelDropsTheDeletedExpenseAndEmptyGroups() async throws {
        let store = try TestStore()
        let lunch = Expense(title: "Lunch", amount: 10, date: .now, category: .restaurant)
        let bus = Expense(title: "Bus", amount: 2, date: .now, category: .transport)
        try await store.expenses.save(lunch)
        try await store.expenses.save(bus)
        let home = HomeViewModel(repository: store.expenses, importer: store.importer)
        await home.loadExpenses()
        
        await home.delete(lunch)
        
        #expect(home.groups.map(\.category) == [.transport])
        #expect(home.monthTotal == 2)
    }
    
    @Test func deletingAGroupRemovesItsExpensesButNotOtherCategoriesOrMonths() async throws {
        let store = try TestStore()
        let lastYear = try #require(Calendar.current.date(byAdding: .year, value: -1, to: .now))
        let lunch = Expense(title: "Lunch", amount: 10, date: .now, category: .restaurant)
        let dinner = Expense(title: "Dinner", amount: 20, date: .now, category: .restaurant)
        let bus = Expense(title: "Bus", amount: 2, date: .now, category: .transport)
        let oldLunch = Expense(title: "Old lunch", amount: 5, date: lastYear, category: .restaurant)
        for expense in [lunch, dinner, bus, oldLunch] { try await store.expenses.save(expense) }
        let home = HomeViewModel(repository: store.expenses, importer: store.importer)
        await home.loadExpenses()
        let restaurantGroup = try #require(home.groups.first { $0.category == .restaurant })
        
        await home.delete(restaurantGroup)
        
        #expect(home.groups.map(\.category) == [.transport])
        let remaining = try await store.allExpenses().map(\.title)
        #expect(Set(remaining) == ["Bus", "Old lunch"])
    }
}
