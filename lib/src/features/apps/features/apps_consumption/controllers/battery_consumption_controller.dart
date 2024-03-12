import 'package:phone_cleaner/main.dart';
import 'package:phone_cleaner/src/features/apps/apps.dart';
import 'package:device_info/device_info.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/battery_consumption_state.dart';

part 'battery_consumption_controller.g.dart';

@riverpod
class BatteryConsumptionController extends _$BatteryConsumptionController {
  @override
  FutureOr<BatteryConsumptionState> build() async {
    final appManager = ref.watch(appRepository);
    final timeRemaining = await appManager.getTimeRemainingForBatteryAnalysis();

    if (timeRemaining > 0) {
      return BatteryConsumptionState(apps: [], timeRemaining: timeRemaining);
    }

    final batteryPercentageFuture =
        appManager.getAppsBatteryUsagePercentage(UsagePeriod.week);
    final apps = ref.watch(appsControllerProvider.future);

    return Future.wait([apps, batteryPercentageFuture]).then((value) {
      final apps = (value[0] as AppsInfo).apps;
      final batteryPercentage = value[1] as Map<String, double>;
      final appsWithBatteryConsumption = apps
          .map(
            (e) => e.copyWith(
                batteryPercentage: batteryPercentage[e.packageName] ?? 0),
          )
          .toList();
      return BatteryConsumptionState(
        timeRemaining: timeRemaining,
        apps: appsWithBatteryConsumption,
      );
    });
  }
}
