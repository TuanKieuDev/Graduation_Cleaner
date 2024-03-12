import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/features/apps/models/period_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'models.dart';

part 'apps_usage_period_data.freezed.dart';

@freezed
class AppsUsagePeriodData with _$AppsUsagePeriodData {
  const factory AppsUsagePeriodData({
    @Default([]) List<AppCheckboxItemData> usageData,
    @Default([]) List<AppsUsageCategory> categories,
    required PeriodType periodType,
    required List<BarChartData> barChartData,
  }) = _AppsUsagePeriodData;
}
