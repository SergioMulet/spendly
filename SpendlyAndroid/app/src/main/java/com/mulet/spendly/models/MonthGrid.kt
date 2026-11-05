package com.mulet.spendly.models

import java.time.LocalDate
import java.time.Month
import java.time.YearMonth
import java.time.format.DateTimeFormatter
import java.time.format.TextStyle
import java.time.temporal.WeekFields
import java.util.Locale

/** The days of one month laid out in weeks, ready to draw as a 7-column grid. */
class MonthGrid(val month: YearMonth, locale: Locale, today: LocalDate = LocalDate.now()) {
    data class Day(val date: LocalDate, val isToday: Boolean) {
        val number: Int get() = date.dayOfMonth
    }

    /** Weeks starting on the locale's first weekday. Cells outside the month are null. */
    val weeks: List<List<Day?>>

    /** Weekday names starting on the locale's first weekday, e.g. "MON", "TUE"... */
    val weekdaySymbols: List<String>

    /** The month and year, e.g. "November 2026". */
    val title: String = DateTimeFormatter.ofPattern("LLLL y", locale).format(month).capitalized(locale)

    /** Month names in the given locale, January first. */
    val monthNames: List<String> = Month.entries.map { it.getDisplayName(TextStyle.FULL_STANDALONE, locale).capitalized(locale) }

    /** The name of the shown month, e.g. "November". */
    val monthName: String get() = monthNames[month.monthValue - 1]

    /** Years offered by the month picker. It always includes the shown year. */
    val years: IntRange = minOf(today.year - 30, month.year)..maxOf(today.year + 10, month.year)

    val previousMonth: YearMonth = month.minusMonths(1)
    val nextMonth: YearMonth = month.plusMonths(1)

    init {
        val firstWeekday = WeekFields.of(locale).firstDayOfWeek
        val leadingEmptyCells = (month.atDay(1).dayOfWeek.value - firstWeekday.value + 7) % 7
        val days = (1..month.lengthOfMonth()).map { month.atDay(it).let { date -> Day(date, date == today) } }
        val cells = List(leadingEmptyCells) { null } + days
        val trailingEmptyCells = (7 - cells.size % 7) % 7
        weeks = (cells + List(trailingEmptyCells) { null }).chunked(7)
        weekdaySymbols = (0L until 7L).map {
            firstWeekday.plus(it).getDisplayName(TextStyle.SHORT_STANDALONE, locale).uppercase(locale)
        }
    }

    private fun String.capitalized(locale: Locale) = replaceFirstChar { it.titlecase(locale) }
}
