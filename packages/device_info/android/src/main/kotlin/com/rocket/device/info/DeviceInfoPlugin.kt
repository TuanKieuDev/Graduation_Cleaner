package com.rocket.device.info

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Environment
import android.os.Handler
import android.os.Looper
import com.rocket.device.info.exception.execute
import com.rocket.device.info.services.getAppIconBitmap
import com.rocket.device.info.services.getInstalledApplications
import com.rocket.device.info.services.*
import com.rocket.device.info.settings.Permissions
import com.rocket.device.info.settings.toByteArray
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import org.opencv.android.OpenCVLoader
import serializeToMap
import java.lang.Exception

/** CleanerAppInfoPlugin */
class DeviceInfoPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, ActivityResultListener {
    private lateinit var appManagerChannel: AppManagerChannel
    private lateinit var fileManagerChannel: FileManagerChannel
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var activity: Activity
    private val generalInfoManager = GeneralInfoManager()
    private val appInfoManager = AppInfoManager()

    //private val appInfoUsageManager = AppInfoUsageManager()
    private val folderInfoManager = FolderInfoManager()
    private val fileInfoManager = FileInfoManager()
    private val quickBoostManager = QuickBoostManager()


    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        appManagerChannel = AppManagerChannel(flutterPluginBinding, "app_manager")
        fileManagerChannel = FileManagerChannel(flutterPluginBinding, "file_manager")
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "device_info")
        channel.setMethodCallHandler(this)

        fileInfoManager.callScanItent(context, Environment.getExternalStorageDirectory().toString())
//        fileInfoManager.callScanItent(context, "sdcard")
//        fileInfoManager.refreshMedia("storage/emulated/0/", context)
//        fileInfoManager.refreshMedia("sdcard", context)

        OpenCVLoader.initDebug()
    }



    override fun onMethodCall(call: MethodCall, result: Result) {

        when (call.method) {
            "getPlatformVersion" -> result.success(Build.VERSION.RELEASE)
            "getGeneralInfo" -> result.success(getGeneralInfo())
            "getDownloads" -> result.success(getDownloads())
            "getThumbnails" -> result.success(getThumbnails())
            "getAppData" -> result.success(getAppData())
            "getAPKFiles" -> result.success(getAPKFiles())
            "getEmptyFolders" -> result.success(getEmptyFolders())
            "getVisibleCaches" -> result.success(getVisibleCaches())
            "deleteFile" -> deleteFile(call, result)
//            "getDuplicateFiles" -> result.success(getDuplicateFiles())
            "deleteListFiles" -> deleteListFiles(call, result)
            "killApp" -> result.success(killApp())
//            "getRunningApp" -> result.success(getRunningApp())
            "getAllImages" -> result.success(getAllImages())
            "getAllAudios" -> result.success(getAllAudios())
            "getAllVideos" -> result.success(getAllVideos())
            "getAllMediaFiles" -> result.success(getAllMediaFiles())
            "getAllFiles" -> result.success(getAllFiles())
//            "getSimilar2Images" -> getSimilar2Images(call, result)
            "getSimilarImages" -> getSimilarImages(call, result)
            "getOldImagesBetween1Month" -> result.success(getOldImagesBetween1Month())
            "getOldLargeFilesBetween6Month" -> result.success(getOldLargeFilesBetween6Month())
            "getLargeVideos" -> result.success(getLargeVideos())
            "getLargeFiles" -> result.success(getLargeFiles())
            "getAllMediaFolders" -> result.success(getAllMediaFolders())
            "getBadImages" -> result.success(getBadImages())
            "getSensitiveImages" -> result.success(getSensitiveImages())
            "isImageValid" -> isImageValid(call, result)
            "getOptimizableImages" -> result.success(getOptimizableImages())
            //"optimizeImagePreview" -> optimizeImagePreview(call, result)
            //"optimizeImages" -> optimizeImages(call, result)
            //"getUsageLast24Hours" -> result.success(getUsageLast24Hours())
            //"getUsageLast7Days" -> result.success(getUsageLast7Days())
            "getIconFolderApp" -> getIconFolderApp(call, result)
            "optimizeInterface" -> optimizeInterface(call, result)
            //"timelineUsageStats" -> timelineUsageStats(call, result)
//            "checkPermissionUsage" -> result.success(checkPermissionUsage())
//            "checkPermissionAllStorage" -> result.success(checkPermissionAllStorage())
//            "checkPermissionStorage" -> result.success(checkPermissionStorage())

            //=============NEW API==============
            "getAllApplications" -> getAllApplications(result)
            "getApplicationLabel" -> getApplicationLabel(result, call.argument("packageName")!!)
            "getApplicationIconBitmap" -> getApplicationIconBitmap(
                result,
                call.argument("packageName")!!
            )

            else -> result.notImplemented()
        }
    }

    private fun getAllApplications(result: Result) {
        try {
            val installedApplications = context.getInstalledApplications()
            result.success(installedApplications.map { it.serializeToMap() })
        } catch (e: java.lang.Exception) {
            result.error("UNKNOWN", e.message, e.stackTrace)
        }
    }

    private fun getApplicationLabel(result: Result, packageName: String) {
        try {
            result.success(context.getApplicationLabel(packageName))
        } catch (e: Exception) {
            result.error("UNKNOWN", e.message, e.stackTrace)
        }
    }

    private fun getApplicationIconBitmap(result: Result, packageName: String) {
        try {
            result.success(context.getAppIconBitmap(packageName).toByteArray())
        } catch (e: java.lang.Exception) {
            result.error("UNKNOWN", e.message, e.stackTrace)
        }
    }

    /* Permission Info */

