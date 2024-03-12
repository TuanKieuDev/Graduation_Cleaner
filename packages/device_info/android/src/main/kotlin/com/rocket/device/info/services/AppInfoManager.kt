package com.rocket.device.info.services


import android.content.pm.ApplicationInfo



class AppInfoManager {

    //    private fun lastOpened(context: Context, packageName: String) : Map<String, Long> {
//        var lastOpened = 0L
//        var totalTimeSpent = 0L
//
//        for(usageAppInfo in appInfoUsageManager.getUsageLast7Days(context)) {
//            if(usageAppInfo.packageName != packageName) continue
//            lastOpened = usageAppInfo.lastOpened
//            totalTimeSpent = usageAppInfo.totalTimeSpent
//        }
//
//        return mapOf(
//            "lastOpened" to lastOpened,
//            "totalTimeSpent" to totalTimeSpent,
//        )
//    }

    //    fun openAppInfoInSetting() {
//
//    }
//
//    fun openApp() {
//
//    }
//
//    fun uninstall() {
//
//    }
//
//    fun forceStop() {
//
//    }

    companion object {
        private const val TAG = "AppInfoManager"
        var cacheListAppInfo : List<ApplicationInfo>? = null
    }
}