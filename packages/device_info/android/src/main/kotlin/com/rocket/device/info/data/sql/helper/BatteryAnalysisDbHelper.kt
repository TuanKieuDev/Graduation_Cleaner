package com.rocket.device.info.data.sql.helper

import android.annotation.SuppressLint
import android.content.ContentValues
import android.content.Context
import android.database.Cursor
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import com.google.gson.Gson
import com.rocket.device.info.data.sql.config.BatteryAnalysisDbConfig
import com.rocket.device.info.data.sql.entry.BatteryAnalysisEntry

class BatteryAnalysisDbHelper(
    context: Context?
) : SQLiteOpenHelper(context, BatteryAnalysisDbConfig.DATABASE_NAME, null, BatteryAnalysisDbConfig.DATABASE_VERSION) {

    private val SQL_CREATE_ENTRIES =
        "CREATE TABLE " + BatteryAnalysisEntry.TABLE_NAME + " (" +
                BatteryAnalysisEntry.COLUMN_NAME_TIME_STAMP + " INTEGER," +
                BatteryAnalysisEntry.COLUMN_NAME_IS_CHARGING + " INTEGER," +
                BatteryAnalysisEntry.COLUMN_NAME_BATTERY_LEVEL + " REAL)"

    override fun onCreate(db: SQLiteDatabase?) {
        db?.execSQL(SQL_CREATE_ENTRIES)
    }

    override fun onUpgrade(p0: SQLiteDatabase?, p1: Int, p2: Int) {

    }

    fun insert( batteryLevel: Int, isCharging: Boolean ) {

        val db = writableDatabase

        val values = ContentValues()
        values.put(BatteryAnalysisEntry.COLUMN_NAME_BATTERY_LEVEL, batteryLevel)
        values.put(BatteryAnalysisEntry.COLUMN_NAME_TIME_STAMP, System.currentTimeMillis())
        values.put(BatteryAnalysisEntry.COLUMN_NAME_IS_CHARGING, if(isCharging) 1 else 0)

        db.insert(BatteryAnalysisEntry.TABLE_NAME, null, values)

        db.close()
    }

    fun deleteUnnecessaryData(){ // only keep in seven days
        val sevenDaysBefore = System.currentTimeMillis() - 7 * 24 * 3600 * 1000

        val db = writableDatabase

        val whereClause = BatteryAnalysisEntry.COLUMN_NAME_TIME_STAMP + " <= ?"
        val whereArgs = arrayOf(sevenDaysBefore.toString())

        db.delete(BatteryAnalysisEntry.TABLE_NAME, whereClause, whereArgs)
        db.close()
    }

    @SuppressLint("Range")
    fun getRowsByTimeAndSort(startTimeInEpoch: Long): List<BatteryAnalysisRowData> {

        val db = writableDatabase

        val projection = arrayOf("*")
        val selection = BatteryAnalysisEntry.COLUMN_NAME_TIME_STAMP + " >= ?"
        val selectionArgs = arrayOf(startTimeInEpoch.toString())
        val orderBy = BatteryAnalysisEntry.COLUMN_NAME_TIME_STAMP + " ASC"

        val cursor = db.query(
            BatteryAnalysisEntry.TABLE_NAME,
            projection,
            selection,
            selectionArgs,
            null,
            null,
            orderBy
        )

        var list = mutableListOf<BatteryAnalysisRowData>()

        while (cursor.moveToNext()){
            val batteryLevel = cursor.getDouble(cursor.getColumnIndex(BatteryAnalysisEntry.COLUMN_NAME_BATTERY_LEVEL))
            val timeStamp = cursor.getLong(cursor.getColumnIndex(BatteryAnalysisEntry.COLUMN_NAME_TIME_STAMP))
            val isCharging = cursor.getLong(cursor.getColumnIndex(BatteryAnalysisEntry.COLUMN_NAME_IS_CHARGING)) == 1L

            list.add(BatteryAnalysisRowData(timeStamp, batteryLevel, isCharging))
        }

        db.close()
        cursor.close()

        return list
    }

    @SuppressLint("Range")
    fun getBatteryAnalysisAllRowsForTest() : List<String> {
        val db = readableDatabase

        val projection = arrayOf(
            BatteryAnalysisEntry.COLUMN_NAME_TIME_STAMP,
            BatteryAnalysisEntry.COLUMN_NAME_BATTERY_LEVEL,
            BatteryAnalysisEntry.COLUMN_NAME_IS_CHARGING,
        )

        val cursor: Cursor = db.query(
            BatteryAnalysisEntry.TABLE_NAME,
            projection,
            null,
            null,
            null,
            null,
            null
        )

        val list = mutableListOf<String>()
        while (cursor.moveToNext()) {
            val rowData = BatteryAnalysisRowData(
                cursor.getLong(cursor.getColumnIndex(projection[0])),
                cursor.getDouble(cursor.getColumnIndex(projection[1])),
                cursor.getLong(cursor.getColumnIndex(projection[2])) == 1L
            )
            list.add(rowData.toString())
        }

        cursor.close()
        db.close()

        return list
    }

    class BatteryAnalysisRowData () {

        var timeStamp = 0L
        var batteryLevel = 0.0
        var isCharging = false

        constructor(timeStamp: Long, batteryLevel: Double, isCharging: Boolean) : this() {
            this.timeStamp = timeStamp
            this.batteryLevel = batteryLevel
            this.isCharging = isCharging
        }
        override fun toString(): String {
            return Gson().toJson(this)
        }
    }
}