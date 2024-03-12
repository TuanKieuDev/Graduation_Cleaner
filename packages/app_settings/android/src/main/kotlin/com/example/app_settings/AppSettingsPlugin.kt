package com.example.app_settings

import android.Manifest
import android.app.Activity
import android.app.ActivityManager
import android.app.ActivityManager.RunningServiceInfo
import android.app.AppOpsManager
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Process
import android.provider.Settings
import android.text.TextUtils
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar


class AppSettingsPlugin() : MethodCallHandler, FlutterPlugin, ActivityAware {
  /// Private variable to hold instance of Registrar for creating Intents.
  private lateinit var activity: Activity
  private lateinit var context: Context
  private val TAG = "AppSettingsPlugin"

  private fun checkPermissionUsage(url : String): Boolean {
    var granted = false
    val appOps = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
      context
        .getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
    } else {
      TODO("VERSION.SDK_INT < KITKAT")
    }
    val mode = appOps.checkOpNoThrow(
      AppOpsManager.OPSTR_GET_USAGE_STATS,
      Process.myUid(), context.packageName
    )

    granted = if (mode == AppOpsManager.MODE_DEFAULT) {
      context.checkCallingOrSelfPermission(Manifest.permission.PACKAGE_USAGE_STATS) === PackageManager.PERMISSION_GRANTED
    } else {
      mode == AppOpsManager.MODE_ALLOWED
    }

