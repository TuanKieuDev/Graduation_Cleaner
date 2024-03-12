import 'dart:async';
import 'dart:developer';

import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/features/apps/features/apps_consumption/controllers/battery_consumption_controller.dart';
import 'package:phone_cleaner/src/features/apps/features/notification/controller/notification_usage_controller.dart';
import 'package:phone_cleaner/src/features/apps/features/notification/models/notification_count_info.dart';
import 'package:phone_cleaner/src/features/apps/models/app_specific_type.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../features.dart';

part 'app_filter_controller.g.dart';

@riverpod
class AppFilterController extends _$AppFilterController {
  Future<AppFilterData> setParameters(AppFilterParameter appFilterParameter) =>
      update((state) {
        if (state.appFilterParameter != appFilterParameter) {
          this.state =
              const AsyncLoading<AppFilterData>().copyWithPrevious(this.state);
        }
        return fetchAndFilter(appFilterParameter);
      });

  @override
  FutureOr<AppFilterData> build() async {
    return fetchAndFilter(state.valueOrNull?.appFilterParameter);
  }

  Future<AppFilterData> fetchAndFilter(
      AppFilterParameter? appFilterParameter) async {
    if (appFilterParameter == null) {
      return const AppFilterData();
    }

    final appDataList = await _fetchData(appFilterParameter);
    final filteredList = _filter(appDataList, appFilterParameter);

    return AppFilterData(
      appDataList: filteredList,
      appFilterParameter: appFilterParameter,
      openBottoNav: state.valueOrNull?.openBottoNav ?? false,
    );
  }

  Future<List<AppCheckboxItemData>> _fetchData(
      AppFilterParameter params) async {
    if (params.sortType == SortType.screenTime ||
        params.sortType == SortType.timeOpened ||
        params.sortType == SortType.unused) {
      return _showAppUsagePeriod(params.periodType);
    } else if (params.sortType == SortType.sizeChange) {
      return _showAppGrowing();
    } else if (params.sortType == SortType.notification) {
      return _showNotification(params.periodType);
    } else if (params.sortType == SortType.batteryUse) {
      return _showBatteryUsage();
    }
    final result = await ref.watch(appsControllerProvider.future);
    return result.apps;
  }

  List<AppCheckboxItemData> _filter(
      List<AppCheckboxItemData> dataList, AppFilterParameter params) {
    List<AppCheckboxItemData> filteredList = dataList;

    filteredList = _filterAppType(filteredList, params.appType);
    filteredList = _sort(filteredList, params.sortType, params.isReversed);

    if (params.isRarelyUsed) {
      filteredList.removeWhere(
          (element) => element.totalTimeSpent > Duration.millisecondsPerHour);
    }

    if (params.sortType == SortType.size) {
      filteredList = _sortBySpecificSize(
          filteredList, params.specificType, params.isReversed);
    }

    if (params.showType == ShowType.deepCleaned) {
    } else if (params.showType == ShowType.stop) {}

    return filteredList;
  }

  List<AppCheckboxItemData> _sort(
      List<AppCheckboxItemData> appData, SortType sortType, bool isReversed) {
    if (sortType == SortType.size) {
      return _sortBySize(appData, isReversed);
    } else if (sortType == SortType.sizeChange) {
      return _sortBySizeChange(appData, isReversed);
    } else if (sortType == SortType.name) {
      return _sortByName(appData, isReversed);
    } else if (sortType == SortType.screenTime) {
      return _sortByScreenTime(appData, isReversed);
    } else if (sortType == SortType.notification) {
      return _sortByNotification(appData, isReversed);
    } else if (sortType == SortType.batteryUse) {
      return _sortByBatteryUse(appData, isReversed);
    } else if (sortType == SortType.dataUse) {
      return _sortByDataUsed(appData, isReversed);
    } else if (sortType == SortType.unused) {
      log("message");
      return _sortByUnused(appData, isReversed);
    } else if (sortType == SortType.lastUsed) {
      return _sortByLastOpened(appData, isReversed);
    } else if (sortType == SortType.timeOpened) {
      return _sortByTimeOpened(appData, isReversed);
    } else {
      return _sortBySize(appData, isReversed);
    }
  }

  List<AppCheckboxItemData> _sortBySpecificSize(
      List<AppCheckboxItemData> appData,
      AppSpecificType specificType,
      bool isReversed) {
    final newDataList = appData
        .toList()
        .map((e) => e.copyWith(specificType: specificType))
        .toList();
    final reverseComparison = isReversed ? -1 : 1;
    if (specificType == AppSpecificType.app) {
      newDataList.sort((a, b) =>
          b.appSize.value.compareTo(a.appSize.value) * reverseComparison);
      return newDataList;
    } else if (specificType == AppSpecificType.cache) {
      newDataList.sort((a, b) =>
          b.cacheSize.value.compareTo(a.cacheSize.value) * reverseComparison);
      return newDataList;
    } else if (specificType == AppSpecificType.data) {
      newDataList.sort((a, b) =>
          b.dataSize.value.compareTo(a.appSize.value) * reverseComparison);
      return newDataList;
    } else {
      return _sortBySize(appData, isReversed);
    }
  }

  Future<AppFilterData> toggleAppState(int index) => update((state) {
        final appDataList = state.appDataList.toList();
        appDataList[index] =
            appDataList[index].copyWith(checked: !appDataList[index].checked);
        return state.copyWith(
          appDataList: appDataList,
        );
      });

