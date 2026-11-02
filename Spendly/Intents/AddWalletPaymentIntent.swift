import AppIntents
import Foundation

/// Action for the Shortcuts app: a Wallet automation passes each payment here.
struct AddWalletPaymentIntent: AppIntent {
    static let title: LocalizedStringResource = "Add Wallet payment"
    static let description = IntentDescription("Saves a payment so Spendly turns it into an expense.")
    
    @Parameter(title: "Amount")
    var amount: Double
    
    @Parameter(title: "Merchant")
    var merchant: String
    
    func perform() async throws -> some IntentResult {
        let transaction = PendingTransaction(amount: amount, merchant: merchant, date: .now)
        try await SwiftDataPendingTransactionRepository.shared.add(transaction)
        return .result()
    }
}
