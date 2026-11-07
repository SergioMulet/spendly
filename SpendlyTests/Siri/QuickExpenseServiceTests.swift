import Foundation
import Testing
@testable import Spendly

struct QuickExpenseServiceTests {
    private func service(_ store: TestStore, language: String? = nil) -> QuickExpenseService {
        let defaults = TestDefaults.make()
        if let language { defaults.set(language, forKey: "language") }
        return QuickExpenseService(repository: store.expenses, defaults: defaults)
    }

    @Test func addsAnExpenseWithTheAmountTheCategoryAndTodaysDate() async throws {
        let store = try TestStore()
        let day = Date(timeIntervalSince1970: 1_793_836_800)

        try await service(store).add(amount: 30.6, category: .car, on: day)

        let expense = try #require(try await store.allExpenses().first)
        #expect(try await store.allExpenses().count == 1)
        #expect(expense.amount == 30.6)
        #expect(expense.category == .car)
        #expect(expense.date == day)
    }

    @Test func theExpenseIsDatedTodayByDefault() async throws {
        let store = try TestStore()

        let expense = try await service(store).add(amount: 5, category: .food)

        #expect(Calendar.current.isDateInToday(expense.date))
    }

    @Test func theTitleIsTheCategoryNameInTheLanguageChosenInTheApp() async throws {
        let store = try TestStore()

        let spanish = try await service(store, language: "es").add(amount: 10, category: .car)
        let english = try await service(store, language: "en").add(amount: 10, category: .car)

        #expect(spanish.title == "Coche")
        #expect(english.title == "Car")
    }

    @Test func theReturnedExpenseIsTheSavedOne() async throws {
        let store = try TestStore()

        let returned = try await service(store).add(amount: 12, category: .pet)

        #expect(try await store.allExpenses().first?.id == returned.id)
    }

    @Test(arguments: [0.0, -5.0])
    func anAmountThatIsNotPositiveIsRejectedAndNothingIsSaved(amount: Double) async throws {
        let store = try TestStore()

        await #expect(throws: QuickExpenseError.invalidAmount) {
            try await service(store).add(amount: amount, category: .car)
        }

        #expect(try await store.allExpenses().isEmpty)
    }
}
