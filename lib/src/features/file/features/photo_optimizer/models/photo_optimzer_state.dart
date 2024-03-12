import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'optimize_option.dart';
import 'original_option.dart';

part 'photo_optimzer_state.freezed.dart';

@freezed
class PhotoOptimizerState with _$PhotoOptimizerState {
  const factory PhotoOptimizerState({
    @Default([]) List<FileCheckboxItemData> photos,
    @Default(0) int previewPhotoIndex,
    @Default(OptimizeValue.low) OptimizeValue optimizeValue,
    @Default(OriginalOption.backup) OriginalOption originalOption,
    List<FileCheckboxItemData>? optimizedPhotos,
    List<FileCheckboxItemData>? failedToOptimizePhotos,
  }) = _PhotoOptimizerState;
}
