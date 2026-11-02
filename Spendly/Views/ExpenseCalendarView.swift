import SwiftUI
import UIKit

/// The system calendar (`UICalendarView`) showing, under each day, what was spent on it.
struct ExpenseCalendarView: UIViewRepresentable {
    @Binding var selectedDate: Date
    @Binding var visibleMonth: DateComponents
    let dailyTotals: [Date: Double]
    let currencyCode: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UICalendarView {
        let calendarView = UICalendarView()
        calendarView.calendar = context.environment.calendar
        calendarView.locale = context.environment.locale
        calendarView.delegate = context.coordinator
        let selection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        selection.selectedDate = context.environment.calendar.dateComponents([.year, .month, .day], from: selectedDate)
        calendarView.selectionBehavior = selection
        calendarView.visibleDateComponents = visibleMonth
        return calendarView
    }
    
    func updateUIView(_ calendarView: UICalendarView, context: Context) {
        let coordinator = context.coordinator
        coordinator.parent = self
        coordinator.locale = context.environment.locale
        
        if calendarView.calendar != context.environment.calendar {
            calendarView.calendar = context.environment.calendar
        }
        if calendarView.locale != context.environment.locale {
            calendarView.locale = context.environment.locale
        }
        coordinator.reloadDecorationsIfNeeded(in: calendarView)
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UICalendarView, context: Context) -> CGSize? {
        let width = proposal.width ?? 320
        let fitting = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        let size = uiView.systemLayoutSizeFitting(fitting, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        return CGSize(width: width, height: size.height)
    }
    
    final class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        var parent: ExpenseCalendarView
        var locale = Locale.current
        private var shownTotals: [Date: Double] = [:]
        private var shownCurrencyCode = ""
        
        init(_ parent: ExpenseCalendarView) {
            self.parent = parent
        }
        
        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            guard let date = calendarView.calendar.date(from: dateComponents),
                  let total = parent.dailyTotals[Calendar.current.startOfDay(for: date)] else { return nil }
            let text = total.formatted(.currency(code: parent.currencyCode).notation(.compactName).locale(locale))
            return .customView {
                let label = UILabel()
                label.text = text
                label.font = .preferredFont(forTextStyle: .caption2)
                label.textColor = .secondaryLabel
                label.textAlignment = .center
                label.adjustsFontSizeToFitWidth = true
                label.minimumScaleFactor = 0.5
                return label
            }
        }
        
        func calendarView(_ calendarView: UICalendarView, didChangeVisibleDateComponentsFrom previousDateComponents: DateComponents) {
            let visible = calendarView.visibleDateComponents
            parent.visibleMonth = DateComponents(year: visible.year, month: visible.month)
        }
        
        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            guard let date = dateComponents?.date else { return }
            parent.selectedDate = date
        }
        
        /// Decorations are created once per day, so they must be reloaded when the totals or the currency change.
        func reloadDecorationsIfNeeded(in calendarView: UICalendarView) {
            guard shownTotals != parent.dailyTotals || shownCurrencyCode != parent.currencyCode else { return }
            shownTotals = parent.dailyTotals
            shownCurrencyCode = parent.currencyCode
            let calendar = calendarView.calendar
            guard let month = calendar.date(from: calendarView.visibleDateComponents),
                  let days = calendar.range(of: .day, in: .month, for: month) else { return }
            let components = days.map { day in
                var components = calendar.dateComponents([.year, .month], from: month)
                components.day = day
                return components
            }
            calendarView.reloadDecorations(forDateComponents: components, animated: false)
        }
    }
}
