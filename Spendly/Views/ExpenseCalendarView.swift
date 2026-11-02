import SwiftUI

/// A month calendar that shows, under each day, what was spent on it.
struct ExpenseCalendarView: View {
    @Binding var selectedDate: Date
    @Binding var visibleMonth: DateComponents
    let dailyTotals: [Date: Double]
    let currencyCode: String
    
    @Environment(\.calendar) private var calendar
    @Environment(\.locale) private var locale
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    
    var body: some View {
        if let grid = MonthGrid(month: visibleMonth, calendar: calendar, locale: locale) {
            VStack(spacing: 12) {
                header(for: grid)
                LazyVGrid(columns: columns, spacing: 4) {
                    ForEach(grid.weekdaySymbols, id: \.self) { symbol in
                        Text(symbol)
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                    ForEach(grid.cells) { cell in
                        if let day = cell.day {
                            dayButton(for: day)
                        } else {
                            Color.clear
                        }
                    }
                }
            }
            .gesture(
                DragGesture(minimumDistance: 30).onEnded { value in
                    guard abs(value.translation.width) > abs(value.translation.height) * 2 else { return }
                    visibleMonth = value.translation.width < 0 ? grid.nextMonth : grid.previousMonth
                }
            )
        }
    }
    
    private func header(for grid: MonthGrid) -> some View {
        HStack {
            Text(grid.monthStart, format: .dateTime.month(.wide).year())
                .font(.title3.weight(.semibold))
            Spacer()
            Button {
                visibleMonth = grid.previousMonth
            } label: {
                Image(systemName: "chevron.left")
            }
            Button {
                visibleMonth = grid.nextMonth
            } label: {
                Image(systemName: "chevron.right")
            }
        }
        .font(.title3.weight(.semibold))
        .buttonStyle(.borderless)
    }
    
    private func dayButton(for day: MonthGrid.Day) -> some View {
        let isSelected = calendar.isDate(day.date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(day.date)
        let total = dailyTotals[day.date]
        
        return Button {
            selectedDate = day.date
        } label: {
            VStack(spacing: 2) {
                Text("\(day.number)")
                    .font(.title3)
                    .fontWeight(isToday ? .semibold : .regular)
                    .foregroundStyle(isSelected ? AnyShapeStyle(.white) : isToday ? AnyShapeStyle(.tint) : AnyShapeStyle(.primary))
                    .frame(width: 40, height: 40)
                    .background(isSelected ? AnyShapeStyle(.tint) : AnyShapeStyle(.clear), in: Circle())
                Text(total ?? 0, format: .currency(code: currencyCode).notation(.compactName))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .opacity(total == nil ? 0 : 1)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(day.date, format: .dateTime.day().month(.wide).year()))
        .accessibilityValue(total.map { Text($0, format: .currency(code: currencyCode)) } ?? Text(verbatim: ""))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
