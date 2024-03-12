import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'quick_clean_category.freezed.dart';

enum QuickCleanCategoryType {
  hiddenCache,
  visibleCache,
  browserData,
  thumbnails,
  emptyFolders,
  appData,
  downloads,
  largeOldFiles,
  apkFiles,
}

@freezed
class QuickCleanCategory with _$QuickCleanCategory {
  const QuickCleanCategory._();

  const factory QuickCleanCategory({
    required QuickCleanCategoryType categoryType,
    required ImportantLevel importantLevel,
    required Availability availability,
    @Default([]) List<FileCheckboxItemData> checkboxItems,
  }) = _QuickCleanCategory;

  DigitalUnit get totalSize => checkboxItems.fold(
      0.kb, (previousValue, element) => previousValue + element.size);

  DigitalUnit get selectedSize => checkboxItems
      .where((element) => element.checked)
      .fold(0.kb, (previousValue, element) => previousValue + element.size);

  int get selectedCount =>
      checkboxItems.where((element) => element.checked).length;

  bool get hasItemChecked => checkboxItems.any((element) => element.checked);
  bool get isAllChecked => !checkboxItems.any((element) => !element.checked);
}
