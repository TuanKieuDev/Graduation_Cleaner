import 'package:phone_cleaner/src/commons/models/models.dart';
import 'package:phone_cleaner/src/features/features.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'file_filter_data.freezed.dart';

@freezed
class FileFilterData with _$FileFilterData {
  const FileFilterData._();

  const factory FileFilterData({
    @Default([]) List<FileCategory> fileDataList,
    @Default([]) List<FileCheckboxItemData> cleanedFiles,
    @Default([]) List<FileCheckboxItemData> failedFiles,
    FileFilterParameter? fileFilterParameter,
    @Default(false) bool cleaning,
    @Default(false) bool openBottoNav,
    @Default(true) bool displayGridLayout,
  }) = _FileFilterData;

  bool get isAllChecked =>
      fileDataList.every((element) => element.isAllChecked);

  List<FileCheckboxItemData> get checkedCheckboxItems {
    final result = <FileCheckboxItemData>[];
    for (var category in fileDataList) {
      result.addAll(category.checkboxItems.where((element) => element.checked));
    }
    return result;
  }
}
