import Foundation
@testable import Spendly

/// Real SwiftData repositories on an in-memory container, so tests never touch the user's data.
struct TestStore {
    let pending: SwiftDataPendingTransactionRepository
    let merchants: SwiftDataMerchantCategoryRepository
    let expenses: SwiftDataExpenseRepository
    
    init() throws {
        let container = try AppModelContainer.make(inMemory: true)
        pending = SwiftDataPendingTransactionRepository(modelContainer: container)
        merchants = SwiftDataMerchantCategoryRepository(modelContainer: container)
        expenses = SwiftDataExpenseRepository(modelContainer: container)
    }
    
    var importer: PendingTransactionImporter {
        PendingTransactionImporter(pending: pending, merchants: merchants, expenses: expenses)
    }
    
    func allExpenses() async throws -> [Expense] {
        try await expenses.fetchExpenses(in: DateInterval(start: .distantPast, end: .distantFuture))
    }
}
