import 'dart:collection';
import 'dart:convert';

import 'package:device_info/device_info.dart';

class AppInfoUsageManager {
  final cleanerAppInfo = DeviceInfo();

  Future<List<AppInfoUsage>> getUsageLast24Hours() async {
    String values = await cleanerAppInfo.getUsageLast24Hours();

    List<AppInfoUsage> listAppInfoSize = (jsonDecode(values) as List)
        .map((data) => AppInfoUsage.fromJson(data))
        .toList();

    return listAppInfoSize;
  }

  Future<List<AppInfoUsage>> getUsageLast7Days() async {
    String values = await cleanerAppInfo.getUsageLast7Days();
    List<AppInfoUsage> listAppInfoSize = (jsonDecode(values) as List)
        .map((data) =>
            AppInfoUsage.fromJson(HashMap<String, dynamic>.from(data)))
        .toList();

    return listAppInfoSize;
  }

  Future<List<TimeLineUsageInfo>> timelineUsageStats(
      String package, int usageManager) async {
    String values =
        await cleanerAppInfo.timelineUsageStats(package, usageManager);

    List<TimeLineUsageInfo> listAppInfoSize = (jsonDecode(values) as List)
        .map((data) => TimeLineUsageInfo.fromJson(data))
        .toList();

    return listAppInfoSize;
  }
}
