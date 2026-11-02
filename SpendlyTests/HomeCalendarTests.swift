import Foundation
import Testing
@testable import Spendly

struct HomeCalendarTests {
    @Test func dailyTotalsAddUpTheExpensesOfEachDay() async throws {
        let store = try TestStore()
        let firstDay = try #require(Calendar.current.dateInterval(of: .month, for: .now)?.start)
        let secondDay = try #require(Calendar.current.date(byAdding: .day, value: 1, to: firstDay))
        for (amount, date) in [(10.0, firstDay), (5.0, firstDay), (7.0, secondDay)] {
            try await store.expenses.save(Expense(title: "E", amount: amount, date: date, category: .food))
        }
        let home = HomeViewModel(repository: store.expenses, importer: store.importer)
        
        await home.loadExpenses()
        
        #expect(home.dailyTotals[firstDay] == 15)
        #expect(home.dailyTotals[secondDay] == 7)
    }
    
    @Test func theListFollowsTheVisibleMonthEvenWithoutPickingADay() async throws {
        let store = try TestStore()
        let lastMonth = try #require(Calendar.current.date(byAdding: .month, value: -1, to: .now))
        try await store.expenses.save(Expense(title: "This month", amount: 10, date: .now, category: .food))
        try await store.expenses.save(Expense(title: "Last month", amount: 20, date: lastMonth, category: .food))
        let home = HomeViewModel(repository: store.expenses, importer: store.importer)
        await home.loadExpenses()
        #expect(home.monthTotal == 10)
        
        home.visibleMonth = Calendar.current.dateComponents([.year, .month], from: lastMonth)
        await home.loadExpenses()
        
        #expect(home.monthTotal == 20)
        #expect(home.groups.flatMap(\.expenses).map(\.title) == ["Last month"])
    }
}
