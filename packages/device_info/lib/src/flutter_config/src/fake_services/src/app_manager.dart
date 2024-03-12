import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';

class AppManager {
  static Future<List<PackageInfo>> getAllApplications() async {
    var applicationsMap =
        await DeviceInfoPlatform.instance.getAllApplications();
    return applicationsMap
        .map((e) => PackageInfo.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<String> getLabel(String packageName) async {
    return await DeviceInfoPlatform.instance.getApplicationLabel(packageName);
  }

  static Future<Uint8List> getIcon(String packageName) async {
    return await DeviceInfoPlatform.instance
        .getApplicationIconBitmap(packageName);
  }
}
