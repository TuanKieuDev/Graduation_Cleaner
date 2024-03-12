import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/features/features.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'apps_growing_info.freezed.dart';

@freezed
class AppsGrowingInfo with _$AppsGrowingInfo {
  factory AppsGrowingInfo({
    @Default([]) List<AppCheckboxItemData> growingData,
    required PeriodType periodType,
    required int timeForAnalysis,
  }) = _AppsGrowingInfo;
}
