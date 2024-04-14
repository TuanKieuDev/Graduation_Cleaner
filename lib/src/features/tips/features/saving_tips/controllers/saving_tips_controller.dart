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
    final unusedApps = ref.watch(unusedAppsControllerProvider.notifier).future;
    final photosPreview =
        ref.watch(photoPreviewControllerProvider.notifier).future;
    final largeApps = ref.watch(largeAppsControllerProvider.notifier).future;

    return Future.wait([unusedApps, photosPreview, largeApps])
        .then((value) {
      final unusedApp = value[0] as SavingTipsAppState;
      final photoPreview = value[1] as PhotoPreviewState;
      final largeApp = value[2] as SavingTipsAppState;

      return SavingTipsState(
        isShowLargeAppsTips: largeApp.appCanOptimizeTotalSize > 0.kb,
        isShowPhotoTip: photoPreview.isShowPhotoPreview,
        isShowUnUsedAppsTip: unusedApp.appCanOptimizeTotalSize > 0.kb,
      );
    });
  }
}
