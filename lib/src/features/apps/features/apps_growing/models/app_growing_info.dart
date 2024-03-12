import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../commons/commons.dart';

part 'app_growing_info.freezed.dart';

@freezed
class AppGrowingInfo with _$AppGrowingInfo {
  factory AppGrowingInfo({
    required String packageName,
    required DigitalUnit increaseSizeWeekly,
  }) = _AppGrowingInfo;
}
