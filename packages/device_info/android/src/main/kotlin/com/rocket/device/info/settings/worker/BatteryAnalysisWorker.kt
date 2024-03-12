package com.rocket.device.info.settings.worker

import android.content.Context
import androidx.work.*
import com.rocket.device.info.data.sql.helper.BatteryAnalysisDbHelper
import com.rocket.device.info.services.battery_analysis.BatteryStatus
import java.util.concurrent.TimeUnit

class BatteryAnalysisWorker(appContext: Context, workerParams: WorkerParameters) : Worker(appContext, workerParams) {

    override fun doWork(): Result {

        val batteryLevel = BatteryStatus.getBatteryPercentage(applicationContext)
        val isCharging = BatteryStatus.isCharging(applicationContext)

        val dbHelper = BatteryAnalysisDbHelper(applicationContext)

        dbHelper.insert(batteryLevel, isCharging)

        dbHelper.deleteUnnecessaryData()

        dbHelper.close()

        return Result.success()
    }

    companion object {
        fun startAnalysis(context: Context){

            val request = PeriodicWorkRequestBuilder<BatteryAnalysisWorker>(15, TimeUnit.MINUTES, 5, TimeUnit.MINUTES)
                .setInitialDelay(0, TimeUnit.MILLISECONDS)
                .build()

            WorkManager.getInstance(context)
                .enqueueUniquePeriodicWork(
                    "battery_analysis",
                    ExistingPeriodicWorkPolicy.KEEP,
                    request
                )
        }
    }
}