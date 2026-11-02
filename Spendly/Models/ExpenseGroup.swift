import Foundation

/// The expenses of one category, with their total.
struct ExpenseGroup: Identifiable {
    let category: Category
    let expenses: [Expense]
    
    var id: Category { category }
    var total: Double { expenses.reduce(0) { $0 + $1.amount } }
}
