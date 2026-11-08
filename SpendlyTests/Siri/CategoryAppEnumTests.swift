import AppIntents
import Testing
@testable import Spendly

struct CategoryAppEnumTests {
    /// Siri can only offer the categories that have a display representation, so a new category must not be forgotten.
    @Test func everyCategoryCanBeChosenWithSiri() {
        for category in Category.allCases {
            #expect(Category.caseDisplayRepresentations[category] != nil, "\(category) has no display representation")
        }
    }

    @Test func theCategoriesKeepTheirSavedValueSoStoredExpensesStillLoad() {
        #expect(Category.car.rawValue == "car")
        #expect(Category(rawValue: "other") == .other)
    }
}
