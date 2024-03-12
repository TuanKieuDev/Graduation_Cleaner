package com.rocket.device.info.services

import android.annotation.SuppressLint
import android.app.Activity
import android.app.usage.*
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.net.NetworkCapabilities
import android.net.Uri
import android.os.Build
import android.os.UserHandle
import androidx.core.app.ActivityCompat.startActivityForResult
import androidx.work.*
import com.app.cleaner.device.info.library.models.UsageStats
import com.rocket.device.info.AppManagerChannel
import com.rocket.device.info.core.StorageConstant
import com.rocket.device.info.data.LocalStorage
import com.rocket.device.info.data.sql.entry.AppGrowingEntry
import com.rocket.device.info.data.sql.helper.AppGrowingDbHelper
import com.rocket.device.info.data.sql.helper.NotificationCountDbHelper
import com.rocket.device.info.exception.DeviceInfoException
import com.rocket.device.info.exception.InvalidApkException
import com.rocket.device.info.models.AppInfoSize
import com.rocket.device.info.models.AppType
import com.rocket.device.info.models.PackageInfo
import com.rocket.device.info.services.battery_analysis.BatteryAnalysisHandler
import com.rocket.device.info.services.battery_analysis.BatteryService
import com.rocket.device.info.settings.broadcast_receiver.PackageRemovedReceiver
import com.rocket.device.info.settings.isSystem
import com.rocket.device.info.settings.toBitmap
import com.rocket.device.info.settings.worker.AppGrowingWorker
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.util.*
import kotlin.math.max


const val packageUninstallRequestCode = 244;
private var applicationsInfo: List<ApplicationInfo> = listOf()

fun PackageManager.getApplicationInfoCompat(packageName: String, flags: Int = 0): ApplicationInfo =
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
        getApplicationInfo(packageName, PackageManager.ApplicationInfoFlags.of(flags.toLong()))
    } else {
        @Suppress("DEPRECATION") getApplicationInfo(packageName, flags)
    }

fun Context.getInstalledApplications(): List<PackageInfo> {
    val pm = this.packageManager
    applicationsInfo = getApplicationsInfo()

    val convertedPackageInfo = mutableListOf<PackageInfo>()

    for (packageInfo in applicationsInfo) {
        if (pm.getLaunchIntentForPackage(packageInfo.packageName) == null) continue

        val appType = if (packageInfo.isSystem()) {
            AppType.System
        } else {
            AppType.Installed
        }

        val category = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            packageInfo.category
        } else {
            -1
        }

        val storageUuid = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            packageInfo.storageUuid.toString()
        } else {
            null
        }

        var info =  PackageInfo(
            packageInfo.packageName,
            appType.toString(),
            packageInfo.flags,
            category,
            packageInfo.permission,
            storageUuid,
            packageInfo.uid
        )


        convertedPackageInfo.add(info)
    }

    return convertedPackageInfo
}

fun Context.isInstalledApplication(packageName: String) : Boolean {
    val pm = this.packageManager
    applicationsInfo = getApplicationsInfo()

    return applicationsInfo.any {
        it.packageName == packageName
                && pm.getLaunchIntentForPackage(it.packageName) != null
                && it.packageName != this.packageName
    }
}

private fun Context.getApplicationsInfo() : List<ApplicationInfo> {

    if(applicationsInfo.isNotEmpty()){
        return applicationsInfo
    }

    val pm = this.packageManager
    applicationsInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
        pm.getInstalledApplications(PackageManager.ApplicationInfoFlags.of(PackageManager.GET_META_DATA.toLong()))
    } else {
        @Suppress("DEPRECATION")
        pm.getInstalledApplications(PackageManager.GET_META_DATA)
    }

    val appPackageName = this.packageName

    return applicationsInfo.filter {
        it.packageName != appPackageName
    }
}

fun Context.getApplicationLabel(packageName: String): CharSequence {
    val ai = packageManager.getApplicationInfoCompat(packageName)
    return packageManager.getApplicationLabel(ai)
}

fun Context.getApplicationType(packageName: String): AppType {
    val ai = packageManager.getApplicationInfoCompat(packageName)
    return if (ai.isSystem())  AppType.System else AppType.Installed
}

fun Context.getAppIconBitmap(packageName: String): Bitmap {
    return this.packageManager.getApplicationIcon(packageName).toBitmap()
}

fun Context.countNotificationsInRange(packageName: String, startTimeEpochMillis: Long, endTimeEpochMillis : Long): Int {
    val databaseHandler = NotificationCountDbHelper(this)
    val count = databaseHandler.countNotificationsInRange(packageName, startTimeEpochMillis, endTimeEpochMillis)
    databaseHandler.close()

    return count
}

