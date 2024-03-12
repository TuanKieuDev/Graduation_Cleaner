import 'dart:convert';

import 'package:device_info/device_info.dart';
import 'package:device_info/src/native_connection/src/native_calling/app_manager_platform_interface.dart';
import 'package:flutter/services.dart';

class AppManager {
  Future<List<PackageInfo>> getAllApplications() async {
    var applicationsMap =
        await AppManagerPlatform.instance.getAllApplications();
    return applicationsMap
        .map((e) => PackageInfo.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<String> getLabel(String packageName) async {
    return await AppManagerPlatform.instance.getApplicationLabel(packageName);
  }

  Future<Uint8List> getIcon(String packageName) async {
    return await AppManagerPlatform.instance
        .getApplicationIconBitmap(packageName);
  }

  Future<void> refreshAllEvents(List<PackageInfo> apps) async {
    int endTime = DateTime.now().millisecondsSinceEpoch;
    int startTime = endTime - const Duration(days: 7).inMilliseconds;

    return await AppManagerPlatform.instance.collectAllEvents(
      apps.map((e) => e.packageName).toList(),
      startTime,
      endTime,
    );
  }

  Future<DateTime> getLastAppUsageTime(String packageName) async {
    var epochTime =
        await AppManagerPlatform.instance.getLastAppUsageTime(packageName);
    return DateTime.fromMillisecondsSinceEpoch(epochTime);
  }

  Future<Map<String, DateTime>> getLastAppsUsageTime(
      List<PackageInfo> apps) async {
    Map<String, DateTime> lastAppsUsageTime = {};

    List<Future<DateTime>> futures = [];
    for (var packageInfo in apps) {
      final future = getLastAppUsageTime(packageInfo.packageName);
      future.then(
        (value) {
          lastAppsUsageTime[packageInfo.packageName] = value;
          return value;
        },
      );
      futures.add(future);
    }

    await Future.wait(futures);

    return lastAppsUsageTime;
  }

  Future<int> getUsageDataApps(String packageName) async {
    return await AppManagerPlatform.instance.getUsageDataApps(packageName);
  }

  Future<List<AppInfoUsage>> getAppsUsageInfo(List<PackageInfo> apps,
      [UsagePeriod? usagePeriod]) async {
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    int startTimeInEpoch;
    if (usagePeriod == null) {
      startTimeInEpoch = currentTime - const Duration(days: 30).inMilliseconds;
    } else {
      switch (usagePeriod) {
        case UsagePeriod.day:
          {
            startTimeInEpoch =
                currentTime - const Duration(days: 1).inMilliseconds;
            break;
          }
        case UsagePeriod.week:
          {
            startTimeInEpoch =
                currentTime - const Duration(days: 7).inMilliseconds;
            break;
          }
      }
    }

    List<AppInfoUsage> appsUsageInfo = [];

    List<Future<AppInfoUsage>> futures = [];
    for (var packageInfo in apps) {
      final future = getAppUsageInfo(
          packageInfo.packageName, startTimeInEpoch, currentTime);
      future.then(
        (value) {
          appsUsageInfo.add(value);
          return value;
        },
      );
      futures.add(future);
    }

    await Future.wait(futures);

    return appsUsageInfo;
  }

  Future<List<TimeLineUsageInfo>> getTimelineOfApp(UsagePeriod usagePeriod,
      [String packageName = ""]) async {
    List<TimeLineUsageInfo> list = [];

    DateTime dateNow = DateTime.now();
    int currentTime = dateNow.millisecondsSinceEpoch;

    int length = 0;
    int duration;

    switch (usagePeriod) {
      case UsagePeriod.day:
        {
          length = 24;
          duration = const Duration(hours: 1).inMilliseconds;

          currentTime = DateTime(dateNow.year, dateNow.month, dateNow.day,
                  dateNow.hour, 0, 0, 0, 0)
              .millisecondsSinceEpoch;
          break;
        }
      case UsagePeriod.week:
        {
          length = 7;
          duration = const Duration(days: 1).inMilliseconds;

          currentTime =
              DateTime(dateNow.year, dateNow.month, dateNow.day, 0, 0, 0, 0, 0)
                  .millisecondsSinceEpoch;
          break;
        }
    }

    List<Future<TimeLineUsageInfo>> futures = [];

    for (int i = length; i > 0; i--) {
      DateTime dateTime;
      Future<AppInfoUsage> appUsageInfo;
      Future<TimeLineUsageInfo> future;

      if (i == length && usagePeriod == UsagePeriod.week) {
        dateTime =
            DateTime.fromMillisecondsSinceEpoch(dateNow.millisecondsSinceEpoch);
        appUsageInfo = getAppUsageInfo(
            packageName, currentTime, dateNow.millisecondsSinceEpoch);

        future = getAppUsageTimeline(dateTime, appUsageInfo);
      } else {
        dateTime = DateTime.fromMillisecondsSinceEpoch(currentTime - 1);
        appUsageInfo =
            getAppUsageInfo(packageName, currentTime - duration, currentTime);

        future = getAppUsageTimeline(dateTime, appUsageInfo);

        currentTime -= duration;
      }

      future.then((value) {
        list.add(value);
        return value;
      });

      futures.add(future);
    }

    await Future.wait(futures);

    list.sort(((a, b) => a.dateTime.millisecondsSinceEpoch
        .compareTo(b.dateTime.millisecondsSinceEpoch)));
    return list;
  }

  Future<TimeLineUsageInfo> getAppUsageTimeline(
      DateTime dateTime, Future<AppInfoUsage> appInfoUsage) async {
    return TimeLineUsageInfo(
      dateTime: dateTime,
      appUsageTime: (await appInfoUsage).totalTimeSpent,
    );
  }

  Future<List<String>> getAppsUnused(
      List<PackageInfo> apps, UsagePeriod periodType) async {
    List<Future<bool>> futures = [];
    List<String> listUnused = [];

    for (var packageInfo in apps) {
      futures
          .add(isAppUnused(packageInfo.packageName, periodType).then((value) {
        if (value) {
          listUnused.add(packageInfo.packageName);
        }
        return value;
      }));
    }

    return Future.wait(futures).then((results) {
      return listUnused;
    });
  }

  Future<bool> isAppUnused(String packageName, UsagePeriod periodType) async {
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    int startTimeInEpoch;
    switch (periodType) {
      case UsagePeriod.day:
        {
          startTimeInEpoch =
              currentTime - const Duration(days: 1).inMilliseconds;
          break;
        }
      case UsagePeriod.week:
        {
          startTimeInEpoch =
              currentTime - const Duration(days: 7).inMilliseconds;
          break;
        }
    }

    AppInfoUsage appInfoUsage =
        await getAppUsageInfo(packageName, startTimeInEpoch, currentTime);

    return appInfoUsage.totalOpened == 0;
  }

  Future<AppInfoUsage> getAppUsageInfo(
      String packageName, int startTimeInEpoch, int endTimeInEpoch) async {
    String result = await AppManagerPlatform.instance
        .getAppUsageInfo(packageName, startTimeInEpoch, endTimeInEpoch);
    return AppInfoUsage.fromJson(jsonDecode(result));
  }

  Future<AppInfoSize> getAppSize(
      String packageName, void Function(AppInfoSize) callback) async {
    final appInfoSizeMap =
        await AppManagerPlatform.instance.getAppSize(packageName, callback);
    return AppInfoSize.fromJson(Map<String, dynamic>.from(appInfoSizeMap));
  }

  Future<void> runAppGrowingService() async {
    return await AppManagerPlatform.instance.runAppGrowingService();
  }

  Future<void> runBatteryAnalysisService() async {
    return await AppManagerPlatform.instance.runBatteryAnalysisService();
  }

  Future<int> getTimeRemainingForAppGrowingAnalysis() async {
    return await AppManagerPlatform.instance
        .getTimeRemainingForAppGrowingAnalysis();
  }

  Future<int> getAppSizeGrowingInByte(String packageName, int inDays,
      void Function(int differentInSize) callback) async {
    return await AppManagerPlatform.instance
        .getAppSizeGrowingInByte(packageName, inDays, callback);
  }

  Future<QuickBoostInfoOptimization> freeUpRam() async {
    Map<String, dynamic> values =
        json.decode(await AppManagerPlatform.instance.freeUpRam());

    return QuickBoostInfoOptimization.fromJson(values);
  }

  Future<int> getTimeRemainingForBatteryAnalysis() async {
    return await AppManagerPlatform.instance
        .getTimeRemainingForBatteryAnalysis();
  }

  Future<Map<String, double>> getAppsBatteryUsagePercentage(
      UsagePeriod periodType) async {
    var result = {};

    if (periodType == UsagePeriod.day) {
      result =
          await AppManagerPlatform.instance.getBatteryUsagePercentageInOneDay();
    }

    if (periodType == UsagePeriod.week) {
      result = await AppManagerPlatform.instance
          .getBatteryUsagePercentageInSevenDays();
    }

    Map<String, double> newMap = {};
    result.forEach((key, value) => newMap[key] = value);

    return newMap;
  }

  Future<List<RowDataForTest>> getBatteryAnalysisAllRowsForTest() async {
    List<RowDataForTest> listRow = [];

    var appsBatteryUsage =
        await AppManagerPlatform.instance.getBatteryAnalysisAllRowsForTest();
    for (var element in appsBatteryUsage) {
      listRow.add(RowDataForTest.fromJson(jsonDecode(element)));
    }
    return listRow;
  }

  Future<int> getUnnecessaryData() async {
    return await AppManagerPlatform.instance.getUnnecessaryData();
  }

  Future<int> countNotificationsByUsagePeriod(
      String packageName, UsagePeriod usagePeriod) async {
    int endTime = DateTime.now().millisecondsSinceEpoch;

    int startTime = endTime - const Duration(days: 7).inMilliseconds;

    switch (usagePeriod) {
      case UsagePeriod.day:
        startTime = endTime - const Duration(days: 1).inMilliseconds;
        break;
      case UsagePeriod.week:
        startTime = endTime - const Duration(days: 7).inMilliseconds;
        break;
    }

    return await AppManagerPlatform.instance
        .countNotificationsInRange(packageName, startTime, endTime);
  }

  Future<Map<String, int>> countNotificationOfAllPackagesByUsagePeriod(
      UsagePeriod usagePeriod) async {
    int endTime = DateTime.now().millisecondsSinceEpoch;

    int startTime = endTime - const Duration(days: 7).inMilliseconds;

    switch (usagePeriod) {
      case UsagePeriod.day:
        startTime = endTime - const Duration(days: 1).inMilliseconds;
        break;
      case UsagePeriod.week:
        startTime = endTime - const Duration(days: 7).inMilliseconds;
        break;
    }

    var result = await AppManagerPlatform.instance
        .countNotificationOfAllPackagesInRange(startTime, endTime);

    Map<String, int> newMap = {};
    result.forEach((key, value) => newMap[key] = value);
    return newMap;
  }

  Future<List<NotificationTimelineInfo>> getNotificationTimeline(
      UsagePeriod usagePeriod) async {
    List<NotificationTimelineInfo> timelineList = [];

    DateTime dateNow = DateTime.now();
    int currentTime = dateNow.millisecondsSinceEpoch;

    int length = 0;
    int duration;

    switch (usagePeriod) {
      case UsagePeriod.day:
        {
          length = 24;
          duration = const Duration(hours: 1).inMilliseconds;

          currentTime = DateTime(dateNow.year, dateNow.month, dateNow.day,
                  dateNow.hour, 0, 0, 0, 0)
              .millisecondsSinceEpoch;
          break;
        }
      case UsagePeriod.week:
        {
          length = 7;
          duration = const Duration(days: 1).inMilliseconds;

          currentTime =
              DateTime(dateNow.year, dateNow.month, dateNow.day, 0, 0, 0, 0, 0)
                  .millisecondsSinceEpoch;
          break;
        }
    }

    List<Future<int>> futures = [];

    for (int i = length; i > 0; i--) {
      DateTime dateTime;
      Future<int> future;

      if (i == length && usagePeriod == UsagePeriod.week) {
        dateTime =
            DateTime.fromMillisecondsSinceEpoch(dateNow.millisecondsSinceEpoch);

        future = calculateTotalNotificationsInRange(
            currentTime, dateNow.millisecondsSinceEpoch);
      } else {
        dateTime = DateTime.fromMillisecondsSinceEpoch(currentTime - 1);

        future = calculateTotalNotificationsInRange(
            currentTime - duration, currentTime);

        currentTime -= duration;
      }

      future.then(
        (totalNotificationsInRange) {
          final notificationTimelineElement = NotificationTimelineInfo(
              dateTime: dateTime,
              notificationQuantity: totalNotificationsInRange);

          timelineList.add(notificationTimelineElement);

          return totalNotificationsInRange;
        },
      );

      futures.add(future);
    }

    await Future.wait(futures);

    timelineList.sort(((a, b) => a.dateTime.millisecondsSinceEpoch
        .compareTo(b.dateTime.millisecondsSinceEpoch)));

    return timelineList;
  }

  Future<int> calculateTotalNotificationsInRange(
      int startTime, int endTime) async {
    Map<dynamic, dynamic> notificationQualityMap = await AppManagerPlatform
        .instance
        .countNotificationOfAllPackagesInRange(startTime, endTime);

    int totalNotifications = 0;
    notificationQualityMap.forEach((key, value) {
      totalNotifications += value as int;
    });

    return totalNotifications;
  }

  Future<void> registerPackageRemovedReceiver(
      {required void Function(String removedPackage) onReceive}) async {
    return await AppManagerPlatform.instance
        .registerPackageRemovedReceiver(onReceive);
  }

  Future<void> unregisterPackageRemovedReceiver() async {
    return await AppManagerPlatform.instance.unregisterPackageRemovedReceiver();
  }

  Future<bool> uninstall(String packageName) async {
    return await AppManagerPlatform.instance.uninstall(packageName);
  }

  Future<Uint8List> getApkFileIcon(String apkPath) async {
    return await AppManagerPlatform.instance.getApkFileIcon(apkPath);
  }
}
