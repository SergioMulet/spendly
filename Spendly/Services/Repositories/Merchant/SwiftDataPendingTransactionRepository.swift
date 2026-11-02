import Foundation
import SwiftData

@ModelActor
actor SwiftDataPendingTransactionRepository: PendingTransactionRepository {
    static let shared = SwiftDataPendingTransactionRepository(modelContainer: AppModelContainer.shared)
    
    func add(_ transaction: PendingTransaction) async throws {
        modelContext.insert(PendingTransactionEntity(transaction))
        try modelContext.save()
    }
    
    func fetchAll() async throws -> [PendingTransaction] {
        let descriptor = FetchDescriptor<PendingTransactionEntity>(sortBy: [SortDescriptor(\.date)])
        return try modelContext.fetch(descriptor).map(\.transaction)
    }
    
    func remove(id: UUID) async throws {
        try modelContext.delete(model: PendingTransactionEntity.self, where: #Predicate { $0.id == id })
        try modelContext.save()
    }
}
