import 'dart:async';

import 'package:phone_cleaner/main.dart';
import 'package:phone_cleaner/services/work_manager/work_task_manager.dart';
import 'package:phone_cleaner/src/features/features.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../commons/commons.dart';

part 'quick_clean_controller.g.dart';

@riverpod
class QuickCleanController extends _$QuickCleanController {
  late FileManager _fileManager;

  late KeepAliveLink _keepAliveLink;

  @override
  FutureOr<QuickCleanInfo> build() async {
    _fileManager = ref.watch(fileManagerRepository);

    final fileFuture = _fileManager.isolateQuery({
      SystemEntityType.visibleCache: null,
      SystemEntityType.thumbnail: null,
      SystemEntityType.emptyFolder: null,
      SystemEntityType.installedApk: null,
      SystemEntityType.downloaded: null,
      SystemEntityType.appData: null,
      SystemEntityType.largeOldFile: LargeOldFileParameter(
        const Duration(days: 30),
        100.mb.to(DigitalUnitSymbol.byte).value.toInt(),
      ),
    });
    final appListFuture = _getApps();
    final results = await Future.wait([fileFuture, appListFuture]);
    final result = results[0] as Map<SystemEntityType, List<FolderOrFileInfo>>;
    final apps = results[1] as Map<String, String>;
    _keepAliveLink = ref.keepAlive();

    final visibleCacheScannable = !result[SystemEntityType.visibleCache]!
        .any((element) => element is ErrorFolderInfo);

    var categoryInfos = [
      const QuickCleanCategory(
        categoryType: QuickCleanCategoryType.hiddenCache,
        importantLevel: ImportantLevel.low,
        availability: Availability.toBeUpdated,
        checkboxItems: [],
      ),
      QuickCleanCategory(
        categoryType: QuickCleanCategoryType.visibleCache,
        importantLevel: ImportantLevel.low,
        availability: visibleCacheScannable
            ? Availability.fullAccess
            : Availability.notSupported,
        checkboxItems: visibleCacheScannable
            ? result[SystemEntityType.visibleCache]!
                .cast<FolderInfo>()
                .map((folder) => FileCheckboxItemData(
                      name: folder.name,
                      size: folder.size.bytes,
                      extensionFile: '',
                      fileType: FileType.all,
                      path: folder.path,
                      timeModified: folder.lastModified,
                      isFolder: true,
                    ))
                .toList()
            : [],
      ),
      const QuickCleanCategory(
        categoryType: QuickCleanCategoryType.browserData,
        importantLevel: ImportantLevel.low,
        availability: Availability.toBeUpdated,
        checkboxItems: [],
      ),
      QuickCleanCategory(
        categoryType: QuickCleanCategoryType.thumbnails,
        importantLevel: ImportantLevel.low,
        availability: Availability.fullAccess,
        checkboxItems: result[SystemEntityType.thumbnail]!.map((e) {
          final folder = e as FolderInfo;
          return FileCheckboxItemData(
            name: folder.name,
            size: folder.size.bytes,
            path: folder.path,
            checked: true,
            extensionFile: '',
            fileType: FileType.all,
            timeModified: folder.lastModified,
            isFolder: true,
          );
        }).toList(),
      ),
      QuickCleanCategory(
        categoryType: QuickCleanCategoryType.emptyFolders,
        importantLevel: ImportantLevel.low,
        availability: Availability.fullAccess,
        checkboxItems: result[SystemEntityType.emptyFolder]!.map((e) {
          final folder = e as FolderInfo;
          return FileCheckboxItemData(
            name: folder.name,
            size: folder.size.bytes,
            path: folder.path,
            checked: true,
            extensionFile: '',
            fileType: FileType.all,
            timeModified: folder.lastModified,
            isFolder: true,
          );
        }).toList(),
      ),
      QuickCleanCategory(
        categoryType: QuickCleanCategoryType.apkFiles,
        importantLevel: ImportantLevel.low,
        availability: Availability.fullAccess,
        checkboxItems: result[SystemEntityType.installedApk]!.map((e) {
          final file = e as FileInfo;
          return FileCheckboxItemData(
            name: file.name,
            size: file.size.bytes,
            path: file.path,
            extensionFile: file.extension,
            checked: true,
            fileType: file.toFileType(),
            timeModified: file.lastModified,
          );
        }).toList(),
      ),
      QuickCleanCategory(
        categoryType: QuickCleanCategoryType.downloads,
        importantLevel: ImportantLevel.medium,
        availability: Availability.fullAccess,
        checkboxItems: result[SystemEntityType.downloaded]!.map((e) {
          final file = e as FileInfo;
          return FileCheckboxItemData(
            name: file.name,
            size: file.size.bytes,
            path: file.path,
            extensionFile: file.extension,
            checked: false,
            fileType: file.toFileType(),
            timeModified: file.lastModified,
          );
        }).toList(),
      ),
      QuickCleanCategory(
        categoryType: QuickCleanCategoryType.appData,
        importantLevel: ImportantLevel.medium,
        availability: Availability.fullAccess,
        checkboxItems: result[SystemEntityType.appData]!
            .where((element) => apps.containsKey(element.name))
            .map((e) {
          final folder = e as FolderWithChildren;

          return FileCheckboxItemData(
            name: folder.name,
            size: folder.size.bytes,
            path: folder.path,
            extensionFile: apps[folder.name] ?? '',
            isApp: true,
            fileType: FileType.all,
            timeModified: folder.folderInfo.lastModified,
            isFolder: true,
          );
        }).toList(),
      ),
      QuickCleanCategory(
        categoryType: QuickCleanCategoryType.largeOldFiles,
        importantLevel: ImportantLevel.medium,
        availability: Availability.fullAccess,
        checkboxItems: result[SystemEntityType.installedApk]!.map((e) {
          final file = e as FileInfo;
          return FileCheckboxItemData(
            name: file.name,
            size: file.size.bytes,
            path: file.path,
            extensionFile: file.extension,
            checked: false,
            fileType: file.toFileType(),
            timeModified: file.lastModified,
          );
        }).toList(),
      ),
    ];

    categoryInfos = categoryInfos
        .where((element) =>
            element.checkboxItems.isNotEmpty &&
            element.availability == Availability.fullAccess)
        .toList(growable: false);

    return QuickCleanInfo(categories: categoryInfos);
  }

