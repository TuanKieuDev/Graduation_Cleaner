package com.rocket.device.info.services

import android.annotation.SuppressLint
import android.app.AppOpsManager
import android.app.usage.StorageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.IPackageStatsObserver
import android.content.pm.PackageManager
import android.content.pm.PackageStats
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.RemoteException
import android.provider.Settings
import android.util.Log
import com.rocket.device.info.AppManagerChannel
import com.rocket.device.info.exception.PermissionException
import com.rocket.device.info.models.AppInfoSize
import com.rocket.device.info.settings.Permissions
import serializeToMap
import java.lang.reflect.InvocationTargetException
import java.lang.reflect.Method


class AppInfoSizeManager {

    fun getAppInfoSize(context: Context, packageName: String, methodChannel: AppManagerChannel?, callBack: ((AppInfoSize) -> Unit)?) : AppInfoSize {
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            if (!Permissions.isUsageAccessGranted(context)) {
                throw PermissionException("Error: Usage Access permission is required")
            }

            val storageStatsManager =
                context.getSystemService(Context.STORAGE_STATS_SERVICE) as StorageStatsManager
            try {
                val ai = context.packageManager.getApplicationInfo(packageName, 0)
                val storageStats =
                    storageStatsManager.queryStatsForUid(ai.storageUuid, ai.uid)
                return AppInfoSize(
                    packageName,
                    storageStats.appBytes,
                    storageStats.dataBytes,
                    storageStats.cacheBytes
                )
            } catch (e: Exception) {
            }
        } else {
            val pm: PackageManager = context.packageManager
            var getPackageSizeInfo: Method? = null
            try {
                getPackageSizeInfo = pm.javaClass.getMethod(
                    "getPackageSizeInfo", String::class.java, IPackageStatsObserver::class.java
                )
            } catch (e: NoSuchMethodException) {
                e.printStackTrace()
            }
            try {
                getPackageSizeInfo!!.invoke(pm, packageName,
                    object : IPackageStatsObserver.Stub() {
                        @Throws(RemoteException::class)
                        override fun onGetStatsCompleted(pStats: PackageStats, succeeded: Boolean) {
                            Handler(Looper.getMainLooper()).post(Runnable {
                                val appInfoSize = AppInfoSize(packageName, pStats.codeSize, pStats.dataSize, pStats.cacheSize)
                                if(methodChannel != null){
                                    methodChannel.invokeMethod("returnAppCapacity", appInfoSize.toMap())
                                } else if(callBack != null){
                                    callBack.invoke(appInfoSize)
                                }
                            })
                        }
                    })

            } catch (e: IllegalAccessException) {
                e.printStackTrace()
            } catch (e: InvocationTargetException) {
                e.printStackTrace()
            }
        }
        return AppInfoSize(packageName, 0, 0, 0)
    }
}
