import Foundation

/// Remembers which category the user uses for each merchant, so new payments can be categorized.
protocol MerchantCategoryRepository: Sendable {
    func category(for merchant: String) async throws -> Category?
    func remember(_ category: Category, for merchant: String) async throws
}
