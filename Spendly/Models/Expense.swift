import Foundation

enum Category: String, CaseIterable, Codable {
    case house, sport, car, entertainment, restaurant, communication, food, transport, pet, clothes, gifts, health
    
    var title: LocalizedStringResource {
        switch self {
        case .house: "House"
        case .sport: "Sport"
        case .car: "Car"
        case .entertainment: "Entertainment"
        case .restaurant: "Restaurant"
        case .communication: "Communication"
        case .food: "Food"
        case .transport: "Transport"
        case .pet: "Pet"
        case .clothes: "Clothes"
        case .gifts: "Gifts"
        case .health: "Health"
        }
    }
}

struct Expense: Identifiable, Sendable {
    var id = UUID()
    var title: String
    var amount: Double
    var date: Date
    var category: Category
}