//    private fun checkPermissionUsage(): String {
//        return permission.checkPermissionUsage(context).toString()
//    }
//
//    private fun checkPermissionAllStorage(): String {
//        return permission.checkPermissionAllStorage(context).toString()
//    }
//
//    private fun checkPermissionStorage(): String {
//        return permission.checkPermissionStorage(context).toString()
//    }


    /* Quick Boost Info */

    private fun killApp(): String {
        return quickBoostManager.deleteRam(context).toString()
    }

//    private fun getRunningApp(): String {
//        return convertListToStringList(quickBoostManager.getRunningApp(context))
//    }

    /* Quick Clean Info */

    private fun getDownloads(): String {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            convertListToStringList(fileInfoManager.getDownloads())
        } else {
            TODO("VERSION.SDK_INT < P")
        }
    }

    private fun getThumbnails(): String {
        return convertListToStringList(folderInfoManager.getThumbnails())
    }


    private fun getAppData(): String {
        return convertListToStringList(folderInfoManager.getAppData())
    }

    private fun getAPKFiles(): String {
        return convertListToStringList(fileInfoManager.getAPKs())
    }

    private fun getEmptyFolders(): String {
        return convertListToStringList(folderInfoManager.getEmptyFolders(context))
    }

    private fun getVisibleCaches(): String {
        return convertListToStringList(folderInfoManager.getVisibleCaches())
    }

    private fun deleteFile(call: MethodCall, result: Result) {
        var path: String = call.argument<String>("path").toString()
        val textMessage = fileInfoManager.deleteFile(path, context)

        return result.success(textMessage)
    }

    private fun deleteListFiles(call: MethodCall, result: Result) {
        var listPaths: List<String> = call.argument<List<String>>("listPaths") ?: listOf()
        val textMessage = fileInfoManager.deleteListFiles(listPaths, context)

        return result.success("Done")
    }

    /* Media Info */

    private fun getAllImages(): String {
        return convertListToStringList(fileInfoManager.getAllImages(context))
    }

    private fun getAllAudios(): String {
        return convertListToStringList(fileInfoManager.getAllAudios(context))
    }

    private fun getAllVideos(): String {
        return convertListToStringList(fileInfoManager.getAllVideos(context))
    }

    private fun getAllMediaFiles(): String {
        return convertListToStringList(fileInfoManager.getAllMediaFiles(context))
    }

    private fun getAllFiles(): String {
        return convertListToStringList(fileInfoManager.getAllFiles(context))

    }

    private fun getLargeVideos(): String {
        return convertListToStringList(fileInfoManager.getLargeVideos(context))
    }

    private fun getAllMediaFolders(): String {
        return convertListToStringList(folderInfoManager.getAllMediaFolders(context))
    }

    private fun getLargeFiles(): String {
        return convertListToStringList(fileInfoManager.getLargeFiles(context))
    }
//
//    private fun getDuplicateFiles(): String {
//        return convertListToStringList(fileInfoManager.getDuplicateFiles(context))
//    }

    /* Media function */

    //    private fun getSimilar2Images(call: MethodCall, result: Result) {
