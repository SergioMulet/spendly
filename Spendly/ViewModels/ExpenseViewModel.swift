import Foundation
import Observation

@MainActor
@Observable
final class ExpenseViewModel {
    var date: Date
    var title: String
    var amount: Double
    var category: Category
    
    private(set) var isSaving = false
    private(set) var didSave = false
    var showingError = false
    
    /// Saving an expense with an existing id updates it, so the same view model serves both adding and editing.
    private let id: UUID
    private let isEditing: Bool
    private let repository: ExpenseRepository
    private let merchants: MerchantCategoryRepository
    
    /// Starts a new expense.
    convenience init(date: Date, repository: ExpenseRepository? = nil, merchants: MerchantCategoryRepository? = nil) {
        self.init(expense: Expense(title: "", amount: 0, date: date, category: .house), isEditing: false, repository: repository, merchants: merchants)
    }
    
    /// Edits an existing expense.
    convenience init(expense: Expense, repository: ExpenseRepository? = nil, merchants: MerchantCategoryRepository? = nil) {
        self.init(expense: expense, isEditing: true, repository: repository, merchants: merchants)
    }
    
    private init(expense: Expense, isEditing: Bool, repository: ExpenseRepository?, merchants: MerchantCategoryRepository?) {
        id = expense.id
        date = expense.date
        title = expense.title
        amount = expense.amount
        category = expense.category
        self.isEditing = isEditing
        self.repository = repository ?? SwiftDataExpenseRepository.shared
        self.merchants = merchants ?? SwiftDataMerchantCategoryRepository.shared
    }
    
    var screenTitle: LocalizedStringResource {
        isEditing ? "Edit expense" : "New expense"
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
            // Learning the category is a bonus: if it fails, the expense is still saved.
            try? await merchants.remember(category, for: title)
            didSave = true
        } catch {
            showingError = true
        }
    }
    
    private func createExpense() -> Expense {
        Expense(id: id, title: title, amount: amount, date: date, category: category)
    }
}
