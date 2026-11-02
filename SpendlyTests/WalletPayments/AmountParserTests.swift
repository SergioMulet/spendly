import Testing
@testable import Spendly

struct AmountParserTests {
    @Test(arguments: [
        ("12,50 €", 12.5),
        ("12.50", 12.5),
        ("$1,234.50", 1234.5),
        ("1.234,50 €", 1234.5),
        ("12", 12),
    ])
    func parsesAmounts(text: String, expected: Double) {
        #expect(AmountParser.parse(text) == expected)
    }

    @Test func rejectsTextWithoutNumbers() {
        #expect(AmountParser.parse("abc") == nil)
    }
}