//        var path1: String = call.argument<String>("path1").toString()
//        var path2: String = call.argument<String>("path2").toString()
//
//
//        val similar = fileInfoManager.getSimilar2Images(path1, path2)
//
//        return result.success("$similar")
//    }
//
    // solution: https://stackoverflow.com/questions/60002675/flutter-platform-channels-invoke-channel-method-on-android-hangs-the-ui
    private fun getSimilarImages(call: MethodCall, result: Result) {
        var similarityLevel = call.argument<String>("similarityLevel").toString()
        var minSize = call.argument<String>("minSize").toString()
        val scanner = Thread {
            val result = fileInfoManager.getSimilarImages(
                context,
                similarityLevel.toDouble(),
                minSize.toInt()
            );
            Handler(Looper.getMainLooper()).post(Runnable {
                channel.invokeMethod(
                    "getSimilarImagesResult",
                    result
                )
            })
        }
        scanner.start()
    }

    private fun getOldImagesBetween1Month(): String {
        return convertListToStringList(fileInfoManager.getOldImagesBetween1Month(context))
    }

    private fun getOldLargeFilesBetween6Month(): String {
        return convertListToStringList(fileInfoManager.getOldLargeFilesBetween6Month(context))

    }

    private fun getBadImages(): String {
        return convertListToStringList(fileInfoManager.getLowImage(context))
    }

    private fun getSensitiveImages(): String {
        return convertListToStringList(fileInfoManager.getSensitiveImages(context))
    }

    private fun isImageValid(call: MethodCall, result: Result) {
        var path = call.argument<String>("path").toString()
        return result.success(fileInfoManager.isImageValid(path))
    }

    private fun getOptimizableImages(): List<Any> {
        //return fileInfoManager.getOptimizableImages(context);
        return listOf()
    }

//    private fun optimizeImagePreview(call: MethodCall, result: Result) {
//        var path = call.argument<String>("path").toString()
//        var quality = call.argument<String>("quality").toString()
//        var resolutionScale = call.argument<String>("resolutionScale").toString()
//
//        val listInfor = fileInfoManager.optimizeImagePreview(
//            context,
//            path,
//            quality.toInt(),
//            resolutionScale.toDouble()
//        )
//        return result.success(listInfor)
//    }

//    private fun optimizeImages(call: MethodCall, result: Result) {
//        var paths = call.argument<List<String>>("paths")
//        var quality = call.argument<String>("quality").toString()
//        var resolutionScale = call.argument<String>("resolutionScale").toString()
//        var deleteOriginal = call.argument<Boolean>("deleteOriginal").toString()
//        var packageName = call.argument<String>("packageName").toString()
//
//        val totalSpaceSaved = fileInfoManager.optimizeImages(
//            context,
//            paths,
//            quality.toInt(),
//            resolutionScale.toDouble(),
//            deleteOriginal.toBoolean(),
//            packageName
//        )
//        return result.success(totalSpaceSaved)
//    }

    private fun optimizeInterface(call: MethodCall, result: Result) {
        var path = call.argument<String>("path").toString()
        var isChange = call.argument<String>("isChange").toString()
        var quality = call.argument<String>("quality").toString()
        val textMessage =
            fileInfoManager.optimizeInterface(path, quality.toInt(), isChange.toBoolean())

        return result.success(textMessage)
    }

    private fun getIconFolderApp(call: MethodCall, result: Result) {
        var name = call.argument<String>("name").toString()

        return result.success(folderInfoManager.getIconFolderApp(context, name))
    }


    /* App Info */


    /* App Usage */

//    private fun timelineUsageStats(call: MethodCall, result: Result) {
//        val packageName = call.argument<String>("package").toString()
//        val usageManager = call.argument<Int>("usageManager").toString()
//
//        return result.success(
//            convertListToStringList(
//                appInfoUsageManager.timelineUsage(
//                    context,
//                    packageName,
//                    usageManager.toInt()
//                )
//            )
//        )
//    }
//
//    private fun getUsageLast24Hours(): String {
//        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
//            convertListToStringList(appInfoUsageManager.getUsageLast24Hours(context))
//        } else {
//            TODO("VERSION.SDK_INT < N")
//        }
//    }
//
//    private fun getUsageLast7Days(): String {
//        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
//            convertListToStringList(appInfoUsageManager.getUsageLast7Days(context))
//        } else {
//            TODO("VERSION.SDK_INT < N")
//        }
//    }

    /* Home Info */

    private fun getGeneralInfo(): String {

        return convertListToString(generalInfoManager.generalInfo(context))
    }

    /* End Function */

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun convertListToStringList(list: List<Any>): String {
        return list.toString()
    }

    private fun convertListToString(objectInfo: Any): String {
        return objectInfo.toString()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        appManagerChannel.onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        appManagerChannel.onDetachedFromActivityForConfigChanges()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        appManagerChannel.onReattachedToActivityForConfigChanges(binding)
    }

    override fun onDetachedFromActivity() {
        appManagerChannel.onDetachedFromActivity()
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
//        return appManagerChannel.onActivityResult(requestCode, resultCode, data)
        return false;
    }
}
