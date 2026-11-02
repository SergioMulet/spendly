import Foundation
import Testing
@testable import Spendly

struct MonthGridTests {
    private func calendar(firstWeekday: Int) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        calendar.firstWeekday = firstWeekday
        return calendar
    }
    
    private func grid(year: Int, month: Int, firstWeekday: Int = 2, locale: String = "en") throws -> MonthGrid {
        try #require(MonthGrid(month: DateComponents(year: year, month: month), calendar: calendar(firstWeekday: firstWeekday), locale: Locale(identifier: locale)))
    }
    
    @Test func mondayFirstCalendarPutsASundayStartAtTheEndOfTheFirstWeek() throws {
        // 1 November 2026 is a Sunday.
        let grid = try grid(year: 2026, month: 11)
        
        #expect(grid.cells.count == 6 + 30)
        #expect(grid.cells.prefix(6).allSatisfy { $0.day == nil })
        #expect(grid.cells[6].day?.number == 1)
    }
    
    @Test func sundayFirstCalendarNeedsNoEmptyCellsWhenTheMonthStartsOnASunday() throws {
        let grid = try grid(year: 2026, month: 11, firstWeekday: 1)
        
        #expect(grid.cells.first?.day?.number == 1)
        #expect(grid.cells.count == 30)
    }
    
    @Test func daysAreInOrderWithTheRightLengthForEachMonth() throws {
        #expect(try grid(year: 2028, month: 2).cells.compactMap(\.day).count == 29)
        #expect(try grid(year: 2027, month: 2).cells.compactMap(\.day).count == 28)
        #expect(try grid(year: 2026, month: 11).cells.compactMap(\.day).map(\.number) == Array(1...30))
    }
    
    @Test func weekdayNamesStartOnTheFirstWeekdayAndFollowTheLanguage() throws {
        #expect(try grid(year: 2026, month: 11, locale: "en").weekdaySymbols == ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"])
        #expect(try grid(year: 2026, month: 11, firstWeekday: 1, locale: "es").weekdaySymbols.first == "DOM")
        #expect(try grid(year: 2026, month: 11, locale: "es").weekdaySymbols.first == "LUN")
    }
    
    @Test func previousAndNextMonthsCrossTheYear() throws {
        let january = try grid(year: 2026, month: 1)
        let december = try grid(year: 2026, month: 12)
        
        #expect(january.previousMonth.year == 2025 && january.previousMonth.month == 12)
        #expect(december.nextMonth.year == 2027 && december.nextMonth.month == 1)
    }
    
    @Test func dayDatesAreTheStartOfEachDay() throws {
        let calendar = calendar(firstWeekday: 2)
        let grid = try grid(year: 2026, month: 11)
        
        let days = grid.cells.compactMap(\.day)
        
        #expect(days.allSatisfy { calendar.startOfDay(for: $0.date) == $0.date })
    }
}
