package com.mulet.spendly

import com.mulet.spendly.models.Category
import com.mulet.spendly.models.Currency
import com.mulet.spendly.models.Expense
import com.mulet.spendly.support.FakeExpenseRepository
import com.mulet.spendly.support.FakeSettingsRepository
import com.mulet.spendly.support.MainDispatcherRule
import com.mulet.spendly.viewmodels.HomeViewModel
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Rule
import org.junit.Test
import java.time.Clock
import java.time.Instant
import java.time.LocalDate
import java.time.ZoneOffset
import java.util.Locale

class ExpenseListTest {
    @get:Rule
    val mainDispatcherRule = MainDispatcherRule()

    private val clock = Clock.fixed(Instant.parse("2026-11-05T10:00:00Z"), ZoneOffset.UTC)

    private fun expense(title: String, amount: Double, category: Category, day: Int, month: Int = 11) =
        Expense(title = title, amount = amount, date = LocalDate.of(2026, month, day), category = category)

    private fun viewModel(repository: FakeExpenseRepository, settings: FakeSettingsRepository = FakeSettingsRepository()) =
        HomeViewModel(repository, settings, clock)

    @Test
    fun listsTheVisibleMonthGroupedByCategoryHighestTotalFirst() {
        val repository = FakeExpenseRepository(
            expense("Lunch", 10.0, Category.RESTAURANT, 3),
            expense("Gym", 40.0, Category.SPORT, 4),
            expense("Dinner", 25.0, Category.RESTAURANT, 5),
            expense("Old", 99.0, Category.CAR, 20, month = 10),
        )

        val viewModel = viewModel(repository)

        assertEquals(listOf(Category.SPORT, Category.RESTAURANT), viewModel.groups.value.map { it.category })
        val restaurant = viewModel.groups.value.last()
        assertEquals(listOf("Lunch", "Dinner"), restaurant.expenses.map { it.title })
        assertEquals(35.0, restaurant.total, 0.0)
        assertEquals(75.0, viewModel.monthTotal.value, 0.0)
    }

    @Test
    fun changingTheMonthShowsThatMonthsExpenses() {
        val repository = FakeExpenseRepository(
            expense("Lunch", 10.0, Category.RESTAURANT, 3),
            expense("Old", 99.0, Category.CAR, 20, month = 10),
        )
        val viewModel = viewModel(repository)

        viewModel.showPreviousMonth()

        assertEquals(listOf(Category.CAR), viewModel.groups.value.map { it.category })
        assertEquals(99.0, viewModel.monthTotal.value, 0.0)
    }

    @Test
    fun deletingAnExpenseRemovesOnlyThatOne() {
        val lunch = expense("Lunch", 10.0, Category.RESTAURANT, 3)
        val dinner = expense("Dinner", 25.0, Category.RESTAURANT, 5)
        val repository = FakeExpenseRepository(lunch, dinner)
        val viewModel = viewModel(repository)

        viewModel.delete(lunch)

        assertEquals(listOf(dinner), repository.expenses)
        assertEquals(listOf("Dinner"), viewModel.groups.value.single().expenses.map { it.title })
    }

    @Test
    fun deletingAGroupRemovesTheExpensesOfThatCategoryInTheVisibleMonth() {
        val gym = expense("Gym", 40.0, Category.SPORT, 4)
        val lunch = expense("Lunch", 10.0, Category.RESTAURANT, 3)
        val dinner = expense("Dinner", 25.0, Category.RESTAURANT, 5)
        val oldLunch = expense("Old lunch", 12.0, Category.RESTAURANT, 3, month = 10)
        val repository = FakeExpenseRepository(gym, lunch, dinner, oldLunch)
        val viewModel = viewModel(repository)

        viewModel.delete(viewModel.groups.value.first { it.category == Category.RESTAURANT })

        assertEquals(setOf(gym, oldLunch), repository.expenses.toSet())
        assertEquals(listOf(Category.SPORT), viewModel.groups.value.map { it.category })
    }

    @Test
    fun aFailedDeleteKeepsTheListAndShowsAnError() {
        val lunch = expense("Lunch", 10.0, Category.RESTAURANT, 3)
        val repository = FakeExpenseRepository(lunch)
        val viewModel = viewModel(repository)

        repository.failing = true
        viewModel.delete(lunch)

        assertEquals(R.string.error_delete_expense, viewModel.errorTitle.value)
        assertEquals(1, viewModel.groups.value.size)

        viewModel.errorDismissed()
        assertNull(viewModel.errorTitle.value)
    }

    @Test
    fun aFailedLoadShowsAnError() {
        val repository = FakeExpenseRepository().apply { failing = true }

        val viewModel = viewModel(repository)

        assertEquals(R.string.error_load_expenses, viewModel.errorTitle.value)
    }

    @Test
    fun tappingAnExpenseOpensItAndClosingTheFormShowsTheSavedChanges() {
        val lunch = expense("Lunch", 10.0, Category.RESTAURANT, 3)
        val repository = FakeExpenseRepository(lunch)
        val viewModel = viewModel(repository)

        viewModel.expenseTapped(lunch)
        assertEquals(lunch, viewModel.expenseToEdit.value)

        repository.expenses[0] = lunch.copy(title = "Brunch", amount = 15.0)
        viewModel.expenseFormClosed()

        assertNull(viewModel.expenseToEdit.value)
        assertEquals("Brunch", viewModel.groups.value.single().expenses.single().title)
        assertEquals(15.0, viewModel.monthTotal.value, 0.0)
    }

    @Test
    fun theAddButtonOpensTheFormAndClosingItHidesIt() {
        val viewModel = viewModel(FakeExpenseRepository())

        viewModel.addExpenseTapped()
        assertEquals(true, viewModel.showingAddExpense.value)

        viewModel.expenseFormClosed()
        assertEquals(false, viewModel.showingAddExpense.value)
    }

    @Test
    fun amountsUseTheCurrencyChosenInSettings() {
        val settings = FakeSettingsRepository(currency = Currency.USD)
        val viewModel = viewModel(FakeExpenseRepository(), settings)

        assertEquals("$12.50", viewModel.formatAmount(12.5, Locale.US))

        settings.currency = Currency.GBP
        assertEquals("£12.50", viewModel.formatAmount(12.5, Locale.UK))
        assertNotNull(viewModel.formatDay(LocalDate.of(2026, 11, 5), Locale.US))
    }
}
