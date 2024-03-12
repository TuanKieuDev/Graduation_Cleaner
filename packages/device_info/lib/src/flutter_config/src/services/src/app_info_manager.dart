import 'dart:convert';

import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';

class AppInfoManager {
  final cleanerAppInfo = DeviceInfo();

  Future<List<AppInfo>> getListAppInfo() async {
    String values = await cleanerAppInfo.getListAppInfo();

    List<AppInfo> listAppInfo = (jsonDecode(values) as List)
        .map((data) => AppInfo.fromJson(data))
        .toList();

    return listAppInfo;
  }

  Future<Uint8List> getIconPackage(String package) async {
    String values = await cleanerAppInfo.getIconPackage(package);

    return base64Decode(values);
  }

  Future<int> getUsageDataApps(String package) async {
    int values = await cleanerAppInfo.getUsageDataApps(package);

    return values;
  }

  Future<List<AppInfoSize>> getAllSize() async {
    String values = await cleanerAppInfo.getAllSize();

    List<AppInfoSize> listAppInfoSize = (jsonDecode(values) as List)
        .map((data) => AppInfoSize.fromJson(data))
        .toList();

    return listAppInfoSize;
  }

  Future<List<AppInfo>> getRunningApp() async {
    String values = await cleanerAppInfo.getRunningApp();

    List<AppInfo> listRunningApp = (jsonDecode(values) as List)
        .map((data) => AppInfo.fromJson(data))
        .toList();

    return listRunningApp;
  }

  Future<QuickBoostInfoOptimization> killApp() async {
    Map<String, dynamic> values = json.decode(await cleanerAppInfo.killApp());

    return QuickBoostInfoOptimization.fromJson(values);
  }
}
