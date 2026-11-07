import AppIntents

extension Category: AppEnum {
    nonisolated static let typeDisplayRepresentation: TypeDisplayRepresentation = "Category"
    
    nonisolated static let caseDisplayRepresentations: [Category: DisplayRepresentation] = [
        .house: DisplayRepresentation(title: "House"),
        .sport: DisplayRepresentation(title: "Sport"),
        .car: DisplayRepresentation(title: "Car"),
        .entertainment: DisplayRepresentation(title: "Entertainment"),
        .restaurant: DisplayRepresentation(title: "Restaurant"),
        .communication: DisplayRepresentation(title: "Communication"),
        .food: DisplayRepresentation(title: "Food"),
        .transport: DisplayRepresentation(title: "Transport"),
        .pet: DisplayRepresentation(title: "Pet"),
        .clothes: DisplayRepresentation(title: "Clothes"),
        .gifts: DisplayRepresentation(title: "Gifts"),
        .health: DisplayRepresentation(title: "Health"),
        .other: DisplayRepresentation(title: "Other")
    ]
}
