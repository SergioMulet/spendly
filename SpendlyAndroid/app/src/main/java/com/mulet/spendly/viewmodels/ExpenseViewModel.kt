package com.mulet.spendly.viewmodels

import android.app.Application
import androidx.annotation.StringRes
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider.AndroidViewModelFactory.Companion.APPLICATION_KEY
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.initializer
import androidx.lifecycle.viewmodel.viewModelFactory
import com.mulet.spendly.R
import com.mulet.spendly.models.Category
import com.mulet.spendly.models.Expense
import com.mulet.spendly.services.ExpenseRepository
import com.mulet.spendly.services.RoomExpenseRepository
import com.mulet.spendly.services.SettingsRepository
import com.mulet.spendly.services.SharedPreferencesSettingsRepository
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import java.text.NumberFormat
import java.time.Instant
import java.time.LocalDate
import java.time.ZoneOffset
import java.time.format.DateTimeFormatter
import java.time.format.FormatStyle
import java.util.Currency
import java.util.Locale
import java.util.UUID

/** Saving an expense with an existing id updates it, so the same view model serves both adding and editing. */
class ExpenseViewModel(
    expense: Expense?,
    date: LocalDate,
    private val repository: ExpenseRepository,
    settings: SettingsRepository,
    private val categoryName: (Category) -> String,
) : ViewModel() {
    private val id = expense?.id ?: UUID.randomUUID().toString()

    @StringRes
    val screenTitle: Int = if (expense == null) R.string.new_expense else R.string.edit_expense

    /** The symbol of the currency chosen in Settings, shown next to the amount. */
    val currencySymbol: String = Currency.getInstance(settings.currency.code).symbol

    val categories: List<Category> = Category.entries

    private val _title = MutableStateFlow(expense?.title ?: "")
    val title: StateFlow<String> = _title.asStateFlow()

    /** What the user types in the amount field. Empty only in a new expense that has no amount yet. */
    private val _amountText = MutableStateFlow(expense?.let { amountFormat().format(it.amount) } ?: "")
    val amountText: StateFlow<String> = _amountText.asStateFlow()

    private val _date = MutableStateFlow(expense?.date ?: date)
    val date: StateFlow<LocalDate> = _date.asStateFlow()

    private val _category = MutableStateFlow(expense?.category ?: Category.HOUSE)
    val category: StateFlow<Category> = _category.asStateFlow()

    private val _isSaving = MutableStateFlow(false)

    private val _didSave = MutableStateFlow(false)
    val didSave: StateFlow<Boolean> = _didSave.asStateFlow()

    private val _showingError = MutableStateFlow(false)
    val showingError: StateFlow<Boolean> = _showingError.asStateFlow()

    /** An expense cannot be saved without an amount greater than zero. */
    val canSave: StateFlow<Boolean> = combine(_amountText, _isSaving) { text, isSaving ->
        isSavable(text, isSaving)
    }.stateIn(viewModelScope, SharingStarted.Eagerly, isSavable(_amountText.value, false))

    fun setTitle(title: String) {
        _title.value = title
    }

    fun setAmountText(text: String) {
        _amountText.value = text
    }

    fun setDate(date: LocalDate) {
        _date.value = date
    }

    fun setCategory(category: Category) {
        _category.value = category
    }

    /** The date as the milliseconds the Material date picker works with (midnight UTC). */
    val dateMillis: Long get() = _date.value.atStartOfDay(ZoneOffset.UTC).toInstant().toEpochMilli()

    fun datePicked(millis: Long?) {
        millis?.let { _date.value = Instant.ofEpochMilli(it).atZone(ZoneOffset.UTC).toLocalDate() }
    }

    fun formatDate(date: LocalDate, locale: Locale): String =
        DateTimeFormatter.ofLocalizedDate(FormatStyle.MEDIUM).withLocale(locale).format(date)

    fun save() {
        val amount = parse(_amountText.value)
        if (!canSave.value || amount == null) return
        viewModelScope.launch {
            _isSaving.value = true
            try {
                if (_title.value.isBlank()) _title.value = categoryName(_category.value)
                repository.save(Expense(id, _title.value, amount, _date.value, _category.value))
                _didSave.value = true
            } catch (e: CancellationException) {
                throw e
            } catch (e: Exception) {
                _showingError.value = true
            } finally {
                _isSaving.value = false
            }
        }
    }

    fun errorDismissed() {
        _showingError.value = false
    }

    private fun isSavable(text: String, isSaving: Boolean) = (parse(text) ?: 0.0) > 0 && !isSaving

    /** Accepts "12,50" and "12.50". Text that is not a number gives null. */
    private fun parse(text: String): Double? = text.trim().replace(',', '.').toDoubleOrNull()

    private fun amountFormat() = NumberFormat.getNumberInstance(Locale.getDefault()).apply {
        isGroupingUsed = false
        minimumFractionDigits = 2
        maximumFractionDigits = 2
    }

    companion object {
        fun factory(expense: Expense?, date: LocalDate) = viewModelFactory {
            initializer {
                val application = checkNotNull(this[APPLICATION_KEY]) as Application
                ExpenseViewModel(
                    expense = expense,
                    date = date,
                    repository = RoomExpenseRepository.from(application),
                    settings = SharedPreferencesSettingsRepository(application),
                    categoryName = { application.getString(it.titleRes) },
                )
            }
        }
    }
}
