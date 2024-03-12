import 'package:freezed_annotation/freezed_annotation.dart';

part 'apps_usage_info.freezed.dart';

@freezed
class AppsUsageInfo with _$AppsUsageInfo {
  const factory AppsUsageInfo({
    required int totalTimeUsage,
    required int dateTime,
  }) = _AppsUsageInfo;
}