  Future<Map<String, String>> _getApps() async {
    final appManager = ref.watch(appRepository);
    final apps = await appManager.getAllApplications();
    final results = <String, String>{};
    final futures = <Future>[];
    for (var i = 0; i < apps.length; i++) {
      final future = appManager
          .getLabel(apps[i].packageName)
          .then((value) => results[value] = apps[i].packageName);
      futures.add(future);
    }
    Future.wait(futures);

    return results;
  }

  void toggleCategoryState(int categoryIndex) {
    assert(categoryIndex >= 0);
    assert(categoryIndex < state.value!.categories.length);

    final quickCleanInfo = state.value!;
    final targetCategory = quickCleanInfo.categories[categoryIndex];
    final targetCheckedState = !targetCategory.isAllChecked;
    final newCategories = [...quickCleanInfo.categories];

    newCategories[categoryIndex] = targetCategory.copyWith(
        checkboxItems: targetCategory.checkboxItems
            .map((checkboxItem) =>
                checkboxItem.copyWith(checked: targetCheckedState))
            .toList());

    final newQuickCleanInfo =
        quickCleanInfo.copyWith(categories: newCategories);

    state = AsyncData(newQuickCleanInfo);
  }

  void toggleCategoryItemState(int categoryIndex, int itemIndex) {
    assert(categoryIndex >= 0);
    assert(categoryIndex < state.value!.categories.length);

    final quickCleanInfo = state.value!;
    final targetCategory = quickCleanInfo.categories[categoryIndex];

    assert(itemIndex >= 0);
    assert(itemIndex < targetCategory.checkboxItems.length);

    final targetCheckboxItem = targetCategory.checkboxItems[itemIndex];
    final targetCheckedState = !targetCheckboxItem.checked;

    final newCategories = [...quickCleanInfo.categories];
    final newTargetCategoryCheckboxItems = [
      ...newCategories[categoryIndex].checkboxItems
    ];
    newTargetCategoryCheckboxItems[itemIndex] =
        targetCheckboxItem.copyWith(checked: targetCheckedState);
    newCategories[categoryIndex] =
        targetCategory.copyWith(checkboxItems: newTargetCategoryCheckboxItems);

    state = AsyncData(quickCleanInfo.copyWith(categories: newCategories));
  }

  Future<DigitalUnit> clean() async {
    state = const AsyncValue<QuickCleanInfo>.loading().copyWithPrevious(state);

    state = await AsyncValue.guard(_clean);
    WorkTaskManager.registerPeriodicForQuickCleanNotifications();
    _keepAliveLink.close();
    return state.requireValue.cleanedSize!;
  }

  Future<QuickCleanInfo> _clean() async {
    final selectedPaths = <String, FileCheckboxItemData>{};
    for (var item in state.value!.categories) {
      for (var item2 in item.checkboxItems) {
        if (item2.checked) {
          selectedPaths[item2.path] = item2;
        }
      }
    }

    var deletedFilePaths = <String>{};

    Completer<void> complete = Completer();
    _fileManager.deleteFiles(selectedPaths.keys).listen(
      (value) {
        deletedFilePaths.add(value.path);
      },
      onError: print,
      onDone: complete.complete,
    );

    await complete.future;

    final cleanedItems = selectedPaths.values
        .where((element) => deletedFilePaths.contains(element.path))
        .toList();
    final failedItems = selectedPaths.values
        .where((element) => !deletedFilePaths.contains(element.path))
        .toList();
    selectedPaths.removeWhere((key, value) => !deletedFilePaths.contains(key));
    final cleanedSize = cleanedItems.fold(
        0.kb, (previousValue, element) => previousValue + element.size);

    final newCategories = state.requireValue.categories
        .map((category) => category.copyWith(
            checkboxItems: category.checkboxItems
                .where((element) => !selectedPaths.containsKey(element.path))
                .toList()))
        .where((element) => element.checkboxItems.isNotEmpty)
        .toList();

    await ref.refresh(overallSystemControllerProvider.notifier).future;

    return state.requireValue.copyWith(
      categories: newCategories,
      cleanedItems: cleanedItems,
      failedItems: failedItems,
      cleanedSize: cleanedSize,
    );
  }
}
