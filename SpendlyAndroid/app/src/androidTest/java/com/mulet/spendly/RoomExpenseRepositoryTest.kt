package com.mulet.spendly

import android.content.Context
import androidx.room.Room
import androidx.test.core.app.ApplicationProvider
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.mulet.spendly.models.Category
import com.mulet.spendly.models.Expense
import com.mulet.spendly.services.RoomExpenseRepository
import com.mulet.spendly.services.database.SpendlyDatabase
import kotlinx.coroutines.runBlocking
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import java.time.LocalDate
import java.time.YearMonth

/** Runs against a real Room database kept in memory. */
@RunWith(AndroidJUnit4::class)
class RoomExpenseRepositoryTest {
    private lateinit var database: SpendlyDatabase
    private lateinit var repository: RoomExpenseRepository

    @Before
    fun createDatabase() {
        val context = ApplicationProvider.getApplicationContext<Context>()
        database = Room.inMemoryDatabaseBuilder(context, SpendlyDatabase::class.java).build()
        repository = RoomExpenseRepository(database.expenseDao())
    }

    @After
    fun closeDatabase() = database.close()

    private fun expense(title: String, date: LocalDate, amount: Double = 10.0) =
        Expense(title = title, amount = amount, date = date, category = Category.FOOD)

    @Test
    fun fetchesOnlyTheExpensesOfTheMonth() = runBlocking {
        val first = expense("First day", LocalDate.of(2026, 11, 1))
        val last = expense("Last day", LocalDate.of(2026, 11, 30))
        repository.save(first)
        repository.save(last)
        repository.save(expense("October", LocalDate.of(2026, 10, 31)))
        repository.save(expense("December", LocalDate.of(2026, 12, 1)))

        val november = repository.fetchExpenses(YearMonth.of(2026, 11))

        assertEquals(listOf(first.title, last.title), november.map { it.title })
        assertEquals(first, november.first())
    }

    @Test
    fun savingAnExistingExpenseUpdatesIt() = runBlocking {
        val original = expense("Lunch", LocalDate.of(2026, 11, 5))
        repository.save(original)

        repository.save(original.copy(title = "Dinner", amount = 25.0, category = Category.RESTAURANT))

        val saved = repository.fetchExpenses(YearMonth.of(2026, 11)).single()
        assertEquals("Dinner", saved.title)
        assertEquals(25.0, saved.amount, 0.0)
        assertEquals(Category.RESTAURANT, saved.category)
    }

    @Test
    fun deletesOnlyTheGivenExpenses() = runBlocking {
        val lunch = expense("Lunch", LocalDate.of(2026, 11, 5))
        val dinner = expense("Dinner", LocalDate.of(2026, 11, 6))
        val gym = expense("Gym", LocalDate.of(2026, 11, 7))
        listOf(lunch, dinner, gym).forEach { repository.save(it) }

        repository.delete(listOf(lunch.id, dinner.id))

        assertEquals(listOf(gym), repository.fetchExpenses(YearMonth.of(2026, 11)))
        repository.delete(emptyList())
        assertTrue(repository.fetchExpenses(YearMonth.of(2026, 11)).isNotEmpty())
    }
}
