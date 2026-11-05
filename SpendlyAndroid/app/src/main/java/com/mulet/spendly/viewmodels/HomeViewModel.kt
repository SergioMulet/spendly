package com.mulet.spendly.viewmodels

import android.app.Application
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider.AndroidViewModelFactory.Companion.APPLICATION_KEY
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.initializer
import androidx.lifecycle.viewmodel.viewModelFactory
import com.mulet.spendly.R
import com.mulet.spendly.models.Expense
import com.mulet.spendly.models.ExpenseGroup
import com.mulet.spendly.models.MonthGrid
import com.mulet.spendly.services.ExpenseRepository
import com.mulet.spendly.services.RoomExpenseRepository
import com.mulet.spendly.services.SettingsRepository
import com.mulet.spendly.services.SharedPreferencesSettingsRepository
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch
import java.text.NumberFormat
import java.time.Clock
import java.time.LocalDate
import java.time.YearMonth
import java.time.format.DateTimeFormatter
import java.util.Currency
import java.util.Locale
import kotlin.math.abs

class HomeViewModel(
    private val repository: ExpenseRepository,
    private val settings: SettingsRepository,
    private val clock: Clock = Clock.systemDefaultZone(),
) : ViewModel() {
    private val _selectedDate = MutableStateFlow(LocalDate.now(clock))
    val selectedDate: StateFlow<LocalDate> = _selectedDate.asStateFlow()

    /** The month shown by the calendar. The list and the totals always follow it. */
    private val _visibleMonth = MutableStateFlow(YearMonth.now(clock))
    val visibleMonth: StateFlow<YearMonth> = _visibleMonth.asStateFlow()

    private val _showingMonthPicker = MutableStateFlow(false)
    val showingMonthPicker: StateFlow<Boolean> = _showingMonthPicker.asStateFlow()

    /** The expenses of the visible month grouped by category, highest total first. */
    private val _groups = MutableStateFlow<List<ExpenseGroup>>(emptyList())
    val groups: StateFlow<List<ExpenseGroup>> = _groups.asStateFlow()

    private val _monthTotal = MutableStateFlow(0.0)
    val monthTotal: StateFlow<Double> = _monthTotal.asStateFlow()

    private val _showingAddExpense = MutableStateFlow(false)
    val showingAddExpense: StateFlow<Boolean> = _showingAddExpense.asStateFlow()

    private val _expenseToEdit = MutableStateFlow<Expense?>(null)
    val expenseToEdit: StateFlow<Expense?> = _expenseToEdit.asStateFlow()

    /** String resource of the error alert title, or null when there is no error to show. */
    private val _errorTitle = MutableStateFlow<Int?>(null)
    val errorTitle: StateFlow<Int?> = _errorTitle.asStateFlow()

    init {
        viewModelScope.launch {
            visibleMonth.collectLatest { loadExpenses() }
        }
    }

    fun monthGrid(month: YearMonth, locale: Locale) = MonthGrid(month, locale, LocalDate.now(clock))

    /** An amount in the currency chosen in Settings, e.g. "12,50 €". */
    fun formatAmount(amount: Double, locale: Locale): String =
        NumberFormat.getCurrencyInstance(locale)
            .apply { currency = Currency.getInstance(settings.currency.code) }
            .format(amount)

    /** The day and month of an expense, e.g. "5 Nov". */
    fun formatDay(date: LocalDate, locale: Locale): String =
        DateTimeFormatter.ofPattern("d MMM", locale).format(date)

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
        _showingAddExpense.value = true
    }

    fun expenseTapped(expense: Expense) {
        _expenseToEdit.value = expense
    }

    /** Closes the add or edit screen, saved or not, and shows the list again. */
    fun expenseFormClosed() {
        _showingAddExpense.value = false
        _expenseToEdit.value = null
        viewModelScope.launch { loadExpenses() }
    }

    fun delete(expense: Expense) = delete(listOf(expense.id))

    /** Deletes every expense of the group, which only holds the visible month's expenses. */
    fun delete(group: ExpenseGroup) = delete(group.expenses.map { it.id })

    fun errorDismissed() {
        _errorTitle.value = null
    }

    private fun delete(ids: List<String>) {
        viewModelScope.launch {
            try {
                repository.delete(ids)
                loadExpenses()
            } catch (e: CancellationException) {
                throw e
            } catch (e: Exception) {
                _errorTitle.value = R.string.error_delete_expense
            }
        }
    }

    private suspend fun loadExpenses() {
        try {
            val groups = repository.fetchExpenses(_visibleMonth.value)
                .groupBy { it.category }
                .map { (category, expenses) -> ExpenseGroup(category, expenses) }
                .sortedByDescending { it.total }
            _groups.value = groups
            _monthTotal.value = groups.sumOf { it.total }
        } catch (e: CancellationException) {
            throw e
        } catch (e: Exception) {
            _errorTitle.value = R.string.error_load_expenses
        }
    }

    companion object {
        private const val SWIPE_THRESHOLD = 100f

        val Factory = viewModelFactory {
            initializer {
                val application = checkNotNull(this[APPLICATION_KEY]) as Application
                HomeViewModel(
                    repository = RoomExpenseRepository.from(application),
                    settings = SharedPreferencesSettingsRepository(application),
                )
            }
        }
    }
}
