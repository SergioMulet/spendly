import Foundation
import SwiftData

@ModelActor
actor SwiftDataMerchantCategoryRepository: MerchantCategoryRepository {
    static let shared = SwiftDataMerchantCategoryRepository(modelContainer: AppModelContainer.shared)
    
    func category(for merchant: String) async throws -> Category? {
        try entity(for: MerchantKey.make(merchant))?.category
    }
    
    func remember(_ category: Category, for merchant: String) async throws {
        let key = MerchantKey.make(merchant)
        guard !key.isEmpty else { return }
        if let entity = try entity(for: key) {
            entity.category = category
        } else {
            modelContext.insert(MerchantCategoryEntity(merchantKey: key, category: category))
        }
        try modelContext.save()
    }
    
    private func entity(for key: String) throws -> MerchantCategoryEntity? {
        let descriptor = FetchDescriptor<MerchantCategoryEntity>(predicate: #Predicate { $0.merchantKey == key })
        return try modelContext.fetch(descriptor).first
    }
}
