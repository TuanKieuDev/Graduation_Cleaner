import 'package:phone_cleaner/src/commons/models/digital_unit.dart';
import 'package:phone_cleaner/src/commons/models/file_checkbox_item_data.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'file_cache_info.freezed.dart';

@freezed
class FileCacheInfo with _$FileCacheInfo {
  const FileCacheInfo._();

  factory FileCacheInfo({
    required DigitalUnit totalSpace,
    required DigitalUnit usedSpace,
    required List<FileCheckboxItemData> files,
    required List<FileCheckboxItemData> images,
    required List<FileCheckboxItemData> videos,
    required List<FileCheckboxItemData> largeVideos,
    required List<FileCheckboxItemData> sounds,
    required List<FileCheckboxItemData> otherFiles,
  }) = _FileCacheInfo;

  DigitalUnit get imagesSize => images.fold(
      0.bytes, (previousValue, element) => previousValue + element.size);

  DigitalUnit get videosSize => videos.fold(
      0.bytes, (previousValue, element) => previousValue + element.size);

  DigitalUnit get soundsSize => sounds.fold(
      0.bytes, (previousValue, element) => previousValue + element.size);

  DigitalUnit get othersSize => otherFiles.fold(
      0.bytes, (previousValue, element) => previousValue + element.size);
}
