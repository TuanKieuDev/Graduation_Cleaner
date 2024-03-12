import 'package:freezed_annotation/freezed_annotation.dart';

part 'package_info.freezed.dart';
part 'package_info.g.dart';

@freezed
class PackageInfo with _$PackageInfo {
  factory PackageInfo(
    final String packageName,
    final String appType,
    final num flags,
    final num category,
    final String? description,
    final String? storageUUID,
    final num uid,
  ) = _PackageInfo;

  factory PackageInfo.fromJson(Map<String, dynamic> json) =>
      _$PackageInfoFromJson(json);
}
