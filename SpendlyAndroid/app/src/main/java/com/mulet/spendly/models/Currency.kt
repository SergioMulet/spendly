package com.mulet.spendly.models

import androidx.annotation.StringRes
import com.mulet.spendly.R

enum class Currency(val code: String, @StringRes val nameRes: Int) {
    EUR("EUR", R.string.currency_eur),
    USD("USD", R.string.currency_usd),
    GBP("GBP", R.string.currency_gbp);

    companion object {
        fun fromCode(code: String?): Currency? = entries.firstOrNull { it.code == code }
    }
}
