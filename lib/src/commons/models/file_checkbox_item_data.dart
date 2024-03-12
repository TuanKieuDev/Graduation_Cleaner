import 'package:phone_cleaner/src/features/file/models/file_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'digital_unit.dart';

part 'file_checkbox_item_data.freezed.dart';

@freezed
class FileCheckboxItemData with _$FileCheckboxItemData {
  const FileCheckboxItemData._();

  const factory FileCheckboxItemData({
    required String name,
    required DigitalUnit size,
    required String extensionFile,
    required String path,
    required DateTime timeModified,
    required FileType fileType,
    @Default(0) int mediaId,
    @Default(0) int mediaType,
    @Default(false) bool isApp,
    @Default(false) bool checked,
    @Default(false) bool isFolder,
    String? thumbnailPath,
  }) = _FileCheckboxItemData;
}
