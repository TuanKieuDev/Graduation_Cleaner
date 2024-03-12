import 'dart:typed_data';

import 'package:phone_cleaner/src/features/apps/models/app_specific_type.dart';
import 'package:phone_cleaner/src/features/features.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../commons.dart';

part 'app_checkbox_item_data.freezed.dart';

@freezed
class AppCheckboxItemData with _$AppCheckboxItemData {
  @Assert('(iconData == null) || (svgData == null)')
  factory AppCheckboxItemData({
    required String name,
    required String packageName,
    Uint8List? iconData,
    Uint8List? svgData,
    @Default(0) int totalTimeSpent,
    @Default(0) int timeOpened,
    DateTime? lastOpened,
    required AppType appType,
    required DigitalUnit dataUsed,
    required DigitalUnit appSize,
    required DigitalUnit dataSize,
    required DigitalUnit cacheSize,
    @Default(SortType.size) SortType sortType,
    required DigitalUnit totalSize,
    @Default(false) bool checked,
    @Default(false) bool isIgnore,
    @Default(DigitalUnit.fromByte(0)) DigitalUnit sizeChange,
    @Default(0) int notificationCount,
    @Default(0) double batteryPercentage,
    AppSpecificType? specificType,
  }) = _AppCheckboxItemData;
}
