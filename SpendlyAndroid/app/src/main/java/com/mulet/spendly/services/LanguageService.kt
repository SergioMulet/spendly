package com.mulet.spendly.services

import androidx.appcompat.app.AppCompatDelegate
import androidx.core.os.LocaleListCompat
import com.mulet.spendly.models.Language

interface LanguageService {
    fun apply(language: Language)
}

/** Switches the app language without touching the device one. */
class AppCompatLanguageService : LanguageService {
    override fun apply(language: Language) {
        AppCompatDelegate.setApplicationLocales(LocaleListCompat.forLanguageTags(language.code))
    }
}
