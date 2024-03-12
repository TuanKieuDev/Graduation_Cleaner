import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../commons/commons.dart';
part 'quick_boost_info.freezed.dart';

@freezed
class QuickBoostInfo with _$QuickBoostInfo {
  const factory QuickBoostInfo({
    DigitalUnit? freeMemory,
    DigitalUnit? savedSpace,
  }) = _QuickBoostInfo;
}
