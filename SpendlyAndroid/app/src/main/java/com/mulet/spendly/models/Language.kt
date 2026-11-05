package com.mulet.spendly.models

import java.util.Locale

enum class Language(val code: String, val displayName: String) {
    ENGLISH("en", "English"),
    SPANISH("es", "Español");

    companion object {
        /** The device language when supported, English otherwise. */
        val deviceDefault: Language
            get() = fromCode(Locale.getDefault().language) ?: ENGLISH

        fun fromCode(code: String?): Language? = entries.firstOrNull { it.code == code }
    }
}
