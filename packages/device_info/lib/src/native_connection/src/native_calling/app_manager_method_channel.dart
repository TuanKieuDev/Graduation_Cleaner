import 'dart:async';

import 'package:device_info/src/flutter_config/src/models/src/app_type.dart';
import 'package:device_info/src/native_connection/src/native_calling/app_manager_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../../device_info.dart';

/// An implementation of [AppManagerPlatform] that uses method channels.
class AppManagerAndroid extends AppManagerPlatform {
  List<ValueSetter<bool>> uninstallResultCallbacks = [];
  List<ValueSetter<String>> packageRemovedReceivedCallbacks = [];

  AppManagerAndroid() {
    methodChannel.setMethodCallHandler((call) {
      print('uninstall ${call.method}');

      switch (call.method) {
        case "onPackageRemovedReceive":
          {
            for (var e in packageRemovedReceivedCallbacks) {
              e.call(call.arguments);
            }
            packageRemovedReceivedCallbacks.clear();
            break;
          }
        case "onUninstallResult":
          {
            for (var e in uninstallResultCallbacks) {
              var arguments = call.arguments as Map<String, dynamic>;
              e(arguments["success"]);
            }
            uninstallResultCallbacks.clear();
          }
          break;
        default:
          UnimplementedError("${call.method} is not implemented");
      }
      return Future.value();
    });
  }

  /// The method channel used to interact with the native platform.
  @visibleForTesting
  MethodChannel methodChannel = const MethodChannel('app_manager');

