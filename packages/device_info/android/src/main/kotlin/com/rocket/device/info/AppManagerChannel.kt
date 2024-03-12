package com.rocket.device.info

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageInstaller
import android.util.Log
import com.rocket.device.info.core.ExecutorService
import com.rocket.device.info.data.sql.helper.BatteryAnalysisDbHelper
import com.rocket.device.info.exception.DeviceInfoException
import com.rocket.device.info.exception.execute
import com.rocket.device.info.services.*
import com.rocket.device.info.settings.toByteArray
import com.rocket.device.info.util.ResultHandler
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import kotlinx.coroutines.*
import serializeToMap

class AppManagerChannel(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding, name: String) :
    MethodChannel(flutterPluginBinding.binaryMessenger, name),
    ActivityAware,
    ActivityResultListener,
    MethodChannel.MethodCallHandler {
    private val applicationContext: Context = flutterPluginBinding.applicationContext
    private val quickBoostManager = QuickBoostManager();
    private var activity: Activity? = null

    init {
        setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getAllApplications" -> runOnIOThreadWithResult(result) {
                applicationContext.getInstalledApplications().map { it.toMap() }
            }
            "getApplicationLabel" -> runOnIOThreadWithResult(result) {
                applicationContext.getApplicationLabel(call.argument("packageName")!!)
            }
            "getUsageDataApps" -> runOnIOThreadWithResult(result) {
                applicationContext.getUsageDataApps(call.argument("packageName")!!)
            }
            "getApplicationType" -> result.execute {
                applicationContext.getApplicationType(call.argument("packageName")!!)
            }
            "getApplicationIconBitmap" -> runOnIOThreadWithResult(result) {
                applicationContext.getAppIconBitmap(call.argument("packageName")!!).toByteArray()
            }
            "collectAllEvents" -> result.execute {
                AppInfoUsageManager.collectAllEvents(applicationContext, call.argument("packagesNameList")!!, call.argument("startTimeInEpoch")!!, call.argument("endTimeInEpoch")!!)
            }
            "getLastAppUsageTime" -> result.execute {
                AppInfoUsageManager.getLastAppUsageTime(applicationContext, call.argument("packageName")!!)
            }
            "getAppUsageInfo" -> runOnIOThreadWithResult(result) {
                AppInfoUsageManager.getAppUsageInfo(applicationContext, call.argument("packageName")!!, call.argument("startTimeInEpoch")!!, call.argument("endTimeInEpoch")!!)
            }
            "getAppSize" -> result.execute {
                applicationContext.getAppSize(call.argument("packageName")!!, this, null).toMap()
            }
            "getUnnecessaryData" -> result.execute {
                quickBoostManager.getUnnecessaryData(applicationContext)
            }
            "runAppGrowingService" -> result.execute {
                applicationContext.runAppGrowingService()
            }
            "getTimeRemainingForAppGrowingAnalysis" -> result.execute {
                applicationContext.getTimeRemainingForAppGrowingAnalysis()
            }
            "getAppSizeGrowingInByte" -> result.execute {
                applicationContext.getAppSizeGrowingInByte(call.argument("packageName")!!, call.argument("inDays")!!, this)
            }
            "freeUpRam" -> result.execute {
                quickBoostManager.deleteRam(applicationContext).toString()
            }
            "runBatteryAnalysisService" -> applicationContext.runBatteryAnalysisService()
            "getTimeRemainingForBatteryAnalysis" -> result.execute {
                applicationContext.getTimeRemainingForBatteryAnalysis()
            }
            "getBatteryUsagePercentageInOneDay" -> result.execute {
                applicationContext.getBatteryUsagePercentageInOneDay()
            }
            "getBatteryUsagePercentageInSevenDays" -> result.execute {
                applicationContext.getBatteryUsagePercentageInSevenDays()
            }
            "getBatteryAnalysisAllRowsForTest" -> result.execute {
                BatteryAnalysisDbHelper(applicationContext).getBatteryAnalysisAllRowsForTest()
            }
            "countNotificationsInRange" -> result.execute {
                applicationContext.countNotificationsInRange(call.argument("packageName")!!, call.argument("startTimeEpochMillis")!!, call.argument("endTimeEpochMillis")!!)
            }
            "countNotificationOfAllPackagesInRange" -> result.execute {
                applicationContext.countNotificationOfAllPackagesInRange(call.argument("startTimeEpochMillis")!!, call.argument("endTimeEpochMillis")!!)
            }
            "registerPackageRemovedReceiver" -> result.execute {
                applicationContext.registerPackageRemovedReceiver(this)
            }
            "unregisterPackageRemovedReceiver" -> result.execute {
                applicationContext.unregisterPackageRemovedReceiver()
            }
            "uninstall" -> result.execute {
                applicationContext.uninstallApplication(call.argument("packageName")!!, activity!!)
            }
            "getApkFileIcon" -> result.execute {
                applicationContext.getApkFileIcon(call.argument("path")!!)
            }
            else -> result.notImplemented()

        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null;
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null;
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == packageUninstallRequestCode){
            val packageName = data?.getStringExtra(PackageInstaller.EXTRA_PACKAGE_NAME)
            val result = resultCode < 0
            invokeMethod("onUninstallResult", result)
            //Log.d("uninstall", "${requestCode} ${resultCode} ${data} ${packageName}")
            return true
        }
        return false
    }

    private fun runOnIOThreadWithResult(result: Result, body: () -> Any){
        val resultHandler = ResultHandler(result)

        val scope = CoroutineScope(Dispatchers.IO)
        val job = scope.launch {
            try {
                val value = withContext(ExecutorService.executor.asCoroutineDispatcher()){
                    body.invoke()
                }
                resultHandler.reply(value)
            }catch (deviceInfoException: DeviceInfoException){
                resultHandler.replyError(deviceInfoException.javaClass.name, deviceInfoException.message, deviceInfoException.serializeToMap())
            }
        }

        job.invokeOnCompletion { scope.cancel() }
    }
}