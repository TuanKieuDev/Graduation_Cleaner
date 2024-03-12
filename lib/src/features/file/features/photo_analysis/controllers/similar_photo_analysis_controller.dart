import 'package:phone_cleaner/main.dart';
import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/features/file/file.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'similar_photo_analysis_controller.g.dart';

@riverpod
class SimilarPhotoAnalysisController extends _$SimilarPhotoAnalysisController {
  @override
  FutureOr<List<FileCategory>> build() {
    return ref
        .watch(fileManagerRepository)
        .getSimilarImages()
        .then((value) => value
            .map((e) => e
                .map((e) => FileCheckboxItemData(
                      mediaId: e.mediaId,
                      mediaType: e.mediaType,
                      name: e.name,
                      size: e.size.bytes,
                      extensionFile: e.extension,
                      path: e.path,
                      timeModified: e.lastModified,
                      fileType: FileType.photo,
                    ))
                .toList())
            .map(
              (e) => FileCategory(
                name: e[0]
                    .path
                    .substring(0, e[0].path.lastIndexOf('/'))
                    .folderOptimalName,
                checkboxItems: e,
              ),
            )
            .toList()
            .filterWithParams(similarPhotosFilterParam));
  }

  void deletePathsInState(Set<String> paths) {
    if (!state.hasValue) return;
    var newState = state.requireValue;
    newState = newState
        .map((e) => e.copyWith(
            checkboxItems: e.checkboxItems
                .where((element) => !paths.contains(element.path))
                .toList()))
        .where((element) =>
            element.checkboxItems.isNotEmpty &&
            element.checkboxItems.length > 1)
        .toList();
    state = AsyncData(newState);
  }
}
