import Foundation

/// Where payments wait until the app turns them into expenses.
protocol PendingTransactionRepository: Sendable {
    func add(_ transaction: PendingTransaction) async throws
    func fetchAll() async throws -> [PendingTransaction]
    func remove(id: UUID) async throws
}
