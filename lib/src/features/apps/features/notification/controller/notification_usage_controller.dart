import 'package:phone_cleaner/main.dart';
import 'package:phone_cleaner/src/features/apps/apps.dart';
import 'package:phone_cleaner/src/features/apps/features/notification/models/notification_count_info.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_usage_controller.g.dart';

@riverpod
class NotificationUsageController extends _$NotificationUsageController {
  @override
  Future<NotificationCountInfo> build() {
    final appData = ref.watch(appsControllerProvider.future);
    final notificationCountWeek = getNotificationCountWeekly();
    final barChartData = getNotificationBarChartData();
    return Future.wait([appData, notificationCountWeek, barChartData])
        .then((value) {
      final apps = (value[0] as AppsInfo).apps;
      final notificationMapWeekly = value[1] as Map<String, int>;
      final barChart = value[2] as List<BarChartData>;

      final appsWithNotificationCountWeekly = apps
          .map((e) => e.copyWith(
              notificationCount: notificationMapWeekly[e.packageName] ?? 0))
          .toList();
      appsWithNotificationCountWeekly
          .sort((a, b) => b.notificationCount.compareTo(a.notificationCount));

      return NotificationCountInfo(
        dataWithNotificationWeekly: appsWithNotificationCountWeekly,
        barChartData: barChart,
      );
    });
  }

  Future<Map<String, int>> getNotificationCountWeekly() {
    return ref
        .watch(appRepository)
        .countNotificationOfAllPackagesByUsagePeriod(UsagePeriod.week);
  }

  void deletePathsInState(List<String> paths) {
    update((state) {
      final appsData = state.dataWithNotificationWeekly.toList();
      appsData.removeWhere((element) => paths.contains(element.packageName));

      return state.copyWith(
        dataWithNotificationWeekly: appsData,
      );
    });
  }

  Future<List<BarChartData>> getNotificationBarChartData() async {
    final data = await AppManager().getNotificationTimeline(UsagePeriod.week);

    var usageData = data.map((data) {
      return BarChartData(
        x: data.dateTime.weekday,
        y: data.notificationQuantity.toDouble(),
        gradient: _getGradientColorChart(
          data.notificationQuantity,
        ),
      );
    });
    return usageData.toList();
  }

  Gradient _getGradientColorChart(int value) {
    if (value > 100) {
      return const LinearGradient(
        colors: [Color(0xFFF43B2E), Color(0xFFFF5A7B)],
        stops: [13.64 / 100, 89.9 / 100],
        begin: Alignment(1, 1),
        end: Alignment(-1, -1),
      );
    } else if (value > 50) {
      return const LinearGradient(
        colors: [Color(0xFFFF7728), Color(0xFFFF984C)],
        stops: [5.79 / 100, 88.98 / 100],
        begin: Alignment(1, 1),
        end: Alignment(-1, -1),
      );
    } else if (value > 20) {
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
}
