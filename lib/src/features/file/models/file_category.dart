import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'models.dart';

part 'file_category.freezed.dart';

@freezed
class FileCategory with _$FileCategory {
  const FileCategory._();

  const factory FileCategory({
    required String name,
    String? iconPath,
    @Default([]) List<FileCheckboxItemData> checkboxItems,
  }) = _FileCategory;

  DigitalUnit get totalSize => checkboxItems.fold(
      0.kb, (previousValue, element) => previousValue + element.size);

  DigitalUnit get selectedSize => checkboxItems
      .where((element) => element.checked)
      .fold(0.kb, (previousValue, element) => previousValue + element.size);

  int get selectedCount =>
      checkboxItems.where((element) => element.checked).length;

  bool get hasItemChecked => checkboxItems.any((element) => element.checked);
  bool get isAllChecked => checkboxItems.every((element) => element.checked);
  bool get isAllPhoto =>
      checkboxItems.every((element) => element.fileType == FileType.photo);
  bool get isAllVideo =>
      checkboxItems.every((element) => element.fileType == FileType.video);
  bool get isAllAudio =>
      checkboxItems.every((element) => element.fileType == FileType.audio);

  CheckboxStatus get checkboxStatus {
    final count = selectedCount;
    if (count == 0) return CheckboxStatus.unchecked;
    if (count == checkboxItems.length) return CheckboxStatus.checked;
    return CheckboxStatus.partiallyChecked;
  }
}
