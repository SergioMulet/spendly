package com.mulet.spendly.services

import android.content.Context
import com.mulet.spendly.models.Currency
import com.mulet.spendly.models.Language

interface SettingsRepository {
    var currency: Currency
    var language: Language
}

class SharedPreferencesSettingsRepository(context: Context) : SettingsRepository {
    private val preferences = context.getSharedPreferences("settings", Context.MODE_PRIVATE)

    override var currency: Currency
        get() = Currency.fromCode(preferences.getString(CURRENCY_KEY, null)) ?: Currency.EUR
        set(value) = preferences.edit().putString(CURRENCY_KEY, value.code).apply()

    override var language: Language
        get() = Language.fromCode(preferences.getString(LANGUAGE_KEY, null)) ?: Language.deviceDefault
        set(value) = preferences.edit().putString(LANGUAGE_KEY, value.code).apply()

    private companion object {
        const val CURRENCY_KEY = "currencyCode"
        const val LANGUAGE_KEY = "language"
    }
}
