import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/commons/utilities/app_filter_extension.dart';
import 'package:phone_cleaner/src/features/features.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'large_apps_controller.g.dart';

@riverpod
class LargeAppsController extends _$LargeAppsController {
  @override
  FutureOr<SavingTipsAppState> build() {
    final appFilterController = ref.watch(appsControllerProvider.future);

    return appFilterController.then((value) {
      final apps = value.apps
          .filterWithParams(
            largeAppsParams,
          )
          .where((element) => element.totalSize >= largeCapacity)
          .toList();

      return SavingTipsAppState(
        apps: apps,
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
