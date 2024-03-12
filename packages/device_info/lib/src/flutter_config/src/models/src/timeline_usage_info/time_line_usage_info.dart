import 'package:freezed_annotation/freezed_annotation.dart';

part 'time_line_usage_info.freezed.dart';
part 'time_line_usage_info.g.dart';

@freezed
class TimeLineUsageInfo with _$TimeLineUsageInfo {
  const TimeLineUsageInfo._();

  const factory TimeLineUsageInfo({
    required DateTime dateTime,
    required int appUsageTime,
  }) = _TimeLineUsageInfo;

  factory TimeLineUsageInfo.fromJson(Map<String, dynamic> json) =>
      _$TimeLineUsageInfoFromJson(json);
}
