import 'dart:typed_data';

import 'package:phone_cleaner/di/injector.dart';
import 'package:phone_cleaner/main.dart';
import 'package:phone_cleaner/services/preference_services/shared_preferences_manager.dart';
import 'package:phone_cleaner/src/features/features.dart';
import 'package:phone_cleaner/src/features/apps/controllers/list_app_controller.dart';
import 'package:device_info/device_info.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../commons/commons.dart';

part 'apps_controller.g.dart';

@riverpod
class AppsController extends _$AppsController {
  late AppManager _appManager;
  @override
  FutureOr<AppsInfo> build() {
    _appManager = ref.watch(appRepository);

    return _fetchData();
  }

  Future<AppsInfo> _fetchData() async {
    final appCheckboxes = <AppCheckboxItemData>[];
    List<Future> futures = [];

    final apps = await ref.watch(listAppControllerProvider.future);
    // appLogger.debug('app : ${apps.length}');
    final previousApps = state.value?.apps.map((e) => e.packageName).toList();
    // appLogger.debug('AppsController._fetchData: ${previousApps?.length}');

    for (var app in apps) {
      if (previousApps != null && previousApps.contains(app.packageName)) {
        final previousApp = state.value!.apps
            .firstWhere((element) => element.packageName == app.packageName);
        appCheckboxes.add(previousApp);
        continue;
      }

      final future =
          _fetchAppData(app).then((value) => appCheckboxes.add(value));
      futures.add(future);
    }

    await Future.wait(futures);

    return AppsInfo(
      appsPackageInfo: apps,
      apps: appCheckboxes,
    );
  }

  Future<AppCheckboxItemData> _fetchAppData(PackageInfo app) async {
    final label1 = getLabelApp(app.packageName);
    final icon1 = getIconApp(app.packageName);
    final appInfoSize1 = getAppInfoSize(app.packageName);
    final dataUsed1 = getAppDataUsed(app.packageName);
    final lastUsed1 = getAppLastUsed(app.packageName);
    final future =
        Future.wait([label1, icon1, appInfoSize1, dataUsed1, lastUsed1])
            .then((value) {
      final appType = (app.appType == AppType.installed.description)
          ? AppType.installed
          : AppType.system;
      final label = value[0] as String;
      final icon = value[1] as Uint8List;
      final appInfoSize = value[2] as AppInfoSize;
      final dataUsed = value[3] as int;
      final lastUsed = value[4] as DateTime;

      return AppCheckboxItemData(
        packageName: app.packageName,
        name: label,
        dataUsed: dataUsed.bytes,
        iconData: icon,
        totalSize: appInfoSize.totalSize.bytes,
        appSize: appInfoSize.appSize.bytes,
        dataSize: appInfoSize.dataSize.bytes,
        cacheSize: appInfoSize.cacheSize.bytes,
        appType: appType,
        lastOpened: lastUsed,
      );
    });
    return future;
  }

  Future<Uint8List> getIconApp(String packageName) async {
    return await _appManager.getIcon(packageName);
  }

  Future<String> getLabelApp(String packageName) async {
    return await _appManager.getLabel(packageName);
  }

  Future<int> getAppDataUsed(String packageName) async {
    return await _appManager.getUsageDataApps(packageName);
  }

  Future<DateTime> getAppLastUsed(String packageName) async {
    return await _appManager.getLastAppUsageTime(packageName);
  }

  Future<AppInfoSize> getAppInfoSize(String packageName) async {
    return await _appManager.getAppSize(
        packageName, (appInfoSize) => appInfoSize);
  }

  bool hasCheckedApp(List<AppCheckboxItemData> apps) {
    return apps.any((element) => element.checked == true);
  }

  Map<String, AppCheckboxItemData> getAppData(
          String packageName, List<AppCheckboxItemData> apps) =>
      <String, AppCheckboxItemData>{
        packageName: apps.firstWhere((e) => e.packageName == packageName),
      };

  Future<int> getSizeChange(
      String packageName, PeriodType periodType, Function(int) callback) async {
    return await _appManager.getAppSizeGrowingInByte(
        packageName, periodType == PeriodType.week ? 7 : 1, callback);
  }

  List<AppCheckboxItemData> getCheckedApps() {
    final apps = state.value!.apps;
    return apps.where((element) => element.checked == true).toList();
  }

  Future<AppType> getAppType(PackageInfo app) async {
    // if (await isAppInIgnoreApps(app.packageName)) {
    //   return AppType.ignored;
    // } else {
    return (app.appType == AppType.installed.description)
        ? AppType.installed
        : AppType.system;
    // }
  }

  Future<bool> isAppInIgnoreApps(String packageName) async {
    final ignoreApps = await getIgnoreApps();
    return ignoreApps.contains(packageName);
  }

  Future<List<String>> getIgnoreApps() async {
    final ignoreApps =
        await injector.get<SharedPreferencesManager>().getIgnoreApps();
    return ignoreApps ?? [];
  }

  Future<void> saveAppsToIgnoredApps(List<String> packageNameList) async {
    var ignoreApps = state.value!.apps
        .where((element) => element.isIgnore == true)
        .map((e) => e.packageName)
        .toList();
    ignoreApps.addAll(packageNameList);
    ignoreApps = ignoreApps.toSet().toList();
    state = AsyncData(
      state.value!.copyWith(
        apps: state.value!.apps
            .map((e) => e.copyWith(
                  isIgnore: ignoreApps.contains(e.packageName) ? true : false,
                ))
            .toList(),
      ),
    );
    await injector.get<SharedPreferencesManager>().saveIgnoredApps(ignoreApps);
  }

  Future<void> removeAppsFromIgnoredApps(List<String> packageNames) async {
    var ignoreApps = state.value!.apps
        .where((element) => element.isIgnore == true)
        .where((element) => !packageNames.contains(element.packageName))
        .map((e) => e.packageName)
        .toList();
    state = AsyncData(
      state.value!.copyWith(
        apps: state.value!.apps.map((e) {
          return e.copyWith(
            isIgnore: ignoreApps.contains(e.packageName) ? true : false,
          );
        }).toList(),
      ),
    );
    await injector.get<SharedPreferencesManager>().saveIgnoredApps(ignoreApps);
  }
}
