import 'package:phone_cleaner/main.dart';
import 'package:device_info/device_info.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'photo_optimizer_controller.dart';

part 'photo_optimizer_preview_controller.g.dart';

@riverpod
class PhotoOptimizerPreviewController
    extends _$PhotoOptimizerPreviewController {
  @override
  FutureOr<PhotoOptimizationResult> build() async {
    final path = await ref.watch(photoOptimizerControllerProvider
        .selectAsync((data) => data.photos[data.previewPhotoIndex].path));
    final optimizeValue = await ref.watch(photoOptimizerControllerProvider
        .selectAsync((data) => data.optimizeValue));

    final result = await ref.read(fileManagerRepository).optimizeImagePreview(
          path,
          'test',
          optimizeValue.quality,
          optimizeValue.scaleValue,
        );
    return result;
  }
}
