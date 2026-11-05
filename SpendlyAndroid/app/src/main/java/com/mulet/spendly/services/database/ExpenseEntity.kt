package com.mulet.spendly.services.database

import androidx.room.Entity
import androidx.room.PrimaryKey

/** How an expense is stored. It never leaves the persistence layer: the rest of the app uses [com.mulet.spendly.models.Expense]. */
@Entity(tableName = "expenses")
data class ExpenseEntity(
    @PrimaryKey val id: String,
    val title: String,
    val amount: Double,
    /** [java.time.LocalDate.toEpochDay] */
    val epochDay: Long,
    /** [com.mulet.spendly.models.Category.name] */
    val category: String,
    /** [java.time.Instant.toEpochMilli] */
    val updatedAt: Long,
)
