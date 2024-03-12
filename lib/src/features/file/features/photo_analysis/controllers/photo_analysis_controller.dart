import 'package:phone_cleaner/main.dart';
import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/features/file/features/photo_analysis/controllers/low_image_analysis_controller.dart';
import 'package:phone_cleaner/src/features/file/features/photo_analysis/controllers/similar_photo_analysis_controller.dart';
import 'package:phone_cleaner/src/features/file/file.dart';
import 'package:device_info/device_info.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'photo_analysis_controller.g.dart';

@riverpod
class ImageAnalysisController extends _$ImageAnalysisController {
  late FileController _fileController;
  late FileManager _fileManager;

  @override
  FutureOr<PhotoAnalysisData> build() {
    ref.watch(fileControllerProvider);
    _fileController = ref.read(fileControllerProvider.notifier);
    _fileManager = ref.watch(fileManagerRepository);
    final lowImagesFuture =
        ref.watch(lowImageAnalysisControllerProvider.future);
    final similarImagesFuture =
        ref.watch(similarPhotoAnalysisControllerProvider.future);
    return Future.wait(
            [_fileController.future, lowImagesFuture, similarImagesFuture])
        .then((value) {
      ref.keepAlive();
      final fileMap = value[0] as Map<SystemEntityType, List<FolderOrFileInfo>>;
      final lowImages = value[1] as List<FileCheckboxItemData>;
      final similarImages = value[2] as List<FileCategory>;

      return PhotoAnalysisData(
        similarPhotos: similarImages,
        badPhotos: lowImages,
        sensitivePhotos: fileMap[SystemEntityType.sensitiveImage]!
            .toListOfFileCheckBoxItemData()
            .filterWithParams(sensitivePhotosFilterParam),
        oldPhotos: fileMap[SystemEntityType.image]!
            .toListOfFileCheckBoxItemData()
            .filterWithParams(oldPhotosFilterParam),
      );
    });
  }

  void deletePathsInState(Set<String> paths) {
    if (!state.hasValue) return;
    var similar = ref.read(similarPhotoAnalysisControllerProvider.notifier);
    var lowImage = ref.read(lowImageAnalysisControllerProvider.notifier);
    var file = ref.read(fileControllerProvider.notifier);
    similar.deletePathsInState(paths);
    // log('aas2 ${ref.read(lowImageAnalysisControllerProvider.notifier)}');
    lowImage.deletePathsInState(paths);

    file.deletePathsInState(paths);
  }
}
