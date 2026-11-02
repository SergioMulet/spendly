import Foundation

/// A payment received from outside the app (e.g. a Wallet automation) that is not an expense yet.
struct PendingTransaction: Identifiable, Sendable {
    var id = UUID()
    var amount: Double
    var merchant: String
    var date: Date
}
