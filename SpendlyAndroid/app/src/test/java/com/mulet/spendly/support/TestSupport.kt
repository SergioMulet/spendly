package com.mulet.spendly.support

import com.mulet.spendly.models.Currency
import com.mulet.spendly.models.Expense
import com.mulet.spendly.models.Language
import com.mulet.spendly.services.ExpenseRepository
import com.mulet.spendly.services.SettingsRepository
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.setMain
import org.junit.rules.TestWatcher
import org.junit.runner.Description
import java.time.YearMonth

/** Runs the view models' coroutines right away, so a test can check the result after each call. */
@OptIn(ExperimentalCoroutinesApi::class)
class MainDispatcherRule : TestWatcher() {
    override fun starting(description: Description) = Dispatchers.setMain(UnconfinedTestDispatcher())
    override fun finished(description: Description) = Dispatchers.resetMain()
}

class FakeSettingsRepository(
    override var currency: Currency = Currency.EUR,
    override var language: Language = Language.ENGLISH,
) : SettingsRepository

/** Keeps the expenses in memory. Set [failing] to make every call throw. */
class FakeExpenseRepository(vararg initial: Expense) : ExpenseRepository {
    val expenses = initial.toMutableList()
    var failing = false

    override suspend fun fetchExpenses(month: YearMonth): List<Expense> {
        check(!failing) { "fetch failed" }
        return expenses.filter { YearMonth.from(it.date) == month }
    }

    override suspend fun save(expense: Expense) {
        check(!failing) { "save failed" }
        expenses.removeAll { it.id == expense.id }
        expenses.add(expense)
    }

    override suspend fun delete(ids: List<String>) {
        check(!failing) { "delete failed" }
        expenses.removeAll { it.id in ids }
    }
}
