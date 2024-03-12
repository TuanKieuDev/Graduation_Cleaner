import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/features/apps/apps.dart';
import 'package:flutter/material.dart';

extension AppCheckboxItemDataFilter on Iterable<AppCheckboxItemData> {
  Iterable<AppCheckboxItemData> filterWithParams(AppFilterParameter params) {
    Iterable<AppCheckboxItemData> filteredList = toList();

    filteredList = _filterAppType(filteredList, params.appType);

    if (params.showType == ShowType.deepCleaned) {
    } else if (params.showType == ShowType.stop) {}

    filteredList = filteredList._sortByType(
        filteredList, params.sortType, params.isReversed);

    return filteredList;
  }

  Iterable<AppCheckboxItemData> _sortByType(
      Iterable<AppCheckboxItemData> appData,
      SortType sortType,
      bool isReversed) {
    if (sortType == SortType.size) {
      return _sortBySize(appData, isReversed);
    } else if (sortType == SortType.sizeChange) {
      // TODO: Handle sortType size Change.
      return this;
    } else if (sortType == SortType.name) {
      return _sortByName(appData, isReversed);
    } else if (sortType == SortType.screenTime) {
      return _sortByScreenTime(appData, isReversed);
    } else if (sortType == SortType.dataUse) {
      return _sortByDataUsed(appData, isReversed);
    } else if (sortType == SortType.unused) {
      return _sortByUnused(appData, isReversed);
    } else if (sortType == SortType.lastUsed) {
      return _sortByLastOpened(appData, isReversed);
    } else if (sortType == SortType.timeOpened) {
      return _sortByTimeOpened(appData, isReversed);
    } else {
      return _sortBySize(appData, isReversed);
    }
  }

  Iterable<AppCheckboxItemData> _filterAppType(
      Iterable<AppCheckboxItemData> appDataList, AppType appType) {
    if (appType != AppType.all) {
      return appDataList
          .where((element) => element.appType == appType)
          .toList();
    }
    return appDataList.toList();
  }

  Iterable<AppCheckboxItemData> _sortBySize(
    Iterable<AppCheckboxItemData> appDataList,
    bool isReversed,
  ) {
    final reverseComparison = isReversed ? -1 : 1;
    final newDataList = appDataList.toList();
    newDataList.sort((a, b) =>
        b.totalSize.value.compareTo(a.totalSize.value) * reverseComparison);

    return newDataList;
  }

  Iterable<AppCheckboxItemData> _sortByName(
    Iterable<AppCheckboxItemData> appDataList,
    bool isReversed,
  ) {
    final reverseComparison = isReversed ? -1 : 1;

    final newDataList = appDataList.toList();
    newDataList.sort((a, b) =>
        a.name
            .toUpperCase()
            .toDiacriticsRemove
            .compareTo(b.name.toUpperCase().toDiacriticsRemove) *
        reverseComparison);
    return newDataList;
  }

  Iterable<AppCheckboxItemData> _sortByScreenTime(
      Iterable<AppCheckboxItemData> appDataList, bool isReversed) {
    final newDataList = appDataList.toList();
    final reverseComparison = isReversed ? -1 : 1;

    newDataList.sort(
      (a, b) =>
          b.totalTimeSpent.compareTo(a.totalTimeSpent) * reverseComparison,
    );
    final dataWithTrailing = newDataList
        .map((e) => e.copyWith(sortType: SortType.screenTime))
        .toList();

    return dataWithTrailing;
  }

  Iterable<AppCheckboxItemData> _sortByDataUsed(
      Iterable<AppCheckboxItemData> appDataList, bool isReversed) {
    final newDataList = appDataList.toList();
    final reverseComparison = isReversed ? -1 : 1;
    newDataList.sort((a, b) =>
        b.dataUsed.value.compareTo(a.dataUsed.value) * reverseComparison);

    final dataWithTrailing =
        newDataList.map((e) => e.copyWith(sortType: SortType.dataUse)).toList();

    return dataWithTrailing;
  }

  Iterable<AppCheckboxItemData> _sortByUnused(
      Iterable<AppCheckboxItemData> appDataList, bool isReversed) {
    final newDataList = appDataList;
    // final reverseComparison = isReversed ? -1 : 1;
    final data = newDataList.where((element) => element.totalTimeSpent == 0);
    final dataWithTrailing =
        data.map((e) => e.copyWith(sortType: SortType.unused)).toList();

    debugPrint('dataWithTrailing: ${dataWithTrailing.map((e) => [
          e.name,
          e.totalTimeSpent
        ])}');

    return dataWithTrailing;
  }

  Iterable<AppCheckboxItemData> _sortByTimeOpened(
    Iterable<AppCheckboxItemData> appDataList,
    bool isReversed,
  ) {
    final newDataList = appDataList.toList();
    final reverseComparison = isReversed ? -1 : 1;
    newDataList.sort(
        (a, b) => b.timeOpened.compareTo(a.timeOpened) * reverseComparison);

    final dataWithTrailing = newDataList
        .map((e) => e.copyWith(sortType: SortType.timeOpened))
        .toList();

    return dataWithTrailing;
  }

  Iterable<AppCheckboxItemData> _sortByLastOpened(
    Iterable<AppCheckboxItemData> appDataList,
    bool isReversed,
  ) {
    final newDataList = appDataList.toList();
    final reverseComparison = isReversed ? -1 : 1;
    newDataList.sort(
        (a, b) => b.lastOpened!.compareTo(a.lastOpened!) * reverseComparison);

    final dataWithTrailing = newDataList
        .map((e) => e.copyWith(sortType: SortType.lastUsed))
        .toList();

    return dataWithTrailing;
  }
}