  @override
  Future<String> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version ?? "";
  }

  @override
  Future<T> invokeMethod<T>(String method, [dynamic arguments]) async =>
      (await methodChannel.invokeMethod<T>(method, arguments))!;

  @override
  Future<List<dynamic>> getAllApplications() =>
      invokeMethod("getAllApplications");

  @override
  Future<String> getApplicationLabel(String packageName) async =>
      await invokeMethod<String>(
          "getApplicationLabel", {"packageName": packageName});

  @override
  Future<Uint8List> getApplicationIconBitmap(String packageName) async =>
      await invokeMethod<Uint8List>(
          "getApplicationIconBitmap", {"packageName": packageName});

  @override
  Future<String> getAppData() async {
    final version = await methodChannel.invokeMethod<String>('getAppData');
    return version ?? "";
  }

  @override
  Future<String> getVisibleCaches() async {
    final version =
        await methodChannel.invokeMethod<String>('getVisibleCaches');
    return version ?? "";
  }

  @override
  Future<String> getHiddenCaches() async {
    final version = await methodChannel.invokeMethod<String>('getHiddenCaches');
    return version ?? "";
  }

  @override
  Future<String> freeUpRam() async {
    final version = await methodChannel.invokeMethod<String>('freeUpRam');
    return version ?? "";
  }

  @override
  Future<String> getRunningApp() {
    // TODO: implement getRunningApp
    throw UnimplementedError();
  }

  @override
  Future<String> killApp(String packageName) {
    // TODO: implement killApp
    throw UnimplementedError();
  }

  @override
  Future<String> getAllSize() {
    // TODO: implement getAllSize
    throw UnimplementedError();
  }

  @override
  Future<String> getIconFolderApp(String name) {
    // TODO: implement getIconFolderApp
    throw UnimplementedError();
  }

  @override
  Future<String> getIconPackage(String package) {
    // TODO: implement getIconPackage
    throw UnimplementedError();
  }

  @override
  Future<int> getUsageDataApps(String packageName) async {
    final version = await methodChannel
        .invokeMethod<int>('getUsageDataApps', {"packageName": packageName});
    return version ?? 0;
  }

  @override
  Future<void> collectAllEvents(List<String> packagesNameList,
      int startTimeInEpoch, int endTimeInEpoch) async {
    methodChannel.invokeMethod<void>(
      'collectAllEvents',
      {
        "packagesNameList": packagesNameList,
        "startTimeInEpoch": startTimeInEpoch,
        "endTimeInEpoch": endTimeInEpoch
      },
    );
  }

  @override
  Future<int> getLastAppUsageTime(String packageName) async {
    final result =
        await methodChannel.invokeMethod<int>('getLastAppUsageTime', {
      "packageName": packageName,
    });
    return result ?? 0;
  }

  @override
  Future<String> getAppUsageInfo(
      String packageName, int startTimeInEpoch, int endTimeInEpoch) async {
    final result = await methodChannel.invokeMethod<String>('getAppUsageInfo', {
      "packageName": packageName,
      "startTimeInEpoch": startTimeInEpoch,
      "endTimeInEpoch": endTimeInEpoch
    });
    return result ?? "";
  }

  @override
  Future<Map> getAppsUsageInfo(int startTimeInEpoch, int endTimeInEpoch) async {
    final result = await methodChannel.invokeMethod<Map>('getAppsUsageInfo', {
      "startTimeInEpoch": startTimeInEpoch,
      "endTimeInEpoch": endTimeInEpoch
    });
    return result ?? {};
  }

  @override
  Future<Map> getAppSize(
      String packageName, void Function(AppInfoSize) callback) async {
    methodChannel.setMethodCallHandler((call) {
      switch (call.method) {
        case "returnAppCapacity": // for API < 26
          {
            Map appInfoSizeMap = call.arguments;
            callback(AppInfoSize.fromJson(
                Map<String, dynamic>.from(appInfoSizeMap)));
          }
      }
      var t;
      return t;
    });

    return await invokeMethod<Map>('getAppSize', {"packageName": packageName});
  }

  @override
  Future<void> runAppGrowingService() async {
    methodChannel.invokeMethod<void>('runAppGrowingService');
  }

  @override
  Future<void> runBatteryAnalysisService() async {
    methodChannel.invokeMethod<void>('runBatteryAnalysisService');
  }

  @override
  Future<int> getTimeRemainingForAppGrowingAnalysis() async {
    return await methodChannel
            .invokeMethod<int>('getTimeRemainingForAppGrowingAnalysis') ??
        0;
  }

  @override
  Future<int> getAppSizeGrowingInByte(String packageName, int inDays,
      void Function(int differentInSize) callback) async {
    methodChannel.setMethodCallHandler((call) {
      switch (call.method) {
        case "returnDifferentInSize": // for API < 26
          {
            int differentInSize = call.arguments;
            callback(differentInSize);
          }
      }
      var t;
      return t;
    });

    return await invokeMethod<int>('getAppSizeGrowingInByte',
        {"packageName": packageName, "inDays": inDays});
  }

  @override
  Future<int> getTimeRemainingForBatteryAnalysis() async {
    return await methodChannel
            .invokeMethod<int>('getTimeRemainingForBatteryAnalysis') ??
        0;
  }

  @override
  Future<Map<dynamic, dynamic>> getBatteryUsagePercentageInOneDay() async {
    return await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
            'getBatteryUsagePercentageInOneDay') ??
        {};
  }

  @override
  Future<Map<dynamic, dynamic>> getBatteryUsagePercentageInSevenDays() async {
    return await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
            'getBatteryUsagePercentageInSevenDays') ??
        {};
  }

  @override
  Future<List<dynamic>> getBatteryAnalysisAllRowsForTest() async {
    return await methodChannel
            .invokeMethod<List<dynamic>>('getBatteryAnalysisAllRowsForTest') ??
        [];
  }

  @override
  Future<int> getUnnecessaryData() => invokeMethod<int>('getUnnecessaryData');

  @override
  Future<AppType> getApplicationType(String packageName) async {
    final version = await methodChannel.invokeMethod<AppType>(
        'getApplicationType', {"packageName": packageName});
    return version ?? AppType.installed;
  }

  @override
  Future<int> countNotificationsInRange(String packageName,
          int startTimeEpochMillis, int endTimeEpochMillis) =>
      invokeMethod<int>(
        'countNotificationsInRange',
        {
          "packageName": packageName,
          "startTimeEpochMillis": startTimeEpochMillis,
          "endTimeEpochMillis": endTimeEpochMillis,
        },
      );

  @override
  Future<Map<dynamic, dynamic>> countNotificationOfAllPackagesInRange(
          int startTimeEpochMillis, int endTimeEpochMillis) =>
      invokeMethod<Map<dynamic, dynamic>>(
        'countNotificationOfAllPackagesInRange',
        {
          "startTimeEpochMillis": startTimeEpochMillis,
          "endTimeEpochMillis": endTimeEpochMillis,
        },
      );

  @override
  Future<void> registerPackageRemovedReceiver(
      void Function(String removedPackage) onReceive) async {
    methodChannel.setMethodCallHandler((call) {
      switch (call.method) {
        case "onPackageRemovedReceive":
          {
            onReceive(call.arguments);
          }
      }
      var t;
      return t;
    });

    methodChannel.invokeMethod<void>('registerPackageRemovedReceiver');
  }

  @override
  Future<void> unregisterPackageRemovedReceiver() async {
    methodChannel.invokeMethod<void>('unregisterPackageRemovedReceiver');
  }

  @override
  Future<bool> uninstall(String packageName) async {
    methodChannel.setMethodCallHandler((call) {
      switch (call.method) {
        case "onPackageRemovedReceive":
          {
            for (var e in packageRemovedReceivedCallbacks) {
              e.call(call.arguments);
            }
            packageRemovedReceivedCallbacks.clear();
            break;
          }
        case "onUninstallResult":
          {
            for (var e in uninstallResultCallbacks) {
              e.call(call.arguments);
            }
            uninstallResultCallbacks.clear();
          }
          break;
        default:
          UnimplementedError("${call.method} is not implemented");
      }
      return Future.value();
    });
    final completer = Completer<bool>();
    uninstallResultCallbacks.add((value) async {
      completer.complete(value);
    });

    // print('uninstall $packageName');
    await methodChannel
        .invokeMethod<dynamic>("uninstall", {'packageName': packageName});

    final result = await completer.future;
    // print('uninstall $packageName $result');

    return result;
  }

  @override
  Future<Uint8List> getApkFileIcon(String apkPath) async {
    return await methodChannel
            .invokeMethod<Uint8List>('getApkFileIcon', {"path": apkPath}) ??
        Uint8List(0);
  }
}
