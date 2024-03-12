import 'dart:typed_data';

import 'package:device_info/src/flutter_config/src/models/src/app_type.dart';
import 'package:device_info/src/native_connection/src/native_calling/app_manager_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../../../../device_info.dart';

abstract class AppManagerPlatform extends PlatformInterface {
  /// Constructs a CleanerAppInfoPlatform.
  AppManagerPlatform() : super(token: _token);

  static final Object _token = Object();

  static AppManagerPlatform _instance = AppManagerAndroid();

  /// The default instance of [AppManagerPlatform] to use.
  ///
  /// Defaults to [MethodChannelDeviceInfo].
  static AppManagerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AppManagerPlatform] when
  /// they register themselves.
  static set instance(AppManagerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<T> invokeMethod<T>(String method, [dynamic arguments]);

  Future<List<dynamic>> getAllApplications();

  Future<String> getPlatformVersion() {
    return Future.value('1.0.0');
  }

  Future<String> getApplicationLabel(String packageName);

  Future<Uint8List> getApplicationIconBitmap(String packageName);

  Future<String> killApp(String packageName);

  Future<String> freeUpRam();

  Future<AppType> getApplicationType(String packageName);

  Future<String> getRunningApp();

  Future<String> getVisibleCaches();

  Future<String> getAppData();

  Future<String> getHiddenCaches();

  Future<String> getIconPackage(String package);

  Future<int> getUsageDataApps(String package);

  Future<void> collectAllEvents(
      List<String> packagesNameList, int startTimeInEpoch, int endTimeInEpoch);

  Future<int> getLastAppUsageTime(String package);

  Future<String> getAppUsageInfo(
      String packageName, int startTimeInEpoch, int endTimeInEpoch);

  Future<Map> getAppsUsageInfo(int startTimeInEpoch, int endTimeInEpoch);

  Future<String> getAllSize();

  Future<String> getIconFolderApp(String name);

  Future<Map> getAppSize(
      String packageName, void Function(AppInfoSize) callback);

  Future<void> runAppGrowingService();

  Future<void> runBatteryAnalysisService();

  Future<int> getTimeRemainingForAppGrowingAnalysis();

  Future<int> getAppSizeGrowingInByte(
      String packageName, int inDays, void Function(int) callback);

  Future<int> getTimeRemainingForBatteryAnalysis();

  Future<Map<dynamic, dynamic>> getBatteryUsagePercentageInOneDay();

  Future<Map<dynamic, dynamic>> getBatteryUsagePercentageInSevenDays();

  Future<List<dynamic>> getBatteryAnalysisAllRowsForTest();

  Future<int> getUnnecessaryData();

  Future<int> countNotificationsInRange(
      String packageName, int startTimeEpochMillis, int endTimeEpochMillis);

  Future<Map<dynamic, dynamic>> countNotificationOfAllPackagesInRange(
      int startTimeEpochMillis, int endTimeEpochMillis);

  Future<void> registerPackageRemovedReceiver(
      void Function(String removedPackage) onReceive);

  Future<void> unregisterPackageRemovedReceiver();

  Future<bool> uninstall(String packageName);

  Future<Uint8List> getApkFileIcon(String path);
}
