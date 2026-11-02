import Foundation

/// Turns the amount text Shortcuts passes ("12,50 €", "$1,234.50", "12.5") into a number.
nonisolated enum AmountParser {
    static func parse(_ text: String) -> Double? {
        let cleaned = text.filter { $0.isNumber || $0 == "," || $0 == "." }
        guard let separator = cleaned.lastIndex(where: { $0 == "," || $0 == "." }) else {
            return Double(cleaned)
        }
        let integerPart = cleaned[..<separator].filter(\.isNumber)
        let decimalPart = cleaned[cleaned.index(after: separator)...]
        return Double("\(integerPart).\(decimalPart)")
    }
}
