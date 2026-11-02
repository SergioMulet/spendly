import Foundation
import Observation

@Observable
final class HomeViewModel {
    var selectedDate = Date()
    var showingAddExpense = false
    var showingError = false
    private(set) var errorTitle: LocalizedStringResource = "Could not load expenses"
    private(set) var groups: [ExpenseGroup] = []
    
    private let repository: ExpenseRepository
    private let importer: PendingTransactionImporter
    
    init(repository: ExpenseRepository? = nil, importer: PendingTransactionImporter? = nil) {
        self.repository = repository ?? SwiftDataExpenseRepository.shared
        self.importer = importer ?? PendingTransactionImporter()
    }
    
    /// Changes when the selected date moves to another month, to reload the list.
    var month: DateComponents {
        Calendar.current.dateComponents([.year, .month], from: selectedDate)
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
    
    /// Loads the expenses of the selected month, grouped by category (highest total first).
    func loadExpenses() async {
        guard let interval = Calendar.current.dateInterval(of: .month, for: selectedDate) else { return }
        do {
            let expenses = try await repository.fetchExpenses(in: interval)
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
    
    /// Deletes every expense of the group, which only holds the selected month's expenses.
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
