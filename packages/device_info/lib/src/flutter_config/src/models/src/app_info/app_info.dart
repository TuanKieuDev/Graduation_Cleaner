import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_info.freezed.dart';
part 'app_info.g.dart';

@freezed
class AppInfo with _$AppInfo {
  const AppInfo._();

  const factory AppInfo({
    required String name,
    String? iconApp,
    required String version,
    required String packageName,
    required String type,
    int? timeNotificationSent,
    int? appSize,
    int? dataSize,
    int? cacheSize,
    int? totalSizeApp,
  }) = _AppInfo;

  factory AppInfo.fromJson(Map<String, dynamic> json) =>
      _$AppInfoFromJson(json);
}
