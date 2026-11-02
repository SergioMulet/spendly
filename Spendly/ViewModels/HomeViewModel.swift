import Foundation
import Observation

@Observable
final class HomeViewModel {
    var selectedDate = Date()
    var showingAddExpense = false
    var showingError = false
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
            showingError = true
        }
    }
}
