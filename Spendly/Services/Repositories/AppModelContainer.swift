import SwiftData

/// The single SwiftData container shared by the app and the repositories.
enum AppModelContainer {
    static let shared: ModelContainer = {
        do {
            return try make()
        } catch {
            fatalError("Could not create the model container: \(error)")
        }
    }()
    
    /// An in-memory container is used by tests, so they never touch the user's data.
    /// SwiftData's own CloudKit sync is turned off: iCloud sync is done by `iCloudExpenseRepository`.
    static func make(inMemory: Bool = false) throws -> ModelContainer {
        try ModelContainer(
            for: ExpenseEntity.self, PendingTransactionEntity.self, MerchantCategoryEntity.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: inMemory, cloudKitDatabase: .none)
        )
    }
}
