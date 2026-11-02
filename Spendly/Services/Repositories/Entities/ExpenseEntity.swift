import Foundation
import SwiftData

/// SwiftData representation of an `Expense`. Private to the persistence layer.
/// Every property has a default value so the model stays compatible with CloudKit sync.
@Model
final class ExpenseEntity {
    var id = UUID()
    var title = ""
    var amount = 0.0
    var date = Date()
    var category = Category.house
    var updatedAt = Date()
    
    init(_ expense: Expense) {
        id = expense.id
        update(from: expense)
    }
    
    func update(from expense: Expense) {
        title = expense.title
        amount = expense.amount
        date = expense.date
        category = expense.category
        updatedAt = expense.updatedAt
    }
    
    var expense: Expense {
        Expense(id: id, title: title, amount: amount, date: date, category: category, updatedAt: updatedAt)
    }
}
