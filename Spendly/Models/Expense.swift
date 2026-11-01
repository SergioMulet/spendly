import Foundation

enum Category: String, CaseIterable, Codable {
    case house, sport, car, entertainment, restaurant, communication, food, transport, pet, clothes, gifts, health
}

struct Expense: Identifiable, Sendable {
    var id = UUID()
    var title: String
    var amount: Double
    var date: Date
    var category: Category
}
