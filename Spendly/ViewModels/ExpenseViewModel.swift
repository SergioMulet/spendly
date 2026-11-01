import Foundation
import Observation

@MainActor
@Observable
final class ExpenseViewModel {
    var date: Date
    var title = ""
    var amount = 0.0
    var category: Category = .house
    
    private(set) var isSaving = false
    private(set) var didSave = false
    var showingError = false
    
    private let repository: ExpenseRepository
    
    init(date: Date, repository: ExpenseRepository? = nil) {
        self.date = date
        self.repository = repository ?? SwiftDataExpenseRepository.shared
    }
    
    var canSave: Bool {
        !title.isEmpty && amount > 0 && !isSaving
    }
    
    func save() async {
        guard canSave else { return }
        isSaving = true
        defer { isSaving = false }
        do {
            try await repository.save(createExpense())
            didSave = true
        } catch {
            showingError = true
        }
    }
    
    private func createExpense() -> Expense {
        Expense(title: title, amount: amount, date: date, category: category)
    }
}
