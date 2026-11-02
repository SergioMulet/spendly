import Foundation

/// Turns pending payments into expenses, using the category last chosen for each merchant.
struct PendingTransactionImporter: Sendable {
    private let pending: PendingTransactionRepository
    private let merchants: MerchantCategoryRepository
    private let expenses: ExpenseRepository
    
    init(
        pending: PendingTransactionRepository = SwiftDataPendingTransactionRepository.shared,
        merchants: MerchantCategoryRepository = SwiftDataMerchantCategoryRepository.shared,
        expenses: ExpenseRepository = SwiftDataExpenseRepository.shared
    ) {
        self.pending = pending
        self.merchants = merchants
        self.expenses = expenses
    }
    
    func importPending() async throws {
        for transaction in try await pending.fetchAll() {
            let category = try await merchants.category(for: transaction.merchant) ?? .other
            // The expense keeps the pending id: if removing the pending item fails, a retry updates it instead of duplicating it.
            try await expenses.save(Expense(id: transaction.id, title: transaction.merchant, amount: transaction.amount, date: transaction.date, category: category))
            try await pending.remove(id: transaction.id)
        }
    }
}
