import 'package:phone_cleaner/main.dart';
import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/features/apps/apps.dart';
import 'package:phone_cleaner/src/features/apps/controllers/list_app_controller.dart';
import 'package:phone_cleaner/src/features/apps/features/apps_growing/models/app_growing_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'growing_controller.g.dart';

@riverpod
class GrowingController extends _$GrowingController {
  @override
  Future<FutureOr<AppGrowingState>> build() async {
    final appManager = ref.watch(appRepository);
    final timeRemaining =
        await appManager.getTimeRemainingForAppGrowingAnalysis();
    if (timeRemaining > 0) {
      return AppGrowingState(apps: [], timeRemaining: timeRemaining);
    }

    final packageInfos = await ref.watch(listAppControllerProvider.future);
    final appsGrowing = <AppGrowingInfo>[];

    for (var item in packageInfos) {
      final sizeChangeWeekly = await appManager.getAppSizeGrowingInByte(
          item.packageName, 7, (sizeChangeWeekly) {});
      appsGrowing.add(
        AppGrowingInfo(
          packageName: item.packageName,
          increaseSizeWeekly: sizeChangeWeekly.bytes,
        ),
      );
    }

    return AppGrowingState(
      apps: appsGrowing,
      timeRemaining: timeRemaining,
    );
  }
}
