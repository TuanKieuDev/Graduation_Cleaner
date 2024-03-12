import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/features/file/controllers/file_controller/file_controller.dart';
import 'package:phone_cleaner/src/features/file/features/photo_optimized/photo_optimized.dart';
import 'package:phone_cleaner/src/features/file/filter_params.dart';
import 'package:device_info/device_info.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'photo_optimized_controller.g.dart';

@riverpod
class PhotoOptimizedController extends _$PhotoOptimizedController {
  late FileController _fileController;

  @override
  FutureOr<PhotosOptimized> build() {
    ref.watch(fileControllerProvider);
    _fileController = ref.watch(fileControllerProvider.notifier);

    return Future.wait([_fileController.future]).then((value) {
      ref.keepAlive();
      final fileMap = value[0];
      return PhotosOptimized(
          photos: fileMap[SystemEntityType.optimizablePhoto]!
              .toListOfFileCheckBoxItemData()
              .filterWithParams(optimizedPhotosFilterParam));
    });
  }

  void deletePathsInState(Set<String> paths) {
    ref.read(fileControllerProvider.notifier).deletePathsInState(paths);
  }
}
