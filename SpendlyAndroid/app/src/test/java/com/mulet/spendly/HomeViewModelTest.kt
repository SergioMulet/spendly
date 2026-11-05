package com.mulet.spendly

import com.mulet.spendly.viewmodels.HomeViewModel
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import java.time.Clock
import java.time.Instant
import java.time.LocalDate
import java.time.YearMonth
import java.time.ZoneOffset

class HomeViewModelTest {
    private val clock = Clock.fixed(Instant.parse("2026-11-05T10:00:00Z"), ZoneOffset.UTC)

    private fun viewModel() = HomeViewModel(clock)

    @Test
    fun startsOnTodayAndItsMonth() {
        val viewModel = viewModel()

        assertEquals(LocalDate.of(2026, 11, 5), viewModel.selectedDate.value)
        assertEquals(YearMonth.of(2026, 11), viewModel.visibleMonth.value)
    }

    @Test
    fun navigatesAcrossYears() {
        val viewModel = viewModel()

        repeat(2) { viewModel.showNextMonth() }
        assertEquals(YearMonth.of(2027, 1), viewModel.visibleMonth.value)

        repeat(3) { viewModel.showPreviousMonth() }
        assertEquals(YearMonth.of(2026, 10), viewModel.visibleMonth.value)
    }

    @Test
    fun monthAndYearPickerKeepTheOtherValue() {
        val viewModel = viewModel()

        viewModel.selectMonth(3)
        viewModel.selectYear(2024)

        assertEquals(YearMonth.of(2024, 3), viewModel.visibleMonth.value)
    }

    @Test
    fun selectingADayDoesNotChangeTheVisibleMonth() {
        val viewModel = viewModel()

        viewModel.selectDate(LocalDate.of(2026, 11, 20))

        assertEquals(LocalDate.of(2026, 11, 20), viewModel.selectedDate.value)
        assertEquals(YearMonth.of(2026, 11), viewModel.visibleMonth.value)
    }

    @Test
    fun onlyLongSwipesChangeTheMonth() {
        val viewModel = viewModel()

        viewModel.onCalendarSwipe(-20f)
        assertEquals(YearMonth.of(2026, 11), viewModel.visibleMonth.value)

        viewModel.onCalendarSwipe(-300f)
        assertEquals(YearMonth.of(2026, 12), viewModel.visibleMonth.value)

        viewModel.onCalendarSwipe(300f)
        assertEquals(YearMonth.of(2026, 11), viewModel.visibleMonth.value)
    }

    @Test
    fun monthPickerCanBeShownAndHidden() {
        val viewModel = viewModel()

        viewModel.setShowingMonthPicker(true)
        assertTrue(viewModel.showingMonthPicker.value)

        viewModel.setShowingMonthPicker(false)
        assertEquals(false, viewModel.showingMonthPicker.value)
    }
}
