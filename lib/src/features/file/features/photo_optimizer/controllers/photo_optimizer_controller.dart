import 'dart:async';

import 'package:phone_cleaner/main.dart';
import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/features/features.dart';
import 'package:device_info/device_info.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/models.dart';

part 'photo_optimizer_controller.g.dart';

@riverpod
class PhotoOptimizerController extends _$PhotoOptimizerController {
  void setOptimizeValue(OptimizeValue value) {
    update((p0) => p0.copyWith(optimizeValue: value));
  }

  void setOriginalValue(OriginalOption option) {
    update((p0) => p0.copyWith(originalOption: option));
  }

  void setSelectedIndex(int index) {
    update((p0) => p0.copyWith(previewPhotoIndex: index));
  }

  @override
  FutureOr<PhotoOptimizerState> build() async {
    final fileFilterData =
        await ref.watch(fileFilterControllerProvider.notifier).future;
    final photos = fileFilterData.checkedCheckboxItems.where(
      (element) {
        //TODO: need to review BE
        return element.fileType == FileType.photo;
      },
    ).toList();

    return PhotoOptimizerState(
      photos: photos,
      previewPhotoIndex: state.valueOrNull?.previewPhotoIndex ?? 0,
      optimizeValue: state.valueOrNull?.optimizeValue ?? OptimizeValue.low,
      originalOption:
          state.valueOrNull?.originalOption ?? OriginalOption.delete,
    );
  }

  Future<PhotoOptimizationResult> getOptimizeImagePreviewValue(
    String path,
  ) async {
    final result = await ref.read(fileManagerRepository).optimizeImagePreview(
          path,
          'test',
          state.requireValue.optimizeValue.quality,
          state.requireValue.optimizeValue.scaleValue,
        );

    return result;
  }

  Future<void> optimize() async {
    state = const AsyncLoading<PhotoOptimizerState>()
        .copyWithPrevious(state, isRefresh: true);
    final newState = state.requireValue;
    var selectedPath = state.requireValue.photos.map((e) => e.path).toList();
    final stream = ref.read(fileManagerRepository).optimizeImages(
          selectedPath,
          state.requireValue.optimizeValue.quality,
          state.requireValue.optimizeValue.scaleValue,
          state.requireValue.originalOption == OriginalOption.delete,
        );
    Completer completer = Completer();
    List<FileCheckboxItemData> optimizedPhotos = [];
    List<FileCheckboxItemData> result = [];
    stream.listen(
      (event) {
        optimizedPhotos.add(event.optimizedPhoto.toFileCheckBoxItemData());
        result.add(event.optimizedPhoto.toFileCheckBoxItemData());
        if (event.originalPhotoWithNewPath != null) {
          optimizedPhotos
              .add(event.originalPhotoWithNewPath!.toFileCheckBoxItemData());
        }
      },
      onError: print,
      onDone: () => completer.complete(),
    );
    await completer.future;
    final optimizedPaths = optimizedPhotos.map((e) => e.path);
    final failedToOptimizePhotos = state.requireValue.photos
        .where((element) => optimizedPaths.contains(element.path))
        .toList();
    ref.read(fileControllerProvider.notifier).deleteAndAddPaths(
          selectedPath.toSet(),
          optimizedPhotos
              .map((e) => FileInfo(
                    mediaId: e.mediaId,
                    mediaType: e.mediaType,
                    name: e.name,
                    path: e.path,
                    size: e.size.value.toInt(),
                    extension: e.extensionFile,
                    lastModified: e.timeModified,
                  ))
              .toList(),
        );

    await ref.refresh(overallSystemControllerProvider.notifier).future;

    state = AsyncData(newState.copyWith(
      optimizedPhotos: result,
      failedToOptimizePhotos: failedToOptimizePhotos,
    ));
  }
}
