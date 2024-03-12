import 'package:phone_cleaner/main.dart';
import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/features/file/file.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'low_image_analysis_controller.g.dart';

@riverpod
class LowImageAnalysisController extends _$LowImageAnalysisController {
  @override
  FutureOr<List<FileCheckboxItemData>> build() {
    return ref.watch(fileManagerRepository).getLowImages().then((value) => value
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
        .filterWithParams(badPhotosFilterParam));
  }

  void deletePathsInState(Set<String> paths) {
    if (!state.hasValue) return;
    var newState = state.requireValue;
    newState =
        newState.where((element) => !paths.contains(element.path)).toList();
    state = AsyncData(newState);
  }
}
