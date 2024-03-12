import 'dart:async';
import 'dart:developer';

import 'package:phone_cleaner/main.dart';
import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/features/features.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'file_filter_controller.g.dart';

@riverpod
class FileFilterController extends _$FileFilterController {
  Future<FileFilterData> setParameters(
          FileFilterParameter fileFilterParameter) =>
      update((state) {
        return fetchAndFilter(_correctParameters(fileFilterParameter));
      });

  Future<FileFilterData> toggleReverse() => update((state) {
        assert(state.fileFilterParameter != null);
        final newParams = state.fileFilterParameter!
            .copyWith(isReversed: !state.fileFilterParameter!.isReversed);
        return state.copyWith(
          fileDataList: state.fileDataList.filterWithParams(newParams),
          fileFilterParameter: newParams,
        );
      });

  Future<FileFilterData> toggleGrid() => update((state) {
        return state.copyWith(displayGridLayout: !state.displayGridLayout);
      });

  Future<FileFilterData> toggleFileCheckboxItemData(
          FileCheckboxItemData fileCheckboxItemData) =>
      update((state) {
        final fileCategories = state.fileDataList;
        for (int categoryIndex = 0;
            categoryIndex < fileCategories.length;
            categoryIndex++) {
          final category = fileCategories[categoryIndex];
          for (int itemIndex = 0;
              itemIndex < category.checkboxItems.length;
              itemIndex++) {
            if (category.checkboxItems[itemIndex] == fileCheckboxItemData) {
              return toggleFileCheckboxItemDataAtIndex(
                  categoryIndex, itemIndex);
            }
          }
        }
        throw StateError('$fileCheckboxItemData not found');
      });

  Future<FileFilterData> toggleFileCheckboxItemDataAtIndex(
          int categoryIndex, int itemIndex) =>
      update((state) {
        final fileCategories = state.fileDataList.toList(growable: true);
        final newItem = fileCategories[categoryIndex].checkboxItems[itemIndex];
        final newCheckboxItems =
            fileCategories[categoryIndex].checkboxItems.toList();
        newCheckboxItems[itemIndex] =
            newItem.copyWith(checked: !newItem.checked);
        fileCategories[categoryIndex] = fileCategories[categoryIndex]
            .copyWith(checkboxItems: newCheckboxItems);

        return state.copyWith(fileDataList: fileCategories);
      });

  Future<FileFilterData> toggleCategoryAtIndex(int categoryIndex) =>
      update((state) {
        final fileCategories = state.fileDataList.toList();
        final newCategory = fileCategories[categoryIndex];
        final newCheckedStatus = newCategory.isAllChecked ? false : true;
        var checkboxItems = newCategory.checkboxItems.toList();
        for (int i = 0; i < checkboxItems.length; i++) {
          checkboxItems[i] =
              checkboxItems[i].copyWith(checked: newCheckedStatus);
        }
        fileCategories[categoryIndex] =
            newCategory.copyWith(checkboxItems: checkboxItems);
        return state.copyWith(fileDataList: fileCategories);
      });

  Future<FileFilterData> toggleAllChecked() => update((state) {
        final fileCategories = state.fileDataList.toList();
        final newCheckedStatus = state.isAllChecked ? false : true;
        for (int categoryIndex = 0;
            categoryIndex < fileCategories.length;
            categoryIndex++) {
          final newCategory = fileCategories[categoryIndex];
          var checkboxItems = newCategory.checkboxItems.toList();
          for (int itemIndex = 0;
              itemIndex < checkboxItems.length;
              itemIndex++) {
            checkboxItems[itemIndex] =
                checkboxItems[itemIndex].copyWith(checked: newCheckedStatus);
          }
          fileCategories[categoryIndex] =
              newCategory.copyWith(checkboxItems: checkboxItems);
        }

        return state.copyWith(fileDataList: fileCategories);
      });

  void deleteFile(FileCheckboxItemData fileCheckboxItemData) {
    deleteFiles([fileCheckboxItemData]);
  }

