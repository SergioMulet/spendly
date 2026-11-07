import Foundation

enum QuickExpenseError: Error {
    case invalidAmount
}

/// Registers an expense from a voice command: dated today, titled with the category name.
struct QuickExpenseService {
    private let repository: ExpenseRepository
    private let defaults: UserDefaults
    
    init(repository: ExpenseRepository? = nil, defaults: UserDefaults = .standard) {
        self.repository = repository ?? iCloudExpenseRepository.shared
        self.defaults = defaults
    }
    
    @discardableResult
    func add(amount: Double, category: Category, on date: Date = .now) async throws -> Expense {
        guard amount > 0 else { throw QuickExpenseError.invalidAmount }
        let expense = Expense(title: title(for: category), amount: amount, date: date, category: category)
        try await repository.save(expense)
        return expense
    }
    
    /// The category name in the language chosen inside the app, like the expense form does (repeated logic, needs refactorization).
    private func title(for category: Category) -> String {
        var name = category.title
        name.locale = defaults.string(forKey: "language").flatMap(Language.init)?.locale ?? .current
        return String(localized: name)
    }
}
