package com.mulet.spendly

import com.mulet.spendly.models.Currency
import com.mulet.spendly.models.Language
import com.mulet.spendly.services.LanguageService
import com.mulet.spendly.services.SettingsRepository
import com.mulet.spendly.viewmodels.SettingsViewModel
import org.junit.Assert.assertEquals
import org.junit.Test

class SettingsViewModelTest {
    private class FakeSettings(
        override var currency: Currency = Currency.EUR,
        override var language: Language = Language.ENGLISH,
    ) : SettingsRepository

    private class FakeLanguageService : LanguageService {
        var applied: Language? = null
        override fun apply(language: Language) {
            applied = language
        }
    }

    @Test
    fun selectCurrencyPersistsAndPublishes() {
        val settings = FakeSettings()
        val viewModel = SettingsViewModel(settings, FakeLanguageService())

        viewModel.selectCurrency(Currency.GBP)

        assertEquals(Currency.GBP, settings.currency)
        assertEquals(Currency.GBP, viewModel.currency.value)
    }

    @Test
    fun selectLanguagePersistsAndAppliesIt() {
        val settings = FakeSettings()
        val languageService = FakeLanguageService()
        val viewModel = SettingsViewModel(settings, languageService)

        viewModel.selectLanguage(Language.SPANISH)

        assertEquals(Language.SPANISH, settings.language)
        assertEquals(Language.SPANISH, viewModel.language.value)
        assertEquals(Language.SPANISH, languageService.applied)
    }

    @Test
    fun startsFromStoredSettings() {
        val settings = FakeSettings(Currency.USD, Language.SPANISH)
        val viewModel = SettingsViewModel(settings, FakeLanguageService())

        assertEquals(Currency.USD, viewModel.currency.value)
        assertEquals(Language.SPANISH, viewModel.language.value)
    }
}
