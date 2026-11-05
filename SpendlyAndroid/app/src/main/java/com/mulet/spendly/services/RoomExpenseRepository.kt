package com.mulet.spendly.services

import android.content.Context
import com.mulet.spendly.models.Category
import com.mulet.spendly.models.Expense
import com.mulet.spendly.services.database.ExpenseDao
import com.mulet.spendly.services.database.ExpenseEntity
import com.mulet.spendly.services.database.SpendlyDatabase
import java.time.Instant
import java.time.LocalDate
import java.time.YearMonth

class RoomExpenseRepository(private val dao: ExpenseDao) : ExpenseRepository {
    override suspend fun fetchExpenses(month: YearMonth): List<Expense> =
        dao.fetch(month.atDay(1).toEpochDay(), month.atEndOfMonth().toEpochDay()).map { it.toExpense() }

    override suspend fun save(expense: Expense) = dao.upsert(expense.toEntity())

    override suspend fun delete(ids: List<String>) = dao.delete(ids)

    companion object {
        fun from(context: Context) = RoomExpenseRepository(SpendlyDatabase.getInstance(context).expenseDao())
    }
}

private fun ExpenseEntity.toExpense() = Expense(
    id = id,
    title = title,
    amount = amount,
    date = LocalDate.ofEpochDay(epochDay),
    category = Category.valueOf(category),
    updatedAt = Instant.ofEpochMilli(updatedAt),
)

private fun Expense.toEntity() = ExpenseEntity(
    id = id,
    title = title,
    amount = amount,
    epochDay = date.toEpochDay(),
    category = category.name,
    updatedAt = updatedAt.toEpochMilli(),
)
