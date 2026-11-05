package com.mulet.spendly

import com.mulet.spendly.models.Category
import com.mulet.spendly.models.Expense
import com.mulet.spendly.support.FakeExpenseRepository
import com.mulet.spendly.support.FakeSettingsRepository
import com.mulet.spendly.support.MainDispatcherRule
import com.mulet.spendly.viewmodels.HomeViewModel
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test
import java.time.Clock
import java.time.Instant
import java.time.LocalDate
import java.time.YearMonth
import java.time.ZoneOffset

class HomeViewModelTest {
    @get:Rule
    val mainDispatcherRule = MainDispatcherRule()

    private val clock = Clock.fixed(Instant.parse("2026-11-05T10:00:00Z"), ZoneOffset.UTC)

    private fun viewModel() = HomeViewModel(FakeExpenseRepository(), FakeSettingsRepository(), clock)

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

    @Test
    fun dailyTotalsAddUpTheExpensesOfEachDayOfTheVisibleMonth() {
        val repository = FakeExpenseRepository(
            expense("Coffee", 2.5, LocalDate.of(2026, 11, 5)),
            expense("Lunch", 10.0, LocalDate.of(2026, 11, 5)),
            expense("Taxi", 7.0, LocalDate.of(2026, 11, 20)),
            expense("Other month", 99.0, LocalDate.of(2026, 10, 5)),
        )
        val viewModel = HomeViewModel(repository, FakeSettingsRepository(), clock)

        assertEquals(
            mapOf(LocalDate.of(2026, 11, 5) to 12.5, LocalDate.of(2026, 11, 20) to 7.0),
            viewModel.dailyTotals.value,
        )

        viewModel.showPreviousMonth()
        assertEquals(mapOf(LocalDate.of(2026, 10, 5) to 99.0), viewModel.dailyTotals.value)
    }

    @Test
    fun dailyTotalsFollowDeletedExpenses() {
        val lunch = expense("Lunch", 10.0, LocalDate.of(2026, 11, 5))
        val viewModel = HomeViewModel(FakeExpenseRepository(lunch), FakeSettingsRepository(), clock)

        viewModel.delete(lunch)

        assertTrue(viewModel.dailyTotals.value.isEmpty())
    }

    private fun expense(title: String, amount: Double, date: LocalDate) =
        Expense(title = title, amount = amount, date = date, category = Category.entries.first())
}
