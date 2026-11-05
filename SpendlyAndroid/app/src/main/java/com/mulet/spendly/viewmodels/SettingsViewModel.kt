package com.mulet.spendly.viewmodels

import android.app.Application
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider.AndroidViewModelFactory.Companion.APPLICATION_KEY
import androidx.lifecycle.viewmodel.initializer
import androidx.lifecycle.viewmodel.viewModelFactory
import com.mulet.spendly.models.Currency
import com.mulet.spendly.models.Language
import com.mulet.spendly.services.AppCompatLanguageService
import com.mulet.spendly.services.LanguageService
import com.mulet.spendly.services.SettingsRepository
import com.mulet.spendly.services.SharedPreferencesSettingsRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

class SettingsViewModel(
    private val settings: SettingsRepository,
    private val languageService: LanguageService,
) : ViewModel() {
    private val _currency = MutableStateFlow(settings.currency)
    val currency: StateFlow<Currency> = _currency.asStateFlow()

    private val _language = MutableStateFlow(settings.language)
    val language: StateFlow<Language> = _language.asStateFlow()

    val currencies: List<Currency> = Currency.entries
    val languages: List<Language> = Language.entries

    fun selectCurrency(currency: Currency) {
        settings.currency = currency
        _currency.value = currency
    }

    fun selectLanguage(language: Language) {
        settings.language = language
        _language.value = language
        languageService.apply(language)
    }

    fun exportData() {
        // TODO: export expenses
    }

    companion object {
        val Factory = viewModelFactory {
            initializer {
                val application = checkNotNull(this[APPLICATION_KEY]) as Application
                SettingsViewModel(
                    settings = SharedPreferencesSettingsRepository(application),
                    languageService = AppCompatLanguageService(),
                )
            }
        }
    }
}
