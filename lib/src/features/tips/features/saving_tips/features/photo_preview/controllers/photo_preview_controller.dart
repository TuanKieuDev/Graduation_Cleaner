import 'package:phone_cleaner/src/features/features.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'photo_preview_controller.g.dart';

@riverpod
class PhotoPreviewController extends _$PhotoPreviewController {
  @override
  FutureOr<PhotoPreviewState> build() async {
    final imagesAnalysis =
        await ref.watch(imageAnalysisControllerProvider.future);

    return PhotoPreviewState(
      photoAnalysisData: imagesAnalysis,
    );
  }
}
