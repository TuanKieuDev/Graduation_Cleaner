import 'package:phone_cleaner/src/features/apps/apps.dart';
import 'package:phone_cleaner/src/features/apps/features/apps_consumption/controllers/battery_consumption_controller.dart';
import 'package:phone_cleaner/src/features/apps/features/apps_consumption/models/battery_consumption_state.dart';
import 'package:phone_cleaner/src/features/features.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../commons/commons.dart';

part 'apps_consumption_controller.g.dart';

@riverpod
class AppsConsumptionController extends _$AppsConsumptionController {
  @override
  FutureOr<List<AppsConsumptionInfo>> build() async {
    ref.watch(appsControllerProvider);
    final data = ref.watch(appsControllerProvider.future);
    final batteryUsage = ref.watch(batteryConsumptionControllerProvider.future);
    return Future.wait([
      data,
      batteryUsage,
    ]).then((value) {
      final apps = (value[0] as AppsInfo).apps;
      final appsWithBattery = value[1] as BatteryConsumptionState;
      return [
        AppsConsumptionInfo(
          consumptionData: sortAppsConsumptionData(apps),
          type: SortType.dataUse,
        ),
        AppsConsumptionInfo(
          consumptionData: sortAppsConsumptionCapacity(apps),
          type: SortType.size,
        ),
        AppsConsumptionInfo(
          consumptionData: sortAppsConsumptionBattery(appsWithBattery.apps),
          type: SortType.batteryUse,
        ),
      ];
    });
  }

  List<AppCheckboxItemData> sortAppsConsumptionData(
      List<AppCheckboxItemData> apps) {
    final appsData = [...apps];
    appsData.sort((a, b) => b.dataUsed.value.compareTo(a.dataUsed.value));
    return appsData;
  }

  List<AppCheckboxItemData> sortAppsConsumptionCapacity(
      List<AppCheckboxItemData> apps) {
    final largeCapacity = 0.mb.to(DigitalUnitSymbol.byte);
    final largeApps =
        apps.where((element) => element.totalSize > largeCapacity).toList();

    largeApps.sort((a, b) => b.totalSize.value.compareTo(a.totalSize.value));
    return largeApps;
  }

  List<AppCheckboxItemData> sortAppsConsumptionBattery(
      List<AppCheckboxItemData> apps) {
    final appsData = [...apps];
    appsData.sort((a, b) => b.batteryPercentage.compareTo(a.batteryPercentage));
    return appsData;
  }
}
