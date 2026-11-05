package com.mulet.spendly.viewmodels

import androidx.lifecycle.ViewModel
import com.mulet.spendly.models.MonthGrid
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import java.time.Clock
import java.time.LocalDate
import java.time.YearMonth
import java.util.Locale
import kotlin.math.abs

class HomeViewModel(private val clock: Clock = Clock.systemDefaultZone()) : ViewModel() {
    private val _selectedDate = MutableStateFlow(LocalDate.now(clock))
    val selectedDate: StateFlow<LocalDate> = _selectedDate.asStateFlow()

    /** The month shown by the calendar. */
    private val _visibleMonth = MutableStateFlow(YearMonth.now(clock))
    val visibleMonth: StateFlow<YearMonth> = _visibleMonth.asStateFlow()

    private val _showingMonthPicker = MutableStateFlow(false)
    val showingMonthPicker: StateFlow<Boolean> = _showingMonthPicker.asStateFlow()

    fun monthGrid(month: YearMonth, locale: Locale) = MonthGrid(month, locale, LocalDate.now(clock))

    fun selectDate(date: LocalDate) {
        _selectedDate.value = date
    }

    fun showPreviousMonth() {
        _visibleMonth.value = _visibleMonth.value.minusMonths(1)
    }

    fun showNextMonth() {
        _visibleMonth.value = _visibleMonth.value.plusMonths(1)
    }

    fun selectMonth(month: Int) {
        _visibleMonth.value = _visibleMonth.value.withMonth(month)
    }

    fun selectYear(year: Int) {
        _visibleMonth.value = _visibleMonth.value.withYear(year)
    }

    fun setShowingMonthPicker(showing: Boolean) {
        _showingMonthPicker.value = showing
    }

    /** A swipe to the left shows the next month; to the right, the previous one. Short or vertical-ish drags are ignored. */
    fun onCalendarSwipe(horizontalDistance: Float) {
        if (abs(horizontalDistance) < SWIPE_THRESHOLD) return
        if (horizontalDistance < 0) showNextMonth() else showPreviousMonth()
    }

    fun addExpenseTapped() {
        // TODO: show the add expense screen
    }

    private companion object {
        const val SWIPE_THRESHOLD = 100f
    }
}
