import 'package:phone_cleaner/src/commons/utilities/app_filter_extension.dart';
import 'package:phone_cleaner/src/features/features.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_diary_controller.g.dart';

@riverpod
class AppDiaryController extends _$AppDiaryController {
  @override
  FutureOr<SavingTipsAppState> build() {
    ref.watch(appsControllerProvider);
    final appsUsageController = ref.watch(appsUsageControllerProvider.future);

    return appsUsageController.then((value) {
      final data = value[0];

      final apps = data.categories[1].items
          .filterWithParams(
            appDairyParams,
          )
          .toList();

      return SavingTipsAppState(apps: apps);
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
