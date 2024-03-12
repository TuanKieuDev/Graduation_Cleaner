import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_info_size.freezed.dart';
part 'app_info_size.g.dart';

@freezed
class AppInfoSize with _$AppInfoSize {
  const AppInfoSize._();

  const factory AppInfoSize({
    required String packageName,
    required int appSize,
    required int dataSize,
    required int cacheSize,
  }) = _AppInfoSize;

  factory AppInfoSize.fromJson(Map<String, dynamic> json) =>
      _$AppInfoSizeFromJson(json);

  int get totalSize => appSize + dataSize + cacheSize;
}

//flutter pub run build_runner watch --delete-conflicting-outputs
