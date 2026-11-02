import Foundation

/// Decorates another repository, adding iCloud sync on top of it.
/// repo stays the source of truth: every save goes to the wrapped repository first.
struct iCloudExpenseRepository: ExpenseRepository {
    private let repo: ExpenseRepository
    
    init(local: ExpenseRepository) {
        self.repo = local
    }
    
    func fetchExpenses(in interval: DateInterval) async throws -> [Expense] {
        try await repo.fetchExpenses(in: interval)
    }
    
    func save(_ expense: Expense) async throws {
        try await repo.save(expense)
        // TODO: push the expense to iCloud (CloudKit). A failure must not fail the save; queue it for retry.
    }
    
    func delete(ids: [UUID]) async throws {
        try await repo.delete(ids: ids)
        // TODO: delete the expenses from iCloud (CloudKit). A failure must not fail the delete; queue it for retry.
    }
}
