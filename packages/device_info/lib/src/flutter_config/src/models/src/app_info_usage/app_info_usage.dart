import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_info_usage.freezed.dart';
part 'app_info_usage.g.dart';

@freezed
class AppInfoUsage with _$AppInfoUsage {
  const AppInfoUsage._();

  const factory AppInfoUsage({
    required String packageName,
    @Default(0) int totalTimeSpent,
    @Default(0) int totalOpened,
  }) = _AppInfoUsage;

  factory AppInfoUsage.fromJson(Map<String, dynamic> json) =>
      _$AppInfoUsageFromJson(json);
}
