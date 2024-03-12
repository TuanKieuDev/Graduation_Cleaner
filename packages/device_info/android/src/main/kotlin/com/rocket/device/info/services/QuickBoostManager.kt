package com.rocket.device.info.services

import android.app.ActivityManager
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Context.ACTIVITY_SERVICE
import android.content.pm.ApplicationInfo
import android.os.Build
import com.rocket.device.info.models.QuickBoost
import java.util.*


class QuickBoostManager {
    private fun getMemoryInfo(context: Context): Long {
        context.applicationContext.let {
            val actManager: ActivityManager =
                    it.getSystemService(ACTIVITY_SERVICE) as ActivityManager
            val memInfo = ActivityManager.MemoryInfo()
            actManager.getMemoryInfo(memInfo)

            return memInfo.availMem
        }
    }

    fun getUnnecessaryData(context: Context): Long {
        val sharedPreference = context.applicationContext.getSharedPreferences(
                "APP_MEMORY_PREFS", Context.MODE_PRIVATE
        )
        var beforeMem = sharedPreference.getLong("currentFreeMemory", 0L)
        val currentMem = getMemoryInfo(context);
        if (beforeMem == 0L) {
            sharedPreference.edit().putLong(
                    "currentFreeMemory", (currentMem)
            ).apply()
            beforeMem = currentMem
        }
        return if (currentMem - beforeMem > 0) currentMem - beforeMem else 0L
    }


    fun deleteRam(context: Context): QuickBoost {
        // Call the function 'getFreeMem' before killing any processes
        val beforeRam = getMemoryInfo(context) ?: 0L
        killBackgroundProcesses(context)
        // Call the function 'getFreeMem' after killing any processes
        val afterRam = getMemoryInfo(context) ?: 0L

        val sharedPreference = context.applicationContext.getSharedPreferences(
                "APP_MEMORY_PREFS", Context.MODE_PRIVATE
        )

        sharedPreference.edit().putLong(
                "currentFreeMemory", (afterRam ?: 0L)
        ).apply()

        val ramOptimized = if (afterRam - beforeRam > 0) afterRam - beforeRam else 0L

        return QuickBoost(
                beforeRam,
                afterRam,
                ramOptimized
        )
    }

    private fun killBackgroundProcesses(context: Context) {
        val packages: List<ApplicationInfo> = context.packageManager.getInstalledApplications(0)
        val mActivityManager = context.getSystemService(ACTIVITY_SERVICE) as ActivityManager
        for (packageInfo in packages) {
            if (packageInfo.packageName.equals(context.applicationContext.packageName)) continue
            mActivityManager.killBackgroundProcesses(packageInfo.packageName)
        }
    }

    private fun getUsageStatsList(context: Context): List<UsageStats> {
        val usm = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
            context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        } else {
            TODO("VERSION.SDK_INT < LOLLIPOP_MR1")
        }
        val calendar: Calendar = Calendar.getInstance()
        val endTime: Long = calendar.timeInMillis
        calendar.add(Calendar.DATE, -1)
        val startTime: Long = calendar.timeInMillis

        return usm.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, startTime, endTime)
    }

    private fun isSTOPPED(pkgInfo: ApplicationInfo): Boolean {
        return pkgInfo.flags and ApplicationInfo.FLAG_STOPPED != 0
    }

    private fun isSYSTEM(pkgInfo: ApplicationInfo): Boolean {
        return pkgInfo.flags and ApplicationInfo.FLAG_SYSTEM != 0
    }
}