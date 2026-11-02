import Foundation
import SwiftData

/// Stores expenses with SwiftData, off the main thread.
@ModelActor
actor SwiftDataExpenseRepository: ExpenseRepository {
    static let shared = SwiftDataExpenseRepository(modelContainer: AppModelContainer.shared)
    
    func fetchExpenses(in interval: DateInterval) async throws -> [Expense] {
        let start = interval.start
        let end = interval.end
        let descriptor = FetchDescriptor<ExpenseEntity>(
            predicate: #Predicate { $0.date >= start && $0.date < end },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try modelContext.fetch(descriptor).map(\.expense)
    }
    
    func save(_ expense: Expense) async throws {
        let id = expense.id
        let descriptor = FetchDescriptor<ExpenseEntity>(predicate: #Predicate { $0.id == id })
        if let entity = try modelContext.fetch(descriptor).first {
            entity.update(from: expense)
        } else {
            modelContext.insert(ExpenseEntity(expense))
        }
        try modelContext.save()
    }
    
    func delete(ids: [UUID]) async throws {
        try modelContext.delete(model: ExpenseEntity.self, where: #Predicate { ids.contains($0.id) })
        try modelContext.save()
    }
}
