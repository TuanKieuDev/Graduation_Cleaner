package com.rocket.device.info.settings

import android.Manifest
import android.annotation.SuppressLint
import android.app.AppOpsManager
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.Environment
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationManagerCompat

object Permissions {

    fun isStoragePermissionGranted(context: Context) : Boolean{
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.R){
            return isAccessAllFilesPermissionGranted()
        }
        return isExternalStoragePermissionGranted(context)
    }

    @RequiresApi(Build.VERSION_CODES.R)
    fun isAccessAllFilesPermissionGranted() : Boolean{
        return Environment.isExternalStorageManager()
    }
    @SuppressLint("NewApi")
    fun isExternalStoragePermissionGranted(context: Context) : Boolean{
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU){
            return context.checkSelfPermission(Manifest.permission.READ_MEDIA_IMAGES) == PackageManager.PERMISSION_GRANTED
        }
        return context.checkSelfPermission(Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED
    }

    fun isUsageAccessGranted(context: Context): Boolean {
        return try {
            val packageManager: PackageManager = context.packageManager
            val applicationInfo = packageManager.getApplicationInfo(context.packageName, 0)
            val appOpsManager = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
            var mode = 0
            if (Build.VERSION.SDK_INT > Build.VERSION_CODES.KITKAT) {
                mode = appOpsManager.checkOpNoThrow(
                    AppOpsManager.OPSTR_GET_USAGE_STATS,
                    applicationInfo.uid, applicationInfo.packageName
                )
            }
            mode == AppOpsManager.MODE_ALLOWED
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }

    fun isNotificationPermissionGranted(context: Context): Boolean {
        return NotificationManagerCompat.from(context).areNotificationsEnabled()
    }
}