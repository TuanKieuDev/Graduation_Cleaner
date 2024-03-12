import 'package:phone_cleaner/src/commons/models/digital_unit.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'overall_device_storage_info.freezed.dart';

@freezed
class OverallDeviceStorageInfo with _$OverallDeviceStorageInfo {
  factory OverallDeviceStorageInfo({
    required DigitalUnit usedSpace,
    required DigitalUnit totalSpace,
    required DigitalUnit usedMemory,
    required DigitalUnit totalMemory,
    required int extendableBatteryPercentage,
  }) = _OverallDeviceStorageInfo;
}
