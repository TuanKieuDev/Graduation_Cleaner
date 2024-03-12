import 'package:phone_cleaner/src/commons/models/models.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'app_filter_parameter.dart';

part 'app_filter_data.freezed.dart';

@freezed
class AppFilterData with _$AppFilterData {
  const AppFilterData._();

  const factory AppFilterData({
    @Default([]) List<AppCheckboxItemData> appDataList,
    @Default([]) List<AppCheckboxItemData> removedApps,
    @Default([]) List<AppCheckboxItemData> failedApps,
    AppFilterParameter? appFilterParameter,
    @Default(false) bool cleaning,
    @Default(false) bool openBottoNav,
  }) = _AppFilterData;

  bool get isAllChecked => appDataList.every((element) => element.checked);

  List<AppCheckboxItemData> get checkedApp {
    final result = <AppCheckboxItemData>[];
    result.addAll(appDataList.where((element) => element.checked));
    return result;
  }
}
