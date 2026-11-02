import Foundation
import SwiftData

/// The category the user last chose for a merchant. `merchantKey` comes from `MerchantKey.make`.
@Model
final class MerchantCategoryEntity {
    var merchantKey = ""
    var category = Category.other
    
    init(merchantKey: String, category: Category) {
        self.merchantKey = merchantKey
        self.category = category
    }
}
