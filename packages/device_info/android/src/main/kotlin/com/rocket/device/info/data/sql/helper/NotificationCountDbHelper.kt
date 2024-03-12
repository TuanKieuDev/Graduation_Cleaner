package com.rocket.device.info.data.sql.helper

import android.content.ContentValues
import android.content.Context
import android.database.Cursor
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import android.service.notification.StatusBarNotification
import android.util.Log
import com.rocket.device.info.data.sql.config.NotificationCountDbConfig
import com.rocket.device.info.data.sql.entry.NotificationCountEntry

class NotificationCountDbHelper(context: Context) : SQLiteOpenHelper(context, NotificationCountDbConfig.DATABASE_NAME, null, NotificationCountDbConfig.DATABASE_VERSION)  {

    private val SQL_CREATE_ENTRIES =
        "CREATE TABLE " + NotificationCountEntry.TABLE_NAME + " (" +
                NotificationCountEntry.COLUMN_NAME_PACKAGE_NAME + " TEXT," +
                NotificationCountEntry.COLUMN_NAME_NOTIFICATION_ID + " INTEGER," +
                NotificationCountEntry.COLUMN_NAME_POST_TIME + " INTEGER)"

    override fun onCreate(db: SQLiteDatabase?) {
        db?.execSQL(SQL_CREATE_ENTRIES)
    }

    override fun onUpgrade(db: SQLiteDatabase?, oldVersion: Int, newVersion: Int) {
        //onCreate(db)
    }

    override fun onDowngrade(db: SQLiteDatabase?, oldVersion: Int, newVersion: Int) {
        onUpgrade(db, oldVersion, newVersion)
    }

    fun addNotificationInfo(sbn : StatusBarNotification) {

        val isNotificationAdded = checkNotificationAdded(sbn)
        if(isNotificationAdded){
            //Log.d("NotificationCount", "Notification was added database! ${sbn.packageName}")
            return
        }

        val db = this.writableDatabase
        val cv = ContentValues()

        cv.put(NotificationCountEntry.COLUMN_NAME_PACKAGE_NAME, sbn.packageName)
        cv.put(NotificationCountEntry.COLUMN_NAME_NOTIFICATION_ID, sbn.id)
        cv.put(NotificationCountEntry.COLUMN_NAME_POST_TIME, sbn.postTime)
        db.insert(NotificationCountEntry.TABLE_NAME, null, cv)

        db.close()
    }

    private fun checkNotificationAdded(sbn: StatusBarNotification) : Boolean{
        val db = this.readableDatabase

        val projection = arrayOf("*")

        val selection = "${NotificationCountEntry.COLUMN_NAME_PACKAGE_NAME} = ? " +
                "AND ${NotificationCountEntry.COLUMN_NAME_NOTIFICATION_ID} = ? " +
                "AND ${NotificationCountEntry.COLUMN_NAME_POST_TIME} = ?"
        val selectionArgs = arrayOf<String>(
            sbn.packageName,
            sbn.id.toString(),
            sbn.postTime.toString()
        )

        val cursor: Cursor = db.query(
            NotificationCountEntry.TABLE_NAME,
            projection,
            selection,
            selectionArgs,
            null,
            null,
            null
        )

        val exists: Boolean = cursor.count > 0

        cursor.close()
        db.close()

        return exists
    }

    fun countNotificationOfAllPackagesInRange(startTimeEpochMillis: Long, endTimeEpochMillis: Long): Map<String, Int> {
        val db = this.readableDatabase

        val query = "SELECT ${NotificationCountEntry.COLUMN_NAME_PACKAGE_NAME}, COUNT(${NotificationCountEntry.COLUMN_NAME_PACKAGE_NAME}) " +
                "FROM ${NotificationCountEntry.TABLE_NAME} " +
                "WHERE ${NotificationCountEntry.COLUMN_NAME_POST_TIME} > $startTimeEpochMillis " +
                "AND ${NotificationCountEntry.COLUMN_NAME_POST_TIME} < $endTimeEpochMillis " +
                "GROUP BY ${NotificationCountEntry.COLUMN_NAME_PACKAGE_NAME}"

        val cursor = db.rawQuery(query, null)
        val result = hashMapOf<String, Int>()
        while (cursor.moveToNext()){
            val packageName = cursor.getString(0)
            val count = cursor.getInt(1)
            result[packageName] = count
        }
        cursor.close()
        return result
    }

    fun countNotificationsInRange(packageName: String, startTimeEpochMillis: Long, endTimeEpochMillis: Long): Int{
        val db = this.readableDatabase

        val cursor = db.query(
            NotificationCountEntry.TABLE_NAME,
            arrayOf(NotificationCountEntry.COLUMN_NAME_PACKAGE_NAME),
            "${NotificationCountEntry.COLUMN_NAME_PACKAGE_NAME} == ? AND ${NotificationCountEntry.COLUMN_NAME_POST_TIME} > ? AND ${NotificationCountEntry.COLUMN_NAME_POST_TIME} < ?",
            arrayOf(
                packageName,
                startTimeEpochMillis.toString(),
                endTimeEpochMillis.toString()
            ),
            null,
            null,
            null
        )

        val count = cursor.count
        cursor.close()
        return count
    }
}