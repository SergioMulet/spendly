package com.mulet.spendly

import com.mulet.spendly.models.Category
import com.mulet.spendly.models.Expense
import com.mulet.spendly.support.FakeExpenseRepository
import com.mulet.spendly.support.FakeSettingsRepository
import com.mulet.spendly.support.MainDispatcherRule
import com.mulet.spendly.viewmodels.ExpenseViewModel
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test
import java.time.LocalDate

class ExpenseViewModelTest {
    @get:Rule
    val mainDispatcherRule = MainDispatcherRule()

    private val day = LocalDate.of(2026, 11, 5)

    private fun newExpenseForm(repository: FakeExpenseRepository) =
        ExpenseViewModel(null, day, repository, FakeSettingsRepository()) { "Name of ${it.name}" }

    private fun editForm(expense: Expense, repository: FakeExpenseRepository) =
        ExpenseViewModel(expense, day, repository, FakeSettingsRepository()) { "Name of ${it.name}" }

    @Test
    fun aNewExpenseStartsWithoutAmountAndCannotBeSavedUntilItHasOne() {
        val repository = FakeExpenseRepository()
        val form = newExpenseForm(repository)

        assertEquals("", form.amountText.value)
        assertFalse(form.canSave.value)
        form.save()
        assertTrue(repository.expenses.isEmpty())

        form.setAmountText("12")
        assertTrue(form.canSave.value)
        form.save()
        assertEquals(12.0, repository.expenses.single().amount, 0.0)
        assertTrue(form.didSave.value)
    }

    @Test
    fun aNewExpenseStartsOnTheGivenDay() {
        assertEquals(day, newExpenseForm(FakeExpenseRepository()).date.value)
    }

    @Test
    fun zeroOrTextThatIsNotANumberCannotBeSaved() {
        val form = newExpenseForm(FakeExpenseRepository())

        form.setAmountText("0")
        assertFalse(form.canSave.value)

        form.setAmountText("abc")
        assertFalse(form.canSave.value)
    }

    @Test
    fun theAmountAcceptsACommaOrADot() {
        val repository = FakeExpenseRepository()

        newExpenseForm(repository).apply { setAmountText("12,50") }.save()
        newExpenseForm(repository).apply { setAmountText("7.25") }.save()

        assertEquals(setOf(12.5, 7.25), repository.expenses.map { it.amount }.toSet())
    }

    @Test
    fun aBlankTitleBecomesTheCategoryName() {
        val repository = FakeExpenseRepository()
        val form = newExpenseForm(repository)

        form.setAmountText("5")
        form.setCategory(Category.FOOD)
        form.save()

        assertEquals("Name of FOOD", repository.expenses.single().title)
    }

    @Test
    fun theFormSavesWhatTheUserChose() {
        val repository = FakeExpenseRepository()
        val form = newExpenseForm(repository)

        form.setTitle("Gym")
        form.setAmountText("40")
        form.setCategory(Category.SPORT)
        form.setDate(LocalDate.of(2026, 11, 20))
        form.save()

        val saved = repository.expenses.single()
        assertEquals("Gym", saved.title)
        assertEquals(40.0, saved.amount, 0.0)
        assertEquals(Category.SPORT, saved.category)
        assertEquals(LocalDate.of(2026, 11, 20), saved.date)
    }

    @Test
    fun editingUpdatesTheExpenseInsteadOfAddingANewOne() {
        val original = Expense(title = "Lunch", amount = 10.0, date = day, category = Category.RESTAURANT)
        val repository = FakeExpenseRepository(original)
        val form = editForm(original, repository)

        form.setTitle("Dinner")
        form.setAmountText("25")
        form.setCategory(Category.FOOD)
        form.save()

        val saved = repository.expenses.single()
        assertEquals(original.id, saved.id)
        assertEquals("Dinner", saved.title)
        assertEquals(25.0, saved.amount, 0.0)
        assertEquals(Category.FOOD, saved.category)
        assertTrue(form.didSave.value)
    }

    @Test
    fun theEditFormStartsWithTheExpenseValues() {
        val expense = Expense(title = "Gym", amount = 40.0, date = day, category = Category.SPORT)

        val form = editForm(expense, FakeExpenseRepository(expense))

        assertEquals("Gym", form.title.value)
        assertEquals(40.0, form.amountText.value.replace(',', '.').toDouble(), 0.0)
        assertEquals(Category.SPORT, form.category.value)
        assertEquals(R.string.edit_expense, form.screenTitle)
        assertTrue(form.canSave.value)
    }

    @Test
    fun aFailedSaveShowsAnErrorAndDoesNotClose() {
        val repository = FakeExpenseRepository().apply { failing = true }
        val form = newExpenseForm(repository)

        form.setAmountText("12")
        form.save()

        assertTrue(form.showingError.value)
        assertFalse(form.didSave.value)
        assertTrue(form.canSave.value)

        form.errorDismissed()
        assertFalse(form.showingError.value)
    }

    @Test
    fun theDatePickerWorksInUtcMidnightMillis() {
        val form = newExpenseForm(FakeExpenseRepository())

        assertEquals(1_793_836_800_000L, form.dateMillis)

        form.datePicked(1_793_836_800_000L + 86_400_000L)
        assertEquals(day.plusDays(1), form.date.value)
    }
}
