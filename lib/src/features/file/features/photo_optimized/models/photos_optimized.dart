import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'photos_optimized.freezed.dart';

@freezed
class PhotosOptimized with _$PhotosOptimized {
  const PhotosOptimized._();
  const factory PhotosOptimized(
      {@Default([]) List<FileCheckboxItemData> photos}) = _PhotosOptimized;

  DigitalUnit get totalSize => photos.fold(
      0.kb, (previousValue, element) => previousValue + element.size);
}
