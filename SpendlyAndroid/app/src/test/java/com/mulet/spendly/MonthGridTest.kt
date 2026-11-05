package com.mulet.spendly

import com.mulet.spendly.models.MonthGrid
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import java.time.LocalDate
import java.time.YearMonth
import java.util.Locale

class MonthGridTest {
    // November 2026 starts on a Sunday and has 30 days.
    private val november = YearMonth.of(2026, 11)
    private val today = LocalDate.of(2026, 11, 5)

    @Test
    fun weeksStartOnTheLocalesFirstWeekday() {
        val spain = MonthGrid(november, Locale.forLanguageTag("es-ES"), today)
        val us = MonthGrid(november, Locale.US, today)

        // Monday first: the 1st (Sunday) is the last cell of the first week.
        assertEquals(6, spain.weeks.first().indexOfFirst { it != null })
        // Sunday first: the 1st is the first cell.
        assertEquals(0, us.weeks.first().indexOfFirst { it != null })
    }

    @Test
    fun containsEveryDayOfTheMonthOnce() {
        val grid = MonthGrid(november, Locale.US, today)

        val days = grid.weeks.flatten().filterNotNull().map { it.number }

        assertEquals((1..30).toList(), days)
        assertTrue(grid.weeks.all { it.size == 7 })
        assertNull(grid.weeks.last().last())
    }

    @Test
    fun marksOnlyTodayAndNavigatesBetweenMonths() {
        val grid = MonthGrid(november, Locale.US, today)

        assertEquals(listOf(5), grid.weeks.flatten().filterNotNull().filter { it.isToday }.map { it.number })
        assertEquals(YearMonth.of(2026, 10), grid.previousMonth)
        assertEquals(YearMonth.of(2026, 12), grid.nextMonth)
    }

    @Test
    fun namesFollowTheLocale() {
        val grid = MonthGrid(november, Locale.forLanguageTag("es-ES"), today)

        assertEquals("Noviembre 2026", grid.title)
        assertEquals("Enero", grid.monthNames.first())
        assertEquals("LUN", grid.weekdaySymbols.first())
        assertTrue(2026 in grid.years)
    }
}
