import AppIntents
import Foundation

/// "Hey Siri, add a car expense in Spendly": Siri asks for the amount and the expense is saved.
struct AddExpenseIntent: AppIntent {
    static let title: LocalizedStringResource = "Add expense"
    static let description = IntentDescription("Registers a new expense in Spendly.")
    
    @Parameter(title: "Category")
    var category: Category
    
    @Parameter(title: "Amount", requestValueDialog: "How much was it?")
    var amount: Double
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        do {
            try await QuickExpenseService().add(amount: amount, category: category)
        } catch QuickExpenseError.invalidAmount {
            throw $amount.needsValueError("The amount must be greater than zero.")
        }
        let currencyCode = UserDefaults.standard.string(forKey: "currencyCode") ?? "EUR"
        let formattedAmount = amount.formatted(.currency(code: currencyCode))
        return .result(dialog: "Added \(formattedAmount) to \(await String(localized: category.title)).")
    }
}