  Future deleteFiles(List<FileCheckboxItemData> fileCheckboxItemData) async {
    // return;
    assert(state.hasValue, "Data is not available!");
    final oldState = state.requireValue;
    state = AsyncData(oldState.copyWith(cleaning: true));
    final deletePaths = fileCheckboxItemData.map((e) => e.path).toSet();

    final resultStream =
        ref.read(fileManagerRepository).deleteFiles(deletePaths);
    final cleanedFiles = <FileCheckboxItemData>[];
    final cleanedPaths = <String>{};
    final completer = Completer();
    resultStream.listen((event) {
      log("called event");
      final data = fileCheckboxItemData
          .firstWhere((element) => element.path == event.path);
      cleanedFiles.add(data);
      cleanedPaths.add(event.path);
    }, onDone: () => completer.complete());
    await completer.future;

    log('${cleanedPaths.length}');
    _deletePathsInState(cleanedPaths);
    _deletePathInFetchedStates(cleanedPaths);

    await ref.refresh(overallSystemControllerProvider.notifier).future;

    Future.delayed(const Duration(milliseconds: 500), () {
      state = AsyncData(
        state.requireValue.copyWith(
            cleaning: false,
            cleanedFiles: cleanedFiles,
            failedFiles: fileCheckboxItemData
                .where((element) => !cleanedPaths.contains(element.path))
                .toList()),
      );
    });
  }

  void _deletePathsInState(Set<String> paths) {
    update((state) {
      final fileCategories = state.fileDataList.toList();
      for (int categoryIndex = 0;
          categoryIndex < fileCategories.length;
          categoryIndex++) {
        final newCategory = fileCategories[categoryIndex];
        var checkboxItems = newCategory.checkboxItems
            .where((element) => !paths.contains(element.path))
            .toList();
        fileCategories[categoryIndex] =
            newCategory.copyWith(checkboxItems: checkboxItems);
      }

      fileCategories.removeWhere((element) => element.checkboxItems.isEmpty);

      return state.copyWith(fileDataList: fileCategories);
    });
  }

  void _deletePathInFetchedStates(Set<String> paths) {
    ref.read(mediaFolderControllerProvider.notifier).deletePathsInState(paths);
    ref.read(fileControllerProvider.notifier).deletePathsInState(paths);
    ref
        .read(photoOptimizedControllerProvider.notifier)
        .deletePathsInState(paths);
    ref
        .read(imageAnalysisControllerProvider.notifier)
        .deletePathsInState(paths);
  }

  @override
  FutureOr<FileFilterData> build() async {
    ref.watch(fileControllerProvider);
    return fetchAndFilter(state.valueOrNull?.fileFilterParameter);
  }

  FutureOr<FileFilterData> fetchAndFilter(
      FileFilterParameter? fileFilterParameter) async {
    fileFilterParameter = _correctParameters(fileFilterParameter);

    if (fileFilterParameter == null) {
      return const FileFilterData();
    }

    final dataList = await _fetchData(fileFilterParameter);
    final filteredList = dataList.filterWithParams(fileFilterParameter);

    return FileFilterData(
      fileDataList: filteredList,
      fileFilterParameter: fileFilterParameter,
      displayGridLayout: state.valueOrNull?.displayGridLayout ?? true,
      openBottoNav: state.valueOrNull?.openBottoNav ?? false,
    );
  }

  FileFilterParameter? _correctParameters(FileFilterParameter? params) {
    return params?.copyWith(
      photoType:
          params.fileType != FileType.photo ? PhotoType.none : params.photoType,
      groupType: params.fileType == FileType.photo &&
              params.photoType == PhotoType.similar
          ? GroupType.folder
          : params.groupType,
    );
  }

  Future<List<FileCategory>> _fetchData(FileFilterParameter params) async {
    Future<List<FileCheckboxItemData>> photoAnalysisData;

    final isMediaFolder = params.groupType == GroupType.folder &&
        params.fileType == FileType.media;

    if (isMediaFolder) {
      return await ref
          .watch(mediaFolderControllerProvider.notifier)
          .future
          .then((value) => value);
    }

    switch (params.photoType) {
      case PhotoType.none:
        photoAnalysisData = ref
            .watch(fileCacheControllerProvider.notifier)
            .future
            .then((value) => value.files);
        break;
      case PhotoType.optimize:
        photoAnalysisData = ref
            .watch(photoOptimizedControllerProvider.notifier)
            .future
            .then((value) => value.photos);
        break;
      case PhotoType.sensitive:
        photoAnalysisData = ref
            .watch(imageAnalysisControllerProvider.notifier)
            .future
            .then((value) => value.sensitivePhotos);
        break;
      case PhotoType.bad:
        photoAnalysisData = ref
            .watch(imageAnalysisControllerProvider.notifier)
            .future
            .then((value) => value.badPhotos);
        break;
      case PhotoType.similar:
        return ref
            .watch(imageAnalysisControllerProvider.notifier)
            .future
            .then((value) => value.similarPhotos);
    }

    return [
      FileCategory(
        name: 'photo',
        checkboxItems: await photoAnalysisData,
      )
    ];
  }
}
