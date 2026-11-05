package com.mulet.spendly.models

import java.time.Instant
import java.time.LocalDate
import java.util.UUID

data class Expense(
    val id: String = UUID.randomUUID().toString(),
    val title: String,
    val amount: Double,
    val date: LocalDate,
    val category: Category,
    val updatedAt: Instant = Instant.now(),
)

/** The expenses of one category in a month. */
data class ExpenseGroup(val category: Category, val expenses: List<Expense>) {
    val id: Category get() = category
    val total: Double get() = expenses.sumOf { it.amount }
}