  Future<AppFilterData> toggleAllAppsState() => update((state) {
        final appDataList = state.appDataList.toList();
        final isAllChecked = appDataList.any((element) => !element.checked);

        return state.copyWith(
          appDataList: appDataList
              .map(
                (e) => e.copyWith(checked: isAllChecked),
              )
              .toList(),
        );
      });

  Future<AppFilterData> toggleReverse() => update((state) {
        assert(state.appFilterParameter != null);
        var newParams = state.appFilterParameter!
            .copyWith(isReversed: !state.appFilterParameter!.isReversed);

        return state.copyWith(
          appDataList: _filter(state.appDataList, newParams),
          appFilterParameter: newParams,
        );
      });

  StreamController streamController = StreamController();
  late Stream stream = streamController.stream;

  List<AppCheckboxItemData> _filterAppType(
      Iterable<AppCheckboxItemData> appDataList, AppType appType) {
    if (appType == AppType.all) {
      return appDataList.where((element) => element.isIgnore != true).toList();
    }
    if (appType == AppType.ignored) {
      return appDataList.where((element) => element.isIgnore == true).toList();
    }
    if (appType != AppType.all) {
      return appDataList
          .where((element) =>
              element.appType == appType && element.isIgnore == false)
          .toList();
    }
    return appDataList.toList();
  }

  List<AppCheckboxItemData> _sortBySize(
    List<AppCheckboxItemData> appDataList,
    bool isReversed,
  ) {
    final reverseComparison = isReversed ? -1 : 1;
    final newDataList = appDataList.toList();
    newDataList.sort((a, b) =>
        b.totalSize.value.compareTo(a.totalSize.value) * reverseComparison);
    return newDataList;
  }

  List<AppCheckboxItemData> _sortByName(
    List<AppCheckboxItemData> appDataList,
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

  List<AppCheckboxItemData> _sortByScreenTime(
      List<AppCheckboxItemData> appDataList, bool isReversed) {
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

  List<AppCheckboxItemData> _sortByDataUsed(
      List<AppCheckboxItemData> appDataList, bool isReversed) {
    final newDataList = appDataList.toList();
    final reverseComparison = isReversed ? -1 : 1;
    newDataList.sort((a, b) =>
        b.dataUsed.value.compareTo(a.dataUsed.value) * reverseComparison);

    final dataWithTrailing =
        newDataList.map((e) => e.copyWith(sortType: SortType.dataUse)).toList();

    return dataWithTrailing;
  }

  List<AppCheckboxItemData> _sortByBatteryUse(
      List<AppCheckboxItemData> appDataList, bool isReversed) {
    final newDataList = appDataList.toList();
    final reverseComparison = isReversed ? -1 : 1;
    newDataList.sort((a, b) =>
        b.batteryPercentage.compareTo(a.batteryPercentage) * reverseComparison);

    final dataWithTrailing = newDataList
        .map((e) => e.copyWith(sortType: SortType.batteryUse))
        .toList();

    return dataWithTrailing;
  }

  List<AppCheckboxItemData> _sortByUnused(
      List<AppCheckboxItemData> appDataList, bool isReversed) {
    final newDataList = appDataList.toList();
    // final reverseComparison = isReversed ? -1 : 1;
    final data =
        newDataList.where((element) => element.totalTimeSpent == 0).toList();
    final dataWithTrailing =
        data.map((e) => e.copyWith(sortType: SortType.unused)).toList();

    return dataWithTrailing;
  }

  List<AppCheckboxItemData> _sortByNotification(
      List<AppCheckboxItemData> appDataList, bool isReversed) {
    final newDataList = appDataList.toList();
    final reverseComparison = isReversed ? -1 : 1;
    newDataList.sort((a, b) =>
        b.notificationCount.compareTo(a.notificationCount) * reverseComparison);

    final dataWithTrailing = newDataList
        .map((e) => e.copyWith(sortType: SortType.notification))
        .toList();

    return dataWithTrailing;
  }

  List<AppCheckboxItemData> _sortByTimeOpened(
    List<AppCheckboxItemData> appDataList,
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

  List<AppCheckboxItemData> _sortByLastOpened(
    List<AppCheckboxItemData> appDataList,
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

  List<AppCheckboxItemData> _sortBySizeChange(
    List<AppCheckboxItemData> appDataList,
    bool isReversed,
  ) {
    final newDataList = appDataList.toList();
    final reverseComparison = isReversed ? -1 : 1;
    newDataList.sort(
        (a, b) => b.sizeChange.compareTo(a.sizeChange) * reverseComparison);

    final dataWithTrailing = newDataList
        .map((e) => e.copyWith(sortType: SortType.sizeChange))
        .toList();

    return dataWithTrailing;
  }

  Future<List<AppCheckboxItemData>> _showAppGrowing() async {
    var appsGrowingInfo = await ref.watch(appsGrowingControllerProvider.future);
    final newData = appsGrowingInfo.growingData.toList();
    return newData;
  }

  Future<List<AppCheckboxItemData>> _showBatteryUsage() async {
    final batteryConsumption =
        await ref.watch(batteryConsumptionControllerProvider.future);
    final newData = batteryConsumption.apps.toList();
    return newData;
  }

  Future<List<AppCheckboxItemData>> _showAppUsagePeriod(
      PeriodType periodType) async {
    final appsUsage = await ref.watch(appsUsageControllerProvider.future);
    final newData = periodType == PeriodType.week
        ? appsUsage[0].usageData
        : appsUsage[1].usageData;
    return newData;
  }

  List<AppCheckboxItemData> _showNotification(PeriodType periodType) {
    final newData = ref.watch(notificationUsageControllerProvider).value ??
        const NotificationCountInfo();
    return newData.dataWithNotificationWeekly;
  }
}
