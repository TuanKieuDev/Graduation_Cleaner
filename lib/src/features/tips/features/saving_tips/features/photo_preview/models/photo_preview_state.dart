import 'package:phone_cleaner/src/features/features.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'photo_preview_state.freezed.dart';

@freezed
class PhotoPreviewState with _$PhotoPreviewState {
  const PhotoPreviewState._();
  const factory PhotoPreviewState({
    PhotoAnalysisData? photoAnalysisData,
  }) = _PhotoPreviewState;

  bool get isShowPhotoPreview =>
      isShowBadPhotos ||
      isShowSensitivePhotos ||
      isShowOldPhotos ||
      isShowSimilarPhotos;

  bool get isShowSimilarPhotos =>
      photoAnalysisData?.similarPhotos.isNotEmpty ?? false;

  bool get isShowBadPhotos => photoAnalysisData?.badPhotos.isNotEmpty ?? false;

  bool get isShowSensitivePhotos =>
      photoAnalysisData?.sensitivePhotos.isNotEmpty ?? false;

  bool get isShowOldPhotos => photoAnalysisData?.oldPhotos.isNotEmpty ?? false;
}
