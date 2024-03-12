package com.rocket.device.info.services

import android.app.ActivityManager
import android.content.Context
import android.content.Context.ACTIVITY_SERVICE
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Environment
import android.os.StatFs
import com.rocket.device.info.models.GeneralInfo
import java.io.File


class GeneralInfoManager {

    private fun getBatteryInfo(context: Context): Int {
        val iFilter = IntentFilter(Intent.ACTION_BATTERY_CHANGED)
        val batteryStatus: Intent? = context.registerReceiver(null, iFilter)
        val level = batteryStatus?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
        val scale = batteryStatus?.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
        val batteryPct = level?.div(scale?.toFloat()!!)

        // About Battery
        val battery: Float = batteryPct!! * 100

        return battery.toInt()
    }

    private fun getMemInfo(context: Context): Map<String, Long> {
        context.applicationContext.let {
            val actManager: ActivityManager =
                it.getSystemService(ACTIVITY_SERVICE) as ActivityManager
            val memInfo = ActivityManager.MemoryInfo()
            actManager.getMemoryInfo(memInfo)
            val totalMem: Long = memInfo.totalMem
            val freeMem: Long = memInfo.availMem
            val runtime = Runtime.getRuntime()
            val usedByApp: Long = (runtime.totalMemory() - runtime.freeMemory())
            return mapOf(
                "usedByApp" to usedByApp,
                "totalMem" to totalMem,
                "freeMem" to freeMem,
            )
        }
    }


    fun generalInfo(context: Context): GeneralInfo {
        val size = File("/data").totalSpace
        val sizeSystem = File("/system").totalSpace
        val sizeDev = File("/dev").totalSpace
        val sizeCache = File("/cache").totalSpace
        val sizeMnt = File("/mnt").totalSpace
        val sizeVendor = File("/vendor").totalSpace
        val sizeMedia1 = File("/storage").totalSpace
        val apex = File("/apex").totalSpace
        val others = File("/special_preload").totalSpace

        var totalSize = size + sizeSystem + sizeDev + sizeCache + sizeMnt + sizeVendor + sizeMedia1
        +apex + others

        val internalStatFs = StatFs(Environment.getRootDirectory().absolutePath)

        val externalStatFs = StatFs(Environment.getExternalStorageDirectory().absolutePath)

        val internalFree: Long = internalStatFs.availableBlocksLong * internalStatFs.blockSizeLong
        val externalFree: Long = externalStatFs.availableBlocksLong * externalStatFs.blockSizeLong

        val free = internalFree + externalFree
        val used = totalSize - free


        val actManager = context.getSystemService(ACTIVITY_SERVICE) as ActivityManager?
        val memInfo = ActivityManager.MemoryInfo()
        actManager!!.getMemoryInfo(memInfo)
        val totalMemory: Long = memInfo.totalMem
        val freeMemory: Long = memInfo.availMem
        val usedMemory: Long = totalMemory - freeMemory

        return GeneralInfo(
            mapOf<String, Any>(
                "usedSpace" to used,
                "totalSpace" to totalSize,
                "usedMemory" to usedMemory,
                "totalMemory" to totalMemory,
                "freeMemory" to freeMemory,
                "battery" to getBatteryInfo(context)
            )
        )
    }
}