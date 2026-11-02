import Foundation

/// Abstraction over where expenses are persisted, so view models do not know about the storage (Strategy pattern).
/// SwiftData is the default; a CloudKit-backed implementation can be added when iCloud sync is enabled.
protocol ExpenseRepository: Sendable {
    func fetchExpenses(in interval: DateInterval) async throws -> [Expense]
    func save(_ expense: Expense) async throws
}
