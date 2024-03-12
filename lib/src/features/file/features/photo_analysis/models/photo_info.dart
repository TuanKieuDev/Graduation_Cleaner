import 'package:phone_cleaner/src/commons/models/digital_unit.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'photo_info.freezed.dart';

@freezed
class PhotoInfo with _$PhotoInfo {
  const factory PhotoInfo({
    required String name,
    required String source,
    required DigitalUnit size,
    required int timeModified,
  }) = _PhotoInfo;
}
