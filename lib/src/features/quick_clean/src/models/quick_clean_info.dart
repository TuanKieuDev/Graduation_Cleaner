import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../commons/commons.dart';
import 'quick_clean_category.dart';

part 'quick_clean_info.freezed.dart';

@freezed
class QuickCleanInfo with _$QuickCleanInfo {
  const QuickCleanInfo._();

  const factory QuickCleanInfo({
    @Default([]) List<QuickCleanCategory> categories,
    DigitalUnit? cleanedSize,
    @Default([]) List<FileCheckboxItemData> cleanedItems,
    @Default([]) List<FileCheckboxItemData> failedItems,
  }) = _QuickCleanInfo;

  DigitalUnit get totalSize => categories.fold(
      0.kb, (previousValue, element) => previousValue + element.totalSize);

  DigitalUnit get selectedSize => categories.fold(
      0.kb, (previousValue, element) => previousValue + element.selectedSize);
}

enum QuickCleanStatus {
  uninitialized,
  loading,
  loaded,
  refreshing,
  cleaning,
  cleaned,
}
