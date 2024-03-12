package com.rocket.device.info.settings.worker

import android.content.ContentValues
import android.content.Context
import android.os.Build
import android.util.Log
import androidx.work.*
import com.rocket.device.info.data.sql.entry.AppGrowingEntry
import com.rocket.device.info.data.sql.helper.AppGrowingDbHelper
import com.rocket.device.info.services.getAppSize
import com.rocket.device.info.services.getInstalledApplications
import com.rocket.device.info.services.runAppGrowingService
import com.rocket.device.info.settings.Permissions
import java.util.*
import java.util.concurrent.TimeUnit

class AppGrowingWorker(appContext: Context, workerParams: WorkerParameters):
    Worker(appContext, workerParams) {
    override fun doWork(): Result {
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && !Permissions.isUsageAccessGranted(applicationContext)){
            return Result.failure()
        }

        val apps : List<String> = applicationContext.getInstalledApplications().map {
            it.packageName
        }

        val dbHelper = AppGrowingDbHelper(applicationContext)
        val db = dbHelper.writableDatabase

        val currentTimestamp = Date().time
        val sevenDaysBeforeTimestamp = currentTimestamp - 7 * 24 * 60 * 60 * 1000
        for (packageName in apps){
            if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
                val totalSize = applicationContext.getAppSize(packageName, null, null).getTotalSize();

                val values = ContentValues()
                values.put(AppGrowingEntry.COLUMN_NAME_PACKAGE_NAME, packageName)
                values.put(AppGrowingEntry.COLUMN_NAME_SIZE, totalSize)
                values.put(AppGrowingEntry.COLUMN_NAME_DATE, currentTimestamp)

                db.insert(AppGrowingEntry.TABLE_NAME, null, values)
            } else {
                applicationContext.getAppSize(packageName, null){
                    val totalSize = it.getTotalSize()

                    val values = ContentValues()
                    values.put(AppGrowingEntry.COLUMN_NAME_PACKAGE_NAME, packageName)
                    values.put(AppGrowingEntry.COLUMN_NAME_SIZE, totalSize)
                    values.put(AppGrowingEntry.COLUMN_NAME_DATE, currentTimestamp)

                    db.insert(AppGrowingEntry.TABLE_NAME, null, values)
                }
            }
        }

        val deleteQuery =
            "DELETE FROM " + AppGrowingEntry.TABLE_NAME + " WHERE " + AppGrowingEntry.COLUMN_NAME_DATE + " <= " + sevenDaysBeforeTimestamp
        db.execSQL(deleteQuery)

        return Result.success()
    }

    companion object {
        fun startAnalysis(context: Context){

            val request = PeriodicWorkRequestBuilder<AppGrowingWorker>(12, TimeUnit.HOURS, 2, TimeUnit.HOURS)
                .setInitialDelay(0, TimeUnit.MILLISECONDS)
                .build()

            WorkManager.getInstance(context)
                .enqueueUniquePeriodicWork(
                    "app_growing_detection",
                    ExistingPeriodicWorkPolicy.KEEP,
                    request
                )
        }
    }
}