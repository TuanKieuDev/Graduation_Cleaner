package com.rocket.device.info.services.battery_analysis

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import com.rocket.device.info.core.StorageConstant
import com.rocket.device.info.data.LocalStorage
import com.rocket.device.info.data.sql.helper.BatteryAnalysisDbHelper


class BatteryReceiver : BroadcastReceiver {

    private var context : Context
    private var intentFilter: IntentFilter
    private var isRunning = false

    constructor(context: Context){
        this.context = context

        val intentFilter = IntentFilter()
        intentFilter.addAction(Intent.ACTION_POWER_CONNECTED)
        intentFilter.addAction(Intent.ACTION_POWER_DISCONNECTED)

        this.intentFilter = intentFilter
    }

    override fun onReceive(context: Context, intent: Intent) {

        if( isOrderedBroadcast ) {
            return
        }

        var isCharging = false

        when(intent.action){
            Intent.ACTION_POWER_DISCONNECTED -> {
                isCharging = false
            }
            Intent.ACTION_POWER_CONNECTED -> {
                isCharging = true
            }
        }

        val batteryLevel = BatteryStatus.getBatteryPercentage(context)

        val dbHelper = BatteryAnalysisDbHelper(context)

        dbHelper.insert(batteryLevel, isCharging)

        dbHelper.close()

        saveBatteryStatusToLocalStorage(context, isCharging)
    }

    private fun saveBatteryStatusToLocalStorage(context: Context, isCharging : Boolean){
        LocalStorage.writeBooleanData(context, StorageConstant.BundleName.BATTERY_STATUS, StorageConstant.Key.BATTERY_STATUS, isCharging)
    }

    fun registerReceiver() {
        if (!this.isRunning) {
            context.registerReceiver(this, this.intentFilter)
            this.isRunning = true
        }
    }

    fun unregisterReceiver() {
        if (this.isRunning) {
            context.unregisterReceiver(this)
            this.isRunning = false
        }
    }

}