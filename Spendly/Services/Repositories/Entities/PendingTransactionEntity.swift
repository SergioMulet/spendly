import Foundation
import SwiftData

/// SwiftData representation of a `PendingTransaction`. Private to the persistence layer.
@Model
final class PendingTransactionEntity {
    var id = UUID()
    var amount = 0.0
    var merchant = ""
    var date = Date()
    
    init(_ transaction: PendingTransaction) {
        id = transaction.id
        amount = transaction.amount
        merchant = transaction.merchant
        date = transaction.date
    }
    
    var transaction: PendingTransaction {
        PendingTransaction(id: id, amount: amount, merchant: merchant, date: date)
    }
}
