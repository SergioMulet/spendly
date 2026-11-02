import Foundation

/// The cells of one month laid out in weeks, ready to draw as a 7-column grid.
struct MonthGrid {
    struct Day: Identifiable {
        let date: Date
        let number: Int
        var id: Date { date }
    }
    
    /// A day, or an empty cell before the 1st so that it falls on the right weekday.
    struct Cell: Identifiable {
        let id: Int
        let day: Day?
    }
    
    let monthStart: Date
    let cells: [Cell]
    /// Weekday names starting on the calendar's first weekday, e.g. "MON", "TUE"...
    let weekdaySymbols: [String]
    let previousMonth: DateComponents
    let nextMonth: DateComponents
    
    /// `calendar` decides the first weekday and the dates; `locale` decides the language of the names.
    init?(month: DateComponents, calendar: Calendar, locale: Locale) {
        guard let monthStart = calendar.date(from: DateComponents(year: month.year, month: month.month)),
              let days = calendar.range(of: .day, in: .month, for: monthStart),
              let previous = calendar.date(byAdding: .month, value: -1, to: monthStart),
              let next = calendar.date(byAdding: .month, value: 1, to: monthStart) else { return nil }
        
        let leadingEmptyCells = (calendar.component(.weekday, from: monthStart) - calendar.firstWeekday + 7) % 7
        let empty = (0..<leadingEmptyCells).map { Cell(id: $0, day: nil) }
        let filled = days.compactMap { number -> Cell? in
            guard let date = calendar.date(byAdding: .day, value: number - 1, to: monthStart) else { return nil }
            return Cell(id: leadingEmptyCells + number - 1, day: Day(date: date, number: number))
        }
        
        var namesCalendar = calendar
        namesCalendar.locale = locale
        let symbols = namesCalendar.shortStandaloneWeekdaySymbols
        let first = calendar.firstWeekday - 1
        
        self.monthStart = monthStart
        cells = empty + filled
        weekdaySymbols = (symbols[first...] + symbols[..<first]).map { $0.uppercased(with: locale) }
        previousMonth = calendar.dateComponents([.year, .month], from: previous)
        nextMonth = calendar.dateComponents([.year, .month], from: next)
    }
}