fun Context.countNotificationOfAllPackagesInRange(startTimeEpochMillis: Long, endTimeEpochMillis : Long): Map<String, Int> {
    val databaseHandler = NotificationCountDbHelper(this)
    val count = databaseHandler.countNotificationOfAllPackagesInRange(startTimeEpochMillis, endTimeEpochMillis)
    databaseHandler.close()

    return count
}

fun Context.getApplicationUsage(packageName: String): Long {
    val networkStatsManager: NetworkStatsManager =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            this.getSystemService(Context.NETWORK_STATS_SERVICE) as NetworkStatsManager
        } else {
            TODO("VERSION.SDK_INT < M")
        }

    val pm: PackageManager = this.packageManager
    val info: ApplicationInfo =
        pm.getApplicationInfoCompat(packageName, PackageManager.GET_META_DATA)
    val uid = info.uid


    val queryNetWorks: NetworkStats = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
        networkStatsManager.queryDetailsForUid(
            NetworkCapabilities.TRANSPORT_CELLULAR,
            null,
            0,
            System.currentTimeMillis(),
            uid
        )
    } else {
        TODO("VERSION.SDK_INT < M")
    }

    var rxBytes = 0L
    var txBytes = 0L
    val bucket = NetworkStats.Bucket()

    while (queryNetWorks.hasNextBucket()) {
        queryNetWorks.getNextBucket(bucket)
        rxBytes += bucket.rxBytes
        txBytes += bucket.txBytes
    }

    return rxBytes + txBytes
}

fun Context.getStorageStatistics(
    packageName: String,
    storageUUID: UUID,
    uid: Int
): com.app.cleaner.device.info.library.models.StorageStats {
    val storageStatsManager = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        this.getSystemService(Context.STORAGE_STATS_SERVICE) as StorageStatsManager
    } else {
        TODO("${Build.VERSION.SDK_INT} < ${Build.VERSION_CODES.O}")
    }

    val user = UserHandle.getUserHandleForUid(uid)

    val storageStats =
        storageStatsManager.queryStatsForPackage(
            storageUUID,
            packageName,
            user
        )

    val externalCacheBytes = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        storageStats.externalCacheBytes
    } else {
        null
    }

    return com.app.cleaner.device.info.library.models.StorageStats(
        packageName,
        storageStats.appBytes,
        storageStats.dataBytes,
        storageStats.cacheBytes,
        externalCacheBytes,
    )
}

@SuppressLint("WrongConstant")
fun Context.getAppUsage(startEpochMillis: Long, endEpochMillis: Long): Map<String, UsageStats> {
    // TODO: Definitely wrong, use another method later
    val usm = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
        this.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
    } else {
        this.getSystemService("usagestats") as UsageStatsManager
    }
    val usageStats =
        usm.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, startEpochMillis, endEpochMillis)

    val result = hashMapOf<String, UsageStats>()
    val pm = this.packageManager

    for (usageStat in usageStats) {
        val packageName = usageStat.packageName

        if (pm.getLaunchIntentForPackage(packageName) == null) continue

        var lastEpochTimeForegroundServiceUsed =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                usageStat.lastTimeForegroundServiceUsed
            } else {
                null
            }

        var totalMillisecondsVisible = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            usageStat.totalTimeVisible
        } else {
            null
        }

        if (!result.containsKey(packageName)) {
            result[packageName] = UsageStats(
                usageStat.packageName,
                usageStat.lastTimeUsed,
                lastEpochTimeForegroundServiceUsed,
                usageStat.totalTimeInForeground,
                totalMillisecondsVisible,
            )
        } else {
            val currentStat = result[packageName]!!
            lastEpochTimeForegroundServiceUsed = if (lastEpochTimeForegroundServiceUsed != null) {
                max(
                    currentStat.lastEpochTimeForegroundServiceUsed!!,
                    lastEpochTimeForegroundServiceUsed
                )
            } else {
                null
            }
            totalMillisecondsVisible = if (totalMillisecondsVisible != null) {
                currentStat.totalMillisecondsVisible!! +
                        totalMillisecondsVisible
            } else {
                null
            }
            result[packageName] = UsageStats(
                usageStat.packageName,
                max(currentStat.lastUsedEpochTime, usageStat.lastTimeUsed),
                lastEpochTimeForegroundServiceUsed,
                currentStat.totalMillisecondsInForeground + usageStat.totalTimeInForeground,
                totalMillisecondsVisible
            )
        }
    }

    return result
}

