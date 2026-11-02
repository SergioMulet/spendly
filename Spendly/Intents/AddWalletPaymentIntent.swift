import AppIntents
import Foundation

/// Action for the Shortcuts app: a Wallet automation passes each payment here.
struct AddWalletPaymentIntent: AppIntent {
    static let title: LocalizedStringResource = "Add Wallet payment"
    static let description = IntentDescription("Saves a payment so Spendly turns it into an expense.")
    
    @Parameter(title: "Amount")
    var amount: String

    @Parameter(title: "Merchant")
    var merchant: String

    func perform() async throws -> some IntentResult {
        guard let value = AmountParser.parse(amount) else {
            throw $amount.needsValueError()
        }
        let transaction = PendingTransaction(amount: value, merchant: merchant, date: .now)
        try await SwiftDataPendingTransactionRepository.shared.add(transaction)
        return .result()
    }
}
