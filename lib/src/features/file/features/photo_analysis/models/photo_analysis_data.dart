import 'package:phone_cleaner/src/features/file/models/file_category.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../commons/commons.dart';

part 'photo_analysis_data.freezed.dart';

@freezed
class PhotoAnalysisData with _$PhotoAnalysisData {
  const PhotoAnalysisData._();
  const factory PhotoAnalysisData({
    required List<FileCategory> similarPhotos,
    required List<FileCheckboxItemData> badPhotos,
    required List<FileCheckboxItemData> sensitivePhotos,
    required List<FileCheckboxItemData> oldPhotos,
  }) = _PhotoAnalysisData;

  DigitalUnit get similarPhotoSize => similarPhotos.fold(
      0.kb, (previousValue, element) => previousValue + element.totalSize);

  DigitalUnit get badPhotoSize => badPhotos.fold(
      0.kb, (previousValue, element) => previousValue + element.size);

  DigitalUnit get sensitivePhotoSize => sensitivePhotos.fold(
      0.kb, (previousValue, element) => previousValue + element.size);

  DigitalUnit get oldPhotoSize => oldPhotos.fold(
      0.kb, (previousValue, element) => previousValue + element.size);

  DigitalUnit get optimizeTotalSize =>
      similarPhotoSize + badPhotoSize + sensitivePhotoSize + oldPhotoSize;
}