private var totalTime = 0L

fun Context.getUsageDataApps(packageName: String): Long {

    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
        throw DeviceInfoException("Your device isn't supported for Usage Data App getting feature")
    }

    val networkStatsManager: NetworkStatsManager =
        getSystemService(Context.NETWORK_STATS_SERVICE) as NetworkStatsManager

    val info: ApplicationInfo =
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU)
            packageManager.getApplicationInfo(packageName, PackageManager.ApplicationInfoFlags.of(0))
        else
            packageManager.getApplicationInfo(packageName, PackageManager.GET_META_DATA)

    val uid = info.uid

    val startTime = Calendar.getInstance().timeInMillis - 7 * 24 * 3600 * 1000
    val endTime = Calendar.getInstance().timeInMillis

    val queryNetWorks1: NetworkStats = networkStatsManager.queryDetailsForUid(
        NetworkCapabilities.TRANSPORT_WIFI,
        null,
        startTime,
        endTime,
        uid
    )

    val queryNetWorks2: NetworkStats = networkStatsManager.queryDetailsForUid(
        NetworkCapabilities.TRANSPORT_CELLULAR,
        null,
        startTime,
        endTime,
        uid
    )

    var totalDataUsed = 0L

    while (queryNetWorks1.hasNextBucket()) {
        val bucket = NetworkStats.Bucket()
        queryNetWorks1.getNextBucket(bucket)
        totalDataUsed += bucket.rxBytes
        totalDataUsed += bucket.txBytes
    }

    while (queryNetWorks2.hasNextBucket()) {
        val bucket = NetworkStats.Bucket()
        queryNetWorks2.getNextBucket(bucket)
        totalDataUsed += bucket.rxBytes
        totalDataUsed += bucket.txBytes
    }

    return totalDataUsed
}

fun Context.getAppSize(
    packageName: String,
    methodChannel: AppManagerChannel?,
    callBack: ((AppInfoSize) -> Unit)?
): AppInfoSize {
    val appSizeManager = AppInfoSizeManager()
    return appSizeManager.getAppInfoSize(this, packageName, methodChannel, callBack)
}

fun Context.runAppGrowingService() {
    AppGrowingWorker.startAnalysis(applicationContext)
}

//fun Context.getAllRows() : String{
//    val dbHelper = AppGrowingDbHelper(applicationContext)
//    val db = dbHelper.writableDatabase
//    val selectQuery = "SELECT * FROM " + AppGrowingEntry.TABLE_NAME +
//            " ORDER BY " + AppGrowingEntry.COLUMN_NAME_SIZE + " ASC"
//
//    val cursor = db.rawQuery(selectQuery, null)
//    // get min of list data
//    var content = ""
//    while (cursor.moveToNext()){
//        val packageName = cursor.getString(cursor.getColumnIndexOrThrow(AppGrowingEntry.COLUMN_NAME_PACKAGE_NAME))
//        val size = cursor.getLong(cursor.getColumnIndexOrThrow(AppGrowingEntry.COLUMN_NAME_SIZE))
//        val date = cursor.getLong(cursor.getColumnIndexOrThrow(AppGrowingEntry.COLUMN_NAME_DATE))
//        content += ("$packageName --- $size --- $date --- \n")
//    }
//    return content
//}
fun Context.getTimeRemainingForAppGrowingAnalysis(): Long {

    val waitingTime = 2 * 24 * 3600 * 1000L // 2 days

    val timeEnd = LocalStorage.readLongData(
        applicationContext,
        StorageConstant.BundleName.TIME_REMAINING_FOR_APP_GROWING,
        StorageConstant.Key.TIME_REMAINING_FOR_APP_GROWING,
    )
    if (timeEnd < 0) {

        LocalStorage.writeLongData(
            applicationContext,
            StorageConstant.BundleName.TIME_REMAINING_FOR_APP_GROWING,
            StorageConstant.Key.TIME_REMAINING_FOR_APP_GROWING,
            System.currentTimeMillis() + waitingTime
        )

        return waitingTime
    } else {
        return timeEnd - System.currentTimeMillis()
    }
}

