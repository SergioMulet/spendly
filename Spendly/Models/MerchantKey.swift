import Foundation

/// Normalizes merchant names so "MERCADONA " and "Mercadona" are treated as the same merchant.
nonisolated enum MerchantKey {
    static func make(_ merchant: String) -> String {
        merchant
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
    }
}
