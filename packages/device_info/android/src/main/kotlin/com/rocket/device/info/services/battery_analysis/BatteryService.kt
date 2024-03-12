package com.rocket.device.info.services.battery_analysis

import android.app.Notification
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.util.Log
import com.rocket.device.info.notification.NotificationConstant
import com.rocket.device.info.notification.NotificationCreation
import com.rocket.device.info.services.getTimeRemainingForBatteryAnalysis
import com.rocket.device.info.settings.Permissions
import com.rocket.device.info.settings.worker.BatteryAnalysisWorker


class BatteryService : Service() {

    companion object {
        private var isRunning = false
        private var shouldRestartService = false
        private var wasRestartedService = false
    }

    private val batteryReceiver : BatteryReceiver = BatteryReceiver(this)

    override fun onBind(p0: Intent?): IBinder? {
        return null
    }

    override fun onCreate() {
        super.onCreate()
        batteryReceiver.registerReceiver()
    }

    override fun onDestroy() {
        super.onDestroy()
        batteryReceiver.unregisterReceiver()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {

        val notification: Notification = NotificationCreation.createBatteryAnalysisNotificationBuilder(this).build()

        startForeground(NotificationConstant.BATTERY_ANALYSIS_NOTIFICATION_ID , notification)

        return START_STICKY
    }

    object BatteryServiceController {

        private fun isBatteryServiceRunning(): Boolean {
            return BatteryService.isRunning
        }

        private fun setBatteryServiceRunning(isRunning: Boolean) {
            BatteryService.isRunning = isRunning
        }

        fun startService(context: Context): Boolean {

            val timeRemainingForAnalysis = context.getTimeRemainingForBatteryAnalysis()
            if(timeRemainingForAnalysis < 0 && !wasRestartedService){
                shouldRestartService = true
            }

            val isEnable = Permissions.isNotificationPermissionGranted(context)

            return if (isEnable) {
                if (isBatteryServiceRunning()) {
                    if(shouldRestartService){
                        //Log.d("BatteryAnalysis", "Restart battery service!")
                        stopService(context)
                        startService(context)
                        shouldRestartService = false
                        wasRestartedService = true
                    }
                } else {

                    //Log.d("BatteryAnalysis", "Start Battery Service!")

                    val intent = Intent(context, BatteryService::class.java)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        context.startForegroundService(intent)
                    }else{
                        context.startService(intent)
                    }

                    BatteryAnalysisWorker.startAnalysis(context)

                    setBatteryServiceRunning(true)
                }
                true
            } else if (isBatteryServiceRunning()) {
                stopService(context)
                false
            } else {
                false
            }
        }

        /* renamed from: ˏ */
        private fun stopService(context: Context) {
            context.stopService(
                Intent(
                    context,
                    BatteryService::class.java
                )
            )
            setBatteryServiceRunning(false)
        }
    }

}