fun Context.getAppSizeGrowingInByte(
    packageName: String,
    inDays: Int,
    methodChannel: AppManagerChannel
): Long {
    val timestamp = Date().time - inDays * 24 * 60 * 60 * 1000

    val dbHelper = AppGrowingDbHelper(applicationContext)
    val db = dbHelper.writableDatabase

    val selectQuery =
            "SELECT " + AppGrowingEntry.COLUMN_NAME_SIZE +
            " FROM " + AppGrowingEntry.TABLE_NAME +
            " WHERE " + AppGrowingEntry.COLUMN_NAME_PACKAGE_NAME + " = " + "'" + packageName + "'" +
            " ORDER BY ABS(" + AppGrowingEntry.COLUMN_NAME_DATE + " - ?)" +
            " LIMIT 1"

    val selectionArgs = arrayOf(timestamp.toString())

    val cursor = db.rawQuery(selectQuery, selectionArgs)
    // get min of list data
    if (cursor.moveToFirst()) {
        val beforeSize =
            cursor.getLong(cursor.getColumnIndexOrThrow(AppGrowingEntry.COLUMN_NAME_SIZE))
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val currentSize = applicationContext.getAppSize(packageName, null, null).getTotalSize();

            cursor.close()
            db.close()
            return currentSize - beforeSize
        } else {
            applicationContext.getAppSize(packageName, null) {
                val currentSize = it.getTotalSize()

                methodChannel.invokeMethod(
                    "returnDifferentInSize",
                    if (currentSize - beforeSize > 0) currentSize - beforeSize else 0
                )
            }
        }
        cursor.close()
    }
    db.close()
    return 0L
}

fun Context.runBatteryAnalysisService(){
    BatteryService.BatteryServiceController.startService(applicationContext)
}

fun Context.getTimeRemainingForBatteryAnalysis(): Long {

    val waitingTime = 2 * 24 * 3600 * 1000L // 2 days

    val timeEnd = LocalStorage.readLongData(
        applicationContext,
        StorageConstant.BundleName.TIME_REMAINING_FOR_BATTERY_ANALYSIS,
        StorageConstant.Key.TIME_REMAINING_FOR_BATTERY_ANALYSIS,
    )
    if (timeEnd < 0) {

        LocalStorage.writeLongData(
            applicationContext,
            StorageConstant.BundleName.TIME_REMAINING_FOR_BATTERY_ANALYSIS,
            StorageConstant.Key.TIME_REMAINING_FOR_BATTERY_ANALYSIS,
            System.currentTimeMillis() + waitingTime
        )

        return waitingTime
    } else {
        return timeEnd - System.currentTimeMillis()
    }
}

fun Context.getBatteryUsagePercentageInOneDay() : Map<String, Double> {
    return BatteryAnalysisHandler.getBatteryUsagePercentageInOneDay(applicationContext)
}

fun Context.getBatteryUsagePercentageInSevenDays() : Map<String, Double> {
    return BatteryAnalysisHandler.getBatteryUsagePercentageInSevenDays(applicationContext)
}

private var packageRemovedReceiver : PackageRemovedReceiver? = null;
fun Context.registerPackageRemovedReceiver(flutterMethodChannel : MethodChannel) {
    if(packageRemovedReceiver == null){
        packageRemovedReceiver = PackageRemovedReceiver(this, flutterMethodChannel)
    }
    packageRemovedReceiver?.registerReceiver()
}

fun Context.unregisterPackageRemovedReceiver() {
    if(packageRemovedReceiver != null){
        packageRemovedReceiver?.unregisterReceiver()
    }
}

fun Context.uninstallApplication(packageName: String, activity: Activity){
    val uri: Uri = Uri.fromParts("package", packageName, null)
    val intent = Intent(Intent.ACTION_UNINSTALL_PACKAGE, uri)
    intent.putExtra(Intent.EXTRA_RETURN_RESULT, true)
//    //Log.d("uninstall", "${packageName}")
    startActivityForResult(activity, intent, packageUninstallRequestCode, null)

}

fun Context.getApkFileIcon(apkFilePath: String) : ByteArray {
    val packageInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
        packageManager.getPackageArchiveInfo(apkFilePath, PackageManager.PackageInfoFlags.of(0))
    } else {
        packageManager.getPackageArchiveInfo(apkFilePath, 0)
    }

    if (packageInfo != null) {
        val appInfo: ApplicationInfo = packageInfo.applicationInfo
        appInfo.sourceDir = apkFilePath
        appInfo.publicSourceDir = apkFilePath
        val drawable = appInfo.loadIcon(packageManager)

        val bitmap = Bitmap.createBitmap(drawable.intrinsicWidth, drawable.intrinsicHeight, Bitmap.Config.ARGB_8888);
        val canvas = Canvas(bitmap);
        drawable.setBounds(0, 0, canvas.width, canvas.height);
        drawable.draw(canvas)

        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
        return stream.toByteArray()
    }

    throw InvalidApkException("Invalid apk file path. Do you have a file that is not actually an apk file but has the extension .apk?")
}