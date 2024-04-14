import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/features/features.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'usused_apps_controller.g.dart';

@riverpod
class UnusedAppsController extends _$UnusedAppsController {
  @override
  FutureOr<SavingTipsAppState> build() {
    ref.watch(appsControllerProvider);
    final appUsage = ref.watch(appsUsageControllerProvider.future);

    return appUsage.then((value) {
      final apps = value;
      final apps2 = apps[0].categories[2].items.where((e) => e.appType == AppType.installed).toList();
      return SavingTipsAppState(
        apps: apps2,
      );
    });
  }

  void toggleAppItem(int index) {
    var appList = state.value!.apps.toList();
    appList[index] = appList[index].copyWith(checked: !appList[index].checked);
    state = AsyncData(
      state.value!.copyWith(apps: appList),
    );
  }
}
