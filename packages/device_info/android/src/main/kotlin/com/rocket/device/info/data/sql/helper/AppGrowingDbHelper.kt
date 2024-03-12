package com.rocket.device.info.data.sql.helper

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import com.rocket.device.info.data.sql.config.AppGrowingDbConfig
import com.rocket.device.info.data.sql.entry.AppGrowingEntry

class AppGrowingDbHelper(
    context: Context?
) : SQLiteOpenHelper(context, AppGrowingDbConfig.DATABASE_NAME, null, AppGrowingDbConfig.DATABASE_VERSION) {

    private val SQL_CREATE_ENTRIES =
        "CREATE TABLE " + AppGrowingEntry.TABLE_NAME + " (" +
                AppGrowingEntry.COLUMN_NAME_PACKAGE_NAME + " TEXT," +
                AppGrowingEntry.COLUMN_NAME_SIZE + " INTEGER," +
                AppGrowingEntry.COLUMN_NAME_DATE + " INTEGER)"

    override fun onCreate(db: SQLiteDatabase?) {
        db?.execSQL(SQL_CREATE_ENTRIES)
    }

    override fun onUpgrade(db: SQLiteDatabase?, oldVersion: Int, newVersion: Int) {
        //onCreate(db)
    }

    override fun onDowngrade(db: SQLiteDatabase?, oldVersion: Int, newVersion: Int) {
        onUpgrade(db, oldVersion, newVersion)
    }
}