import 'package:phone_cleaner/src/commons/utilities/app_filter_extension.dart';
import 'package:phone_cleaner/src/features/features.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'rarely_used_app_controller.g.dart';

@riverpod
class RarelyUsedAppController extends _$RarelyUsedAppController {
  @override
  FutureOr<SavingTipsAppState> build() async {
    final appsUsageController = ref.watch(appsUsageControllerProvider.future);

    return appsUsageController.then((value) {
      final data = value;
      final apps = data[0]
          .categories[1]
          .items
          .filterWithParams(
            rarelyUsedAppsParams,
          )
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
