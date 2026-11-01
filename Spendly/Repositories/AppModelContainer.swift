import SwiftData

/// The single SwiftData container shared by the app and the repositories.
enum AppModelContainer {
    static let shared: ModelContainer = {
        do {
            return try ModelContainer(for: ExpenseEntity.self)
        } catch {
            fatalError("Could not create the model container: \(error)")
        }
    }()
}
