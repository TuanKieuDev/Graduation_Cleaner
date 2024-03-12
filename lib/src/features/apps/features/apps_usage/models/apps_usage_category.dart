import 'package:phone_cleaner/src/commons/models/app_checkbox_item_data.dart';
import 'package:phone_cleaner/src/features/features.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'apps_usage_category.freezed.dart';

enum UsageType {
  timeOpened("time opened"),
  screenTime("screen time"),
  unused("unused");

  const UsageType(this.description);

  final String description;

  @override
  String toString() => description.toString();
}

@freezed
class AppsUsageCategory with _$AppsUsageCategory {
  const AppsUsageCategory._();
  const factory AppsUsageCategory({
    @Default([]) List<AppCheckboxItemData> items,
    required SortType usageType,
  }) = _AppsUsageCategory;

  int get numberOfApps => items.length;
  bool get showBadge => usageType == SortType.unused ? true : false;
}
