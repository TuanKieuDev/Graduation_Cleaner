import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/features/features.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as path;

extension FileCategoryFilter on List<FileCategory> {
  List<FileCategory> filterWithParams(FileFilterParameter params) {
    List<FileCategory> filteredList = this;

    final isMediaFolder = params.groupType == GroupType.folder &&
        params.fileType == FileType.media;

    final isSimilarImages = params.photoType == PhotoType.similar;

    if (!isMediaFolder && !isSimilarImages) {
      final fileCheckboxItemDatas = filteredList.fold(<FileCheckboxItemData>[],
          (previous, value) => previous + value.checkboxItems);
      filteredList = fileCheckboxItemDatas.filterGroup(params.groupType);
    }

    filteredList = filteredList.filterFileType(params.fileType).toList();

    if (params.folderType == FolderType.camera) {
      filteredList = filteredList.filterFolder(FolderType.camera);
    } else if (params.folderType == FolderType.download) {
      filteredList = filteredList.filterFolder(FolderType.download);
    } else if (params.folderType == FolderType.screenShot) {
      filteredList = filteredList.filterFolder(FolderType.screenShot);
    }

    if (params.showFileType == ShowFileType.size) {
      filteredList = filteredList.filterSize(largeCapacity);
    } else if (params.showFileType == ShowFileType.month) {
      filteredList = filteredList.filterDate(oldDuration);
    }

    filteredList.removeWhere((element) => element.checkboxItems.isEmpty);

    filteredList =
        filteredList.sortByFileType(params.sortFileType, params.isReversed);

    return filteredList;
  }

  Iterable<FileCategory> filterFileType(FileType fileType) {
    return map((element) => element.copyWith(
        checkboxItems:
            element.checkboxItems.filterFileType(fileType).toList()));
  }

  List<FileCategory> filterFolder(FolderType folderType) {
    return cast<FileCategory>()
        .map((element) => element.copyWith(
            checkboxItems:
                element.checkboxItems.filterFolderType(folderType).toList()))
        .toList();
  }

  List<FileCategory> sortByFileType(SortFileType sortFileType,
      [bool isReversed = false]) {
    if (sortFileType == SortFileType.name) {
      return sortByName(isReversed);
    } else if (sortFileType == SortFileType.date) {
      return sortByDate(isReversed);
    } else if (sortFileType == SortFileType.size) {
      return sortBySize(isReversed);
    }

    throw UnimplementedError('$sortFileType is not implemented');
  }

  List<FileCategory> sortByName([bool isReversed = false]) {
    final reverseComparison = isReversed ? -1 : 1;
    for (var i = 0; i < length; i++) {
      final newCategory = this[i];
      var newCheckboxItems = newCategory.checkboxItems.toList();
      newCheckboxItems.sortByName(isReversed);

      this[i] = newCategory.copyWith(checkboxItems: newCheckboxItems);
    }

    sort((a, b) {
      var comparision = a.name.compareIgnoreCaseAndDiacriticsTo(b.name);

      if (comparision != 0) return comparision * reverseComparison;

      for (var i = 0;
          i < a.checkboxItems.length && i < b.checkboxItems.length;
          i++) {
        comparision = a.checkboxItems[i].name
            .compareIgnoreCaseAndDiacriticsTo(b.checkboxItems[i].name);
        if (comparision != 0) return comparision * reverseComparison;
      }

      comparision = a.checkboxItems.length.compareTo(b.checkboxItems.length);

      return comparision * reverseComparison;
    });

    return this;
  }

  List<FileCategory> sortByDate([bool isReversed = false]) {
    final reverseComparison = isReversed ? -1 : 1;
    for (var i = 0; i < length; i++) {
      final newCategory = this[i];
      var newCheckboxItems = newCategory.checkboxItems.toList();
      newCheckboxItems.sortByDate(isReversed);

      this[i] = newCategory.copyWith(checkboxItems: newCheckboxItems);
    }

    sort((a, b) {
      int comparision;
      for (var i = 0;
          i < a.checkboxItems.length && i < b.checkboxItems.length;
          i++) {
        comparision = a.checkboxItems[i].timeModified
            .compareTo(b.checkboxItems[i].timeModified);
        if (comparision != 0) return comparision * reverseComparison;
      }

      comparision = a.checkboxItems.length.compareTo(b.checkboxItems.length);
      return comparision * reverseComparison;
    });

    return this;
  }

  List<FileCategory> sortBySize([bool isReversed = true]) {
    final reverseComparison = isReversed ? -1 : 1;
    for (var i = 0; i < length; i++) {
      final newCategory = this[i];
      var newCheckboxItems = newCategory.checkboxItems.toList();
      newCheckboxItems.sortBySize(isReversed);

      this[i] = newCategory.copyWith(checkboxItems: newCheckboxItems);
    }
    sort((a, b) {
      int comparision = a.totalSize.compareTo(b.totalSize) * reverseComparison;

      if (comparision != 0) {
        return comparision;
      }

      for (var i = 0;
          i < a.checkboxItems.length && i < b.checkboxItems.length;
          i++) {
        comparision =
            a.checkboxItems[i].size.compareTo(b.checkboxItems[i].size);
        if (comparision != 0) return comparision * reverseComparison;
      }

      comparision = a.checkboxItems.length.compareTo(b.checkboxItems.length);
      if (isReversed) comparision *= -1;

      return comparision;
    });

    return this;
  }

