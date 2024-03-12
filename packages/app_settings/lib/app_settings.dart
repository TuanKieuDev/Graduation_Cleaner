import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';

class AppSettings {
  // Static constant variable to initialize MethodChannel of 'app_settings'.
  static const MethodChannel _channel = MethodChannel('app_settings');

  /// Future async method call to open WIFI settings.
  static Future<void> openWIFISettings({
    bool asAnotherTask = false,
  }) async {
    _channel.invokeMethod('wifi', {
      'asAnotherTask': asAnotherTask,
    });
  }

  /// Future async method call to open wireless settings.
  static Future<void> openWirelessSettings({
    bool asAnotherTask = false,
  }) async {
    _channel.invokeMethod('wireless', {
      'asAnotherTask': asAnotherTask,
    });
  }

  static Future<void> openListenNotificationSettings({
    bool asAnotherTask = false,
  }) async {
    _channel.invokeMethod('notificationSetting', {
      'asAnotherTask': asAnotherTask,
    });
  }

  static Future<void> openUsageSettings({
    bool asAnotherTask = false,
  }) async {
    _channel.invokeMethod('usage', {
      'asAnotherTask': asAnotherTask,
    });
  }

  static Future<bool> checkUsagePermissions({
    bool asAnotherTask = false,
  }) async {
    final isGranted = await _channel.invokeMethod<bool>('checkUsage', {
      'asAnotherTask': asAnotherTask,
    });
    return isGranted ?? false;
  }

  /// Future async method call to open location settings.
  static Future<void> openLocationSettings({
    bool asAnotherTask = false,
  }) async {
    _channel.invokeMethod('location', {
      'asAnotherTask': asAnotherTask,
    });
  }

  /// Future async method call to open security settings.
  static Future<void> openSecuritySettings({
    bool asAnotherTask = false,
  }) async {
    _channel.invokeMethod('security', {
      'asAnotherTask': asAnotherTask,
    });
  }

  /// Future async method call to open security settings.
  static Future<void> openLockAndPasswordSettings({
    bool asAnotherTask = false,
  }) async {
    _channel.invokeMethod('locksettings', {
      'asAnotherTask': asAnotherTask,
    });
  }

  /// Future async method call to open bluetooth settings.
  static Future<void> openBluetoothSettings({
    bool asAnotherTask = false,
  }) async {
    _channel.invokeMethod('bluetooth', {
      'asAnotherTask': asAnotherTask,
    });
  }

  /// Future async method call to open data roaming settings.
  static Future<void> openDataRoamingSettings({
    bool asAnotherTask = false,
  }) async {
    _channel.invokeMethod('data_roaming', {
      'asAnotherTask': asAnotherTask,
    });
  }

  /// Future async method call to open date settings.
  static Future<void> openDateSettings({
    bool asAnotherTask = false,
  }) async {
    _channel.invokeMethod('date', {
      'asAnotherTask': asAnotherTask,
    });
  }

  /// Future async method call to open display settings.
  static Future<void> openDisplaySettings({
    bool asAnotherTask = false,
  }) async {
    _channel.invokeMethod('display', {
      'asAnotherTask': asAnotherTask,
    });
  }

  static Future<bool> checkNotificationListenerPermissions() async {
    final isGranted =
        await _channel.invokeMethod<bool>('checkNotificationListener');
    log("called check noti");
    return isGranted ?? false;
  }

  /// Future async method call to open notification settings.
  static Future<void> openNotificationSettings({
    bool asAnotherTask = false,
  }) async {
    _channel.invokeMethod('notificationSettings', {
      'asAnotherTask': asAnotherTask,
    });
  }

  static Future<bool> checkNotificationPermissions({
    bool asAnotherTask = false,
  }) async {
    final isGranted = await _channel.invokeMethod<bool>('checkNotification', {
      'asAnotherTask': asAnotherTask,
    });
    log("called check noti");
    return isGranted ?? false;
  }

  /// Future async method call to open sound settings.
  static Future<void> openSoundSettings({
    bool asAnotherTask = false,
  }) async {
    _channel.invokeMethod('sound', {
      'asAnotherTask': asAnotherTask,
    });
  }

  /// Future async method call to open internal storage settings.
  static Future<void> openInternalStorageSettings({
    bool asAnotherTask = false,
  }) async {
    _channel.invokeMethod('internal_storage', {
      'asAnotherTask': asAnotherTask,
    });
  }

  /// Future async method call to open battery optimization settings.
  static Future<void> openBatteryOptimizationSettings({
    bool asAnotherTask = false,
  }) async {
    _channel.invokeMethod('battery_optimization', {
      'asAnotherTask': asAnotherTask,
    });
  }

  /// Future async method call to open app specific settings screen.
  static Future<void> openAppSettings({bool asAnotherTask = false}) async {
    _channel.invokeMethod('app_settings', {
      'asAnotherTask': asAnotherTask,
    });
  }

  static Future<void> openOtherAppSettings(
      {bool asAnotherTask = false, String packageName = ""}) async {
    _channel.invokeMethod('app_settings_1',
        {'asAnotherTask': asAnotherTask, 'packageName': packageName});
  }

  static Future<void> uninstallApp(
      {bool asAnotherTask = false, String packageName = ""}) async {
    _channel.invokeMethod('uninstallApp',
        {'asAnotherTask': asAnotherTask, 'packageName': packageName});
  }

  static Future<void> uninstallApps(
      {bool asAnotherTask = false,
      List<String> listPackageName = const []}) async {
    _channel.invokeMethod('uninstallListApp',
        {'asAnotherTask': asAnotherTask, 'listPackageName': listPackageName});
  }

  /// Future async method call to open NCF settings.
  static Future<void> openNFCSettings({
    bool asAnotherTask = false,
  }) async {
    _channel.invokeMethod('nfc', {
      'asAnotherTask': asAnotherTask,
    });
  }

  /// Future async method call to open Device settings.
  static Future<void> openDeviceSettings({
    bool asAnotherTask = false,
  }) async {
    _channel.invokeMethod('device_settings', {
      'asAnotherTask': asAnotherTask,
    });
  }

  /// Future async method call to open VPN settings.
  static Future<void> openVPNSettings({
    bool asAnotherTask = false,
  }) async {
    _channel.invokeMethod('vpn', {
      'asAnotherTask': asAnotherTask,
    });
  }

  /// Future async method call to open accessibility settings.
  static Future<void> openAccessibilitySettings({
    bool asAnotherTask = false,
  }) async {
    _channel.invokeMethod('accessibility', {
      'asAnotherTask': asAnotherTask,
    });
  }

  /// Future async method call to open Development settings.
  static Future<void> openDevelopmentSettings(
      {bool asAnotherTask = false}) async {
    _channel.invokeMethod('development', {'asAnotherTask': asAnotherTask});
  }

  /// Opening hotspot and tethering settings
  static Future<void> openHotspotSettings({bool asAnotherTask = false}) async {
    _channel.invokeMethod('hotspot', {'asAnotherTask': asAnotherTask});
  }

  /// Future async method call to open APN settings.
  static Future<void> openAPNSettings({
    bool asAnotherTask = false,
  }) async {
    _channel.invokeMethod('apn', {
      'asAnotherTask': asAnotherTask,
    });
  }

  /// Future async method call to open Alarms & Reminders settings.
  static Future<void> openAlarmSettings({
    bool asAnotherTask = false,
  }) async {
    _channel.invokeMethod('alarm', {
      'asAnotherTask': asAnotherTask,
    });
  }
}
