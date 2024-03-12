import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/features/apps/controllers/list_app_controller.dart';
import 'package:phone_cleaner/src/features/features.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'saving_tips_controller.g.dart';

@riverpod
class SavingTipsController extends _$SavingTipsController {
  @override
  FutureOr<SavingTipsState> build() {
    ref.watch(listAppControllerProvider);
    final rarelyUsedApps =
        ref.watch(rarelyUsedAppControllerProvider.notifier).future;
    final unusedApps = ref.watch(unusedAppsControllerProvider.notifier).future;
    final photosPreview =
        ref.watch(photoPreviewControllerProvider.notifier).future;
    final largeApps = ref.watch(largeAppsControllerProvider.notifier).future;

    return Future.wait([rarelyUsedApps, unusedApps, photosPreview, largeApps])
        .then((value) {
      final rarelyUsedApp = value[0] as SavingTipsAppState;
      final unusedApp = value[1] as SavingTipsAppState;
      final photoPreview = value[2] as PhotoPreviewState;
      final largeApp = value[3] as SavingTipsAppState;

      return SavingTipsState(
        isShowLargeAppsTips: largeApp.appCanOptimizeTotalSize > 0.kb,
        isShowPhotoTip: photoPreview.isShowPhotoPreview,
        isShowRarelyUsedAppsTip: rarelyUsedApp.appCanOptimizeTotalSize > 0.kb,
        isShowUnUsedAppsTip: unusedApp.appCanOptimizeTotalSize > 0.kb,
        // isShowUnnecessaryDataTip: false,
      );
    });
  }
}