    return granted
  }

  private fun isNotificationServiceEnable(): Boolean {
    var granted = false
    val appOps = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
      context
              .getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
    } else {
      TODO("VERSION.SDK_INT < KITKAT")
    }
    for (service: RunningServiceInfo in appOps.getRunningServices(Int.MAX_VALUE)){
      if(service.service.className.toString() == "com.rocket.device.info.settings.NotificationService"){
        granted = true;
      }
    }


    return granted
  }

  private fun isNotificationListenerGranted(): Boolean {
    val packageName = context.packageName
    val flat = Settings.Secure.getString(
      context.contentResolver,
      "enabled_notification_listeners"
    )
    if (flat.isEmpty()) return false

    val names = flat.split(":").toTypedArray()
    for (name in names) {
      val componentName = ComponentName.unflattenFromString(name)
      val nameMatch: Boolean = TextUtils.equals(packageName, componentName!!.packageName)
      if (nameMatch) {
        return true
      }
    }
    return false
  }

  private fun openSettings1(url: String, asAnotherTask: Boolean = false) {
    try {
      if(checkPermissionUsage(url)) {
        //Log.d(TAG, "Permission Usage Granted")
      } else {
        //Log.d(TAG, "Permission Usage Not Granted")
        val intent = Intent(url)
        if (asAnotherTask) intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        this.activity.startActivity(intent)
      }
    } catch (e: Exception) {
      // Default to APP Settings if setting activity fails to load/be available on device
      openAppSettings(asAnotherTask)
    }
  }

  /// Private method to open device settings window
  private fun openSettings(url: String, asAnotherTask: Boolean = false) {
    try {
      val intent = Intent(url)
      if (asAnotherTask) intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
      this.activity.startActivity(intent)
    } catch (e: Exception) {
      // Default to APP Settings if setting activity fails to load/be available on device
      openAppSettings(asAnotherTask)
    }
  }

  private fun openSettingsWithCustomIntent(intent: Intent, asAnotherTask: Boolean = false) {
    try {
      if (asAnotherTask) intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
      this.activity.startActivity(intent)
    } catch (e: Exception) {
      // Default to APP Settings if setting activity fails to load/be available on device
      openAppSettings(asAnotherTask)
    }
  }



  private fun openAppSettings(asAnotherTask: Boolean = false) {

    val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
    if (asAnotherTask) intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    val uri = Uri.fromParts("package", this.activity.packageName, null)
    intent.data = uri
    this.activity.startActivity(intent)
  }

  private fun openAppSettings1(asAnotherTask: Boolean = false, packageName : String = "") {
    val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
    if (asAnotherTask) intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    val uri = Uri.fromParts("package", packageName, null)
    intent.data = uri
    this.activity.startActivity(intent)
  }

  private fun uninstallApp(asAnotherTask: Boolean = false, packageName : String = "") {
      return;
    val intent = Intent(Intent.ACTION_DELETE)
    if (asAnotherTask) intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    val uri = Uri.fromParts("package", packageName, null)
    intent.data = uri
    this.activity.startActivity(intent)
  }

  private fun uninstallListApp(asAnotherTask: Boolean = false, listPackageName : List<String> = listOf()) {
    val intent = Intent(Intent.ACTION_DELETE)
    if (asAnotherTask) intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    for(packageName in listPackageName) {
      val uri = Uri.fromParts("package", packageName, null)
      intent.data = uri
      this.activity.startActivity(intent)
    }
  }

  /// Main constructor to setup the Registrar
  constructor(registrar: Registrar) : this() {
    //this.activity = registrar.activity() //Deprecated: https://api.flutter.dev/javadoc/io/flutter/plugin/common/PluginRegistry.Registrar.html#activity()
  }

  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "app_settings")
      channel.setMethodCallHandler(AppSettingsPlugin(registrar))
    }
  }

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    context = binding.applicationContext
    val channel = MethodChannel(binding.binaryMessenger, "app_settings")
    channel.setMethodCallHandler(this)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {

  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    this.activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    this.activity = binding.activity
  }

  override fun onDetachedFromActivity() {
  }

  /// Handler method to manage method channel calls.
  override fun onMethodCall(call: MethodCall, result: Result) {

    val asAnotherTask = call.argument("asAnotherTask") ?: false
    val packageName = call.argument("packageName") ?: ""
    val listPackageName : List<String> = call.argument("listPackageName") ?: listOf()

    when (call.method) {
        "wifi" -> {
          openSettings(Settings.ACTION_WIFI_SETTINGS, asAnotherTask)
        }
        "wireless" -> {
          openSettings(Settings.ACTION_WIRELESS_SETTINGS, asAnotherTask)
        }
        "usage" -> {
          openSettings1(Settings.ACTION_USAGE_ACCESS_SETTINGS, asAnotherTask)
        }
        "notificationSettings" -> {
          openSettings(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS, asAnotherTask)
        }
        "location" -> {
          openSettings(Settings.ACTION_LOCATION_SOURCE_SETTINGS, asAnotherTask)
        }
        "security" -> {
          openSettings(Settings.ACTION_SECURITY_SETTINGS, asAnotherTask)
        }
        "locksettings" -> {
          openSettings(DevicePolicyManager.ACTION_SET_NEW_PASSWORD, asAnotherTask)
        }
        "bluetooth" -> {
          openSettings(Settings.ACTION_BLUETOOTH_SETTINGS, asAnotherTask)
        }
        "data_roaming" -> {
          openSettings(Settings.ACTION_DATA_ROAMING_SETTINGS, asAnotherTask)
        }
        "date" -> {
          openSettings(Settings.ACTION_DATE_SETTINGS, asAnotherTask)
        }
        "display" -> {
          openSettings(Settings.ACTION_DISPLAY_SETTINGS, asAnotherTask)
        }
        "notification" -> {
          if (Build.VERSION.SDK_INT >= 26) {
            val intent = Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
              .putExtra(Settings.EXTRA_APP_PACKAGE, this.activity.packageName)
            if (asAnotherTask) intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            this.activity.startActivity(intent)
          } else {
            openAppSettings(asAnotherTask)
          }
        }
        "nfc" -> {
          openSettings(Settings.ACTION_NFC_SETTINGS, asAnotherTask)
        }
        "sound" -> {
          openSettings(Settings.ACTION_SOUND_SETTINGS, asAnotherTask)
        }
        "internal_storage" -> {
          openSettings(Settings.ACTION_INTERNAL_STORAGE_SETTINGS, asAnotherTask)
        }
        "battery_optimization" -> {
          openSettings(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS, asAnotherTask)
        }
        "vpn" -> {
          if(Build.VERSION.SDK_INT >= 24) {
            openSettings(Settings.ACTION_VPN_SETTINGS, asAnotherTask)
          }else{
            openSettings("android.net.vpn.SETTINGS", asAnotherTask)
          }
        }
        "app_settings" -> {
          openAppSettings(asAnotherTask)
        }
        "app_settings_1" -> {
          openAppSettings1(asAnotherTask, packageName)
        }
        "uninstallApp" -> {
          uninstallApp(asAnotherTask, packageName)
        }
        "uninstallListApp" -> {
          uninstallListApp(asAnotherTask, listPackageName)
        }
        "device_settings" -> {
          openSettings(Settings.ACTION_SETTINGS, asAnotherTask)
        }
        "accessibility" -> {
          openSettings(Settings.ACTION_ACCESSIBILITY_SETTINGS, asAnotherTask)
        }
        "development" -> {
          openSettings(Settings.ACTION_APPLICATION_DEVELOPMENT_SETTINGS, asAnotherTask)
        }
        "hotspot" -> {
          val intent = Intent()
          intent.setClassName("com.android.settings", "com.android.settings.TetherSettings")
          openSettingsWithCustomIntent(intent, asAnotherTask)
        }
        "apn" -> {
          openSettings(Settings.ACTION_APN_SETTINGS, asAnotherTask)
        }
        "alarm" -> {
          val uri = Uri.fromParts("package", this.activity.packageName, null)
          openSettingsWithCustomIntent(Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM, uri), asAnotherTask)
        }
        "checkUsage" -> {
          result.success(checkPermissionUsage(Settings.ACTION_USAGE_ACCESS_SETTINGS))
        }
        "checkNotification" -> {
          result.success(isNotificationServiceEnable())
        }
        "checkNotificationListener" -> {
          result.success(isNotificationListenerGranted())
        }
    }
  }
}
