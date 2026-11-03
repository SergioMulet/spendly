import Foundation
import Observation

@MainActor
@Observable
final class ExpenseViewModel {
    var date: Date
    var title: String
    var amount: Double?
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
        amount = isEditing ? expense.amount : nil
        category = expense.category
        self.isEditing = isEditing
        self.repository = repository ?? iCloudExpenseRepository.shared
        self.merchants = merchants ?? SwiftDataMerchantCategoryRepository.shared
    }
    
    var screenTitle: LocalizedStringResource {
        isEditing ? "Edit expense" : "New expense"
    }
    
    /// Symbol of the currency chosen in Settings ("€", "$"...), shown next to the amount.
    var currencySymbol: String {
        let code = UserDefaults.standard.string(forKey: "currencyCode") ?? "EUR"
        var components = Locale.Components(locale: .current)
        components.currency = Locale.Currency(code)
        return Locale(components: components).currencySymbol ?? code
    }
    
    var canSave: Bool {
        (amount ?? 0) > 0 && !isSaving
    }
    
    func save() async {
        guard canSave else { return }
        isSaving = true
        defer { isSaving = false }
        
        if title.isEmpty {
            var categoryName = category.title
            categoryName.locale = UserDefaults.standard.string(forKey: "language").flatMap(Language.init)?.locale ?? .current
            title = String(localized: categoryName)
        }
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
        Expense(id: id, title: title, amount: amount ?? 0, date: date, category: category, updatedAt: .now)
    }
}
