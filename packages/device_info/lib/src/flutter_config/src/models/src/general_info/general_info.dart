import 'package:freezed_annotation/freezed_annotation.dart';

part 'general_info.freezed.dart';
part 'general_info.g.dart';

@freezed
class GeneralInfo with _$GeneralInfo {
  const GeneralInfo._();

  const factory GeneralInfo({
    required int usedSpace,
    required int totalSpace,
    required int usedMemory,
    required int totalMemory,
    required int freeMemory,
    required int battery,
  }) = _GeneralInfo;

  factory GeneralInfo.fromJson(Map<String, dynamic> json) =>
      _$GeneralInfoFromJson(json);
}

//flutter pub run build_runner watch --delete-conflicting-outputs