  List<FileCategory> filterSize([DigitalUnit size = largeCapacity]) {
    return cast<FileCategory>()
        .map((element) => element.copyWith(
            checkboxItems: element.checkboxItems.filterSize(size).toList()))
        .toList();
  }

  List<FileCategory> filterDate([Duration duration = oldDuration]) {
    final oldTime = DateTime.now().subtract(duration);
    return map((element) => element.copyWith(
          checkboxItems:
              element.checkboxItems.filterDateBefore(oldTime).toList(),
        )).toList();
  }
}

extension FileCheckboxItemDataFilter on Iterable<FileCheckboxItemData> {
  List<FileCheckboxItemData> filterWithParams(FileFilterParameter params) {
    Iterable<FileCheckboxItemData> filteredList = this;
    filteredList = filteredList.filterFileType(params.fileType);

    if (params.folderType == FolderType.camera) {
      filteredList = filteredList.filterFolderType(FolderType.camera);
    } else if (params.folderType == FolderType.download) {
      filteredList = filteredList.filterFolderType(FolderType.download);
    } else if (params.folderType == FolderType.screenShot) {
      filteredList = filteredList.filterFolderType(FolderType.screenShot);
    }

    if (params.showFileType == ShowFileType.size) {
      filteredList = filteredList.filterSize(largeCapacity);
    } else if (params.showFileType == ShowFileType.month) {
      filteredList = filteredList.filterDate(oldDuration);
    }

    filteredList =
        filteredList.sortByFileType(params.sortFileType, params.isReversed);

    return filteredList.toListOptimal();
  }

  List<FileCategory> filterGroup(GroupType groupType) {
    switch (groupType) {
      case GroupType.folder:
        return groupByFolder();
      case GroupType.type:
        return groupByType();
      default:
        return groupByNone();
    }
  }

  List<FileCategory> groupByFolder() {
    final groupFolderData = groupBy(
        this, (item) => item.path.substring(0, item.path.lastIndexOf('/')));

    final data = <FileCategory>[];

    for (var entry in groupFolderData.entries) {
      final folderPath = entry.key;
      final pathElements = path.split(folderPath);
      final name = pathElements.length == 1
          ? pathElements[0]
          : path.join(pathElements[pathElements.length - 2],
              pathElements[pathElements.length - 1]);
      data.add(
        FileCategory(
          name: name,
          checkboxItems: entry.value,
        ),
      );
    }
    return data;
  }

  List<FileCategory> groupByType() {
    return [
      FileCategory(
        name: FileType.photo.description,
        checkboxItems:
            where((element) => element.fileType == FileType.photo).toList(),
      ),
      FileCategory(
        name: FileType.video.description,
        checkboxItems:
            where((element) => element.fileType == FileType.video).toList(),
      ),
      FileCategory(
        name: FileType.audio.description,
        checkboxItems:
            where((element) => element.fileType == FileType.audio).toList(),
      ),
      FileCategory(
        name: FileType.other.description,
        checkboxItems:
            where((element) => element.fileType == FileType.other).toList(),
      ),
    ];
  }

  List<FileCategory> groupByNone() {
    return [FileCategory(name: '', checkboxItems: toListOptimal())];
  }

  List<FileCheckboxItemData> sortByFileType(SortFileType sortFileType,
      [bool isReversed = false]) {
    if (sortFileType == SortFileType.name) {
      return sortByName(isReversed);
    } else if (sortFileType == SortFileType.date) {
      return sortByDate(isReversed);
    } else if (sortFileType == SortFileType.size) {
      return sortBySize(isReversed);
    }

    throw UnimplementedError('$sortFileType is not implemented');
  }

  List<FileCheckboxItemData> sortByName([bool isReversed = false]) {
    final reverseComparison = isReversed ? -1 : 1;

    return toListOptimal()
      ..sort(
        (a, b) =>
            a.name.compareIgnoreCaseAndDiacriticsTo(b.name) * reverseComparison,
      );
  }

  List<FileCheckboxItemData> sortByDate([bool isReversed = false]) {
    final reverseComparison = isReversed ? -1 : 1;

    return toListOptimal()
      ..sort(
        (a, b) => a.timeModified.compareTo(b.timeModified) * reverseComparison,
      );
  }

  List<FileCheckboxItemData> sortBySize([bool isReversed = false]) {
    final reverseComparison = isReversed ? -1 : 1;

    return toListOptimal()
      ..sort(
        (a, b) => a.size.compareTo(b.size) * reverseComparison,
      );
  }

  Iterable<FileCheckboxItemData> filterFileType(FileType fileType) {
    return where((e) => e.fileType.equals(fileType));
  }

  Iterable<FileCheckboxItemData> filterFolderType(FolderType folderType) {
    return where(
        (e) => e.path.toLowerCase().contains(folderType.name.toLowerCase()));
  }

  Iterable<FileCheckboxItemData> filterSize(
      [DigitalUnit size = largeCapacity]) {
    return where((e) => e.size > size);
  }

  Iterable<FileCheckboxItemData> filterDate([Duration duration = oldDuration]) {
    final oldTime = DateTime.now().subtract(duration);
    return filterDateBefore(oldTime);
  }

  Iterable<FileCheckboxItemData> filterDateBefore(DateTime datetime) {
    return where((e) => e.timeModified.isBefore(datetime));
  }

  List<FileCheckboxItemData> toListOptimal() {
    if (this is List<FileCheckboxItemData>) {
      return this as List<FileCheckboxItemData>;
    }

    return toList();
  }
}
