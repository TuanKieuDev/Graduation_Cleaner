import 'package:phone_cleaner/src/commons/models/digital_unit.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../commons/models/file_checkbox_item_data.dart';

part 'large_videos.freezed.dart';

@freezed
class LargeVideos with _$LargeVideos {
  const LargeVideos._();
  const factory LargeVideos({
    @Default([]) List<FileCheckboxItemData> videos,
  }) = _LargeVideos;

  int get totalVideos => videos.length;

  DigitalUnit get totalSize => videos.fold(
      0.kb, (previousValue, element) => previousValue + element.size);
}
