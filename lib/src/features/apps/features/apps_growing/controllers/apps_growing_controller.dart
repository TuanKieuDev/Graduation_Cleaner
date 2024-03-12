import 'package:phone_cleaner/src/features/apps/features/apps_growing/controllers/growing_controller.dart';
import 'package:phone_cleaner/src/features/features.dart';
import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../commons/commons.dart';
import '../models/app_growing_state.dart';

part 'apps_growing_controller.g.dart';

@riverpod
class AppsGrowingController extends _$AppsGrowingController {
  // void toggleState(PeriodType periodType) {
  //   update((state) => state.copyWith(periodType: periodType));
  // }

  @override
  FutureOr<AppsGrowingInfo> build() async {
    final appGrowingInfo = ref.watch(growingControllerProvider.future);
    final appController = ref.read(appsControllerProvider.future);

    final result =
        Future.wait([appGrowingInfo, appController]).then((value) async {
      final appGrowingState = value[0] as AppGrowingState;
      final appsInfo = value[1] as AppsInfo;

      List<AppCheckboxItemData> newData = appsInfo.apps;
      if (appGrowingState.timeRemaining <= 0) {
        newData = newData
            .mapIndexed((i, e) => e.copyWith(
                sizeChange: appGrowingState.apps[i].increaseSizeWeekly))
            .toList();
        newData
            .sort((a, b) => b.sizeChange.value.compareTo(a.sizeChange.value));
      }

      return AppsGrowingInfo(
        timeForAnalysis: appGrowingState.timeRemaining,
        periodType: PeriodType.day,
        growingData: newData,
      );
    });

    return result;
  }
}
