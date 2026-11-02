import Foundation
import Observation

@Observable
final class HomeViewModel {
    var selectedDate = Date()
    var showingAddExpense = false
    var expenseToEdit: Expense?
    var showingError = false
    private(set) var errorTitle: LocalizedStringResource = "Could not load expenses"
    private(set) var groups: [ExpenseGroup] = []
    /// What the user spent on each day (keyed by the start of the day) in the visible month.
    private(set) var dailyTotals: [Date: Double] = [:]
    /// The month shown by the calendar. The list and the totals always follow it, even when no day is selected.
    var visibleMonth = Calendar.current.dateComponents([.year, .month], from: Date())
    
    private let repository: ExpenseRepository
    private let importer: PendingTransactionImporter
    
    init(repository: ExpenseRepository? = nil, importer: PendingTransactionImporter? = nil) {
        self.repository = repository ?? SwiftDataExpenseRepository.shared
        self.importer = importer ?? PendingTransactionImporter()
    }
    
    var visibleMonthDate: Date {
        Calendar.current.date(from: visibleMonth) ?? selectedDate
    }
    
    var currencyCode: String {
        UserDefaults.standard.string(forKey: "currencyCode") ?? "EUR"
    }
    
    var monthTotal: Double {
        groups.reduce(0) { $0 + $1.total }
    }
    
    /// Turns pending payments into expenses, then reloads the list.
    func refresh() async {
        do {
            try await importer.importPending()
        } catch {
            errorTitle = "Could not import payments"
            showingError = true
        }
        await loadExpenses()
    }
    
    func refresh(isActive: Bool) async {
        if isActive { await refresh() }
    }
    
    /// Loads the expenses of the visible month, grouped by category (highest total first).
    func loadExpenses() async {
        guard let interval = Calendar.current.dateInterval(of: .month, for: visibleMonthDate) else { return }
        do {
            let expenses = try await repository.fetchExpenses(in: interval)
            dailyTotals = Dictionary(grouping: expenses) { Calendar.current.startOfDay(for: $0.date) }
                .mapValues { $0.reduce(0) { $0 + $1.amount } }
            groups = Dictionary(grouping: expenses, by: \.category)
                .map { ExpenseGroup(category: $0.key, expenses: $0.value) }
                .sorted { $0.total > $1.total }
        } catch {
            errorTitle = "Could not load expenses"
            showingError = true
        }
    }
    
    func delete(_ expense: Expense) async {
        await delete(ids: [expense.id])
    }
    
    /// Deletes every expense of the group, which only holds the visible month's expenses.
    func delete(_ group: ExpenseGroup) async {
        await delete(ids: group.expenses.map(\.id))
    }
    
    private func delete(ids: [UUID]) async {
        do {
            try await repository.delete(ids: ids)
            await loadExpenses()
        } catch {
            errorTitle = "Could not delete expense"
            showingError = true
        }
    }
}
