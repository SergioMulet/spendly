package com.mulet.spendly.services.database

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase

@Database(entities = [ExpenseEntity::class], version = 1, exportSchema = false)
abstract class SpendlyDatabase : RoomDatabase() {
    abstract fun expenseDao(): ExpenseDao

    companion object {
        @Volatile
        private var shared: SpendlyDatabase? = null

        fun getInstance(context: Context): SpendlyDatabase =
            shared ?: synchronized(this) {
                shared ?: Room.databaseBuilder(context.applicationContext, SpendlyDatabase::class.java, "spendly.db")
                    .build()
                    .also { shared = it }
            }
    }
}
