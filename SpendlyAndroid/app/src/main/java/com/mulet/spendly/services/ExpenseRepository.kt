package com.mulet.spendly.services

import com.mulet.spendly.models.Expense
import java.time.YearMonth

/** Abstraction over where expenses are persisted, so view models do not know about the storage (Strategy pattern). */
interface ExpenseRepository {
    suspend fun fetchExpenses(month: YearMonth): List<Expense>

    /** Saving an expense with an existing id updates it. */
    suspend fun save(expense: Expense)

    suspend fun delete(ids: List<String>)
}
