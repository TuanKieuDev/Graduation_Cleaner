import 'package:device_info/device_info.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../commons/commons.dart';

part 'apps_info.freezed.dart';

@freezed
class AppsInfo with _$AppsInfo {
  const AppsInfo._();

  factory AppsInfo({
    @Default([]) List<PackageInfo> appsPackageInfo,
    @Default([]) List<AppCheckboxItemData> apps,
  }) = _AppsInfo;

  DigitalUnit get totalAppsSize => apps.fold(
      0.kb, (previousValue, element) => previousValue + element.totalSize);

  List<AppCheckboxItemData> get systemApps =>
      apps.where((e) => e.appType == AppType.system).toList();

  List<AppCheckboxItemData> get installedApps =>
      apps.where((e) => e.appType == AppType.installed).toList();

  DigitalUnit get systemAppsSize => systemApps.fold(
      0.kb, (previousValue, element) => previousValue + element.totalSize);

  DigitalUnit get installedAppsSize => installedApps.fold(
      0.kb, (previousValue, element) => previousValue + element.totalSize);
}

// Map<packageName, {}>


// percentage DigitalUnit
