import 'package:phone_cleaner/main.dart';
import 'package:phone_cleaner/src/features/apps/controllers/list_app_controller.dart';
import 'package:phone_cleaner/src/features/features.dart';
import 'package:collection/collection.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../commons/commons.dart';
import '../models/bar_chart_data.dart';

part 'apps_usage_controller.g.dart';

@riverpod
class AppsUsageController extends _$AppsUsageController {
  late AppManager _appUsageManager;

  @override
  FutureOr<List<AppsUsagePeriodData>> build() {
    final listAppController = ref.watch(listAppControllerProvider.future);
    _appUsageManager = ref.watch(appRepository);

    return Future.wait([listAppController]).then((value) async {
      final appsPackageInfo = value[0];
      await _appUsageManager.refreshAllEvents(appsPackageInfo);
      final data = ref.read(appsControllerProvider.future);

      final barChartDataW = getAppBarChartData(UsagePeriod.week);
      final barChartDataD = getAppBarChartData(UsagePeriod.day);
      final weeklyUsageData =
          _getAppsUsageData(appsPackageInfo, PeriodType.week);
      final dailyUsageData = _getAppsUsageData(appsPackageInfo, PeriodType.day);
      return Future.wait([
        weeklyUsageData,
        dailyUsageData,
        data,
        barChartDataW,
        barChartDataD
      ]).then((value) {
        final data1 = value[0] as List<AppInfoUsage>;
        final data2 = value[1] as List<AppInfoUsage>;
        final appsData = value[2] as AppsInfo;
        final barChartDataWeekly = value[3] as List<BarChartData>;
        final barChartDataDaily = value[4] as List<BarChartData>;
        final weeklyData = appsData.apps
            .mapIndexed((i, e) => e.copyWith(
                timeOpened: data1[i].totalOpened,
                totalTimeSpent: data1[i].totalTimeSpent))
            .toList();
        final dailyData = appsData.apps
            .mapIndexed((i, e) => e.copyWith(
                timeOpened: data2[i].totalOpened,
                totalTimeSpent: data2[i].totalTimeSpent))
            .toList();
        return [
          AppsUsagePeriodData(
            usageData: weeklyData,
            categories: [
              AppsUsageCategory(
                items: _sortTimeOpenedUsage(weeklyData),
                usageType: SortType.timeOpened,
              ),
              AppsUsageCategory(
                items: _sortScreenTimeUsage(weeklyData),
                usageType: SortType.screenTime,
              ),
              AppsUsageCategory(
                items: _getUnusedUsage(weeklyData),
                usageType: SortType.unused,
              ),
            ],
            periodType: PeriodType.week,
            barChartData: barChartDataWeekly,
          ),
          AppsUsagePeriodData(
            usageData: dailyData,
            categories: [
              AppsUsageCategory(
                items: _sortTimeOpenedUsage(dailyData),
                usageType: SortType.timeOpened,
              ),
              AppsUsageCategory(
                items: _sortScreenTimeUsage(dailyData),
                usageType: SortType.screenTime,
              ),
              AppsUsageCategory(
                items: _getUnusedUsage(dailyData),
                usageType: SortType.unused,
              ),
            ],
            periodType: PeriodType.day,
            barChartData: barChartDataDaily,
          )
        ];
      });
    });
  }

  Future<List<AppInfoUsage>> _getAppsUsageData(
      List<PackageInfo> listPackages, PeriodType periodType) async {
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final startTime = periodType == PeriodType.week
        ? (currentTime - 7 * Duration.millisecondsPerDay)
        : (currentTime - Duration.millisecondsPerDay);
    List<AppInfoUsage> appUsageList;

    List<Future<AppInfoUsage>> futures = [];

    for (var packageName in listPackages) {
      final future = _appUsageManager.getAppUsageInfo(
          packageName.packageName, startTime, currentTime);

      future.then((appUsage) => appUsage);
      futures.add(future);
    }

    appUsageList = await Future.wait(futures);
    return appUsageList;
  }

