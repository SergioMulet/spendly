package com.mulet.spendly.services.database

import androidx.room.Dao
import androidx.room.Query
import androidx.room.Upsert

@Dao
interface ExpenseDao {
    @Query("SELECT * FROM expenses WHERE epochDay BETWEEN :firstDay AND :lastDay ORDER BY epochDay, updatedAt")
    suspend fun fetch(firstDay: Long, lastDay: Long): List<ExpenseEntity>

    @Upsert
    suspend fun upsert(expense: ExpenseEntity)

    @Query("DELETE FROM expenses WHERE id IN (:ids)")
    suspend fun delete(ids: List<String>)
}
