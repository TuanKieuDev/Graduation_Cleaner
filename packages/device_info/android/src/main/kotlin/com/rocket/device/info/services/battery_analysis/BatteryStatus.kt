package com.rocket.device.info.services.battery_analysis

import android.content.Context
import android.content.Context.BATTERY_SERVICE
import android.content.Intent
import android.os.BatteryManager
import android.os.Build
import com.rocket.device.info.core.StorageConstant
import com.rocket.device.info.data.LocalStorage


object BatteryStatus {

    fun getBatteryPercentage(context: Context): Int {
        val bm = context.getSystemService(BATTERY_SERVICE) as BatteryManager

        return bm.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
    }

    fun isCharging(context: Context) : Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val batteryManager = context.getSystemService(BATTERY_SERVICE) as BatteryManager
            return batteryManager.isCharging
        }

        return LocalStorage.readBooleanData(context, StorageConstant.BundleName.BATTERY_STATUS, StorageConstant.Key.BATTERY_STATUS)
    }
}