  List<AppCheckboxItemData> _sortScreenTimeUsage(
      List<AppCheckboxItemData> apps) {
    apps.sort(((a, b) => b.totalTimeSpent.compareTo(a.totalTimeSpent)));
    return apps;
  }

  List<AppCheckboxItemData> _sortTimeOpenedUsage(
      List<AppCheckboxItemData> apps) {
    apps.sort(((a, b) => b.timeOpened.compareTo(a.timeOpened)));
    return apps;
  }

  List<AppCheckboxItemData> _getUnusedUsage(List<AppCheckboxItemData> apps) {
    return apps.where((element) => element.totalTimeSpent == 0).toList();
  }

  Future<List<BarChartData>> getAppBarChartData(UsagePeriod usagePeriod,
      [String? packageName]) async {
    final data = packageName != null
        ? await _appUsageManager.getTimelineOfApp(usagePeriod, packageName)
        : await _appUsageManager.getTimelineOfApp(usagePeriod);
    final timeValue = <AppsUsageInfo>[];
    for (var item in data) {
      timeValue.add(
        AppsUsageInfo(
          totalTimeUsage: item.appUsageTime,
          dateTime: usagePeriod == UsagePeriod.week
              ? item.dateTime.weekday
              : item.dateTime.hour,
        ),
      );
    }

    var usageData = timeValue.map((data) {
      return BarChartData(
        x: data.dateTime,
        y: data.totalTimeUsage.millisecond.value.toDouble(),
        gradient: _getGradientColorChart(
          data.totalTimeUsage.millisecond
              .to(TimeUnitSymbol.hour)
              .value
              .toDouble(),
        ),
      );
    });
    return usageData.toList();
  }

  Gradient _getGradientColorChart(double value) {
    if (value > 6) {
      return const LinearGradient(
        colors: [Color(0xFFF43B2E), Color(0xFFFF5A7B)],
        stops: [13.64 / 100, 89.9 / 100],
        begin: Alignment(1, 1),
        end: Alignment(-1, -1),
      );
    } else if (value > 4) {
      return const LinearGradient(
        colors: [Color(0xFFFF7728), Color(0xFFFF984C)],
        stops: [5.79 / 100, 88.98 / 100],
        begin: Alignment(1, 1),
        end: Alignment(-1, -1),
      );
    } else if (value > 2) {
      return const LinearGradient(
        colors: [Color(0xFF3258F3), Color(0xFF2DA6FF)],
        stops: [2.38 / 100, 102.38 / 100],
        begin: Alignment(1, 1),
        end: Alignment(-1, -1),
      );
    } else {
      return const LinearGradient(
        colors: [Color(0xFF33A752), Color(0xFF8DCB9E)],
        stops: [5.79 / 100, 88.98 / 100],
        begin: Alignment(1, 1),
        end: Alignment(-1, -1),
      );
    }
  }

  void toggleAppStateUsage(int index) {
    final originalValue = state.value![0];
    final originalCategory = originalValue.categories[2];
    final item = originalCategory.items[index];
    final newAppState = !item.checked;
    final newCategory = [...originalValue.categories];
    final newItems = [...originalValue.categories[2].items];

    newItems[index] = item.copyWith(checked: newAppState);
    newCategory[2] = originalCategory.copyWith(items: newItems);
    state.value![0] = originalValue.copyWith(categories: newCategory);

    state = AsyncData(state.value!);
  }

  int calculateTotalAppsUnusedChecked() {
    int total = 0;
    for (var item in state.value![0].categories[2].items) {
      if (item.checked) {
        total++;
      }
    }
    return total;
  }

  DigitalUnit getTotalAppsSize(List<AppCheckboxItemData> apps) {
    return apps.fold(
        0.kb, (previousValue, element) => previousValue + element.totalSize);
  }

  DigitalUnit getTotalAppsSizeChecked(List<AppCheckboxItemData> apps) {
    return apps.where((element) => element.checked == true).fold(
        0.kb, (previousValue, element) => previousValue + element.totalSize);
  }
}
