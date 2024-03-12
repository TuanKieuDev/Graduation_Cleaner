import 'package:phone_cleaner/src/commons/models/digital_unit.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'overall_file_cache_info.freezed.dart';

@freezed
class OverallFileCacheInfo with _$OverallFileCacheInfo {
  factory OverallFileCacheInfo({
    required int totalOldPhotos,
    required int totalSimilarPhoto,
    required int totalCacheFile,
    required List<String> oldPhotoSample,
    required List<String> similarPhotoSample,
    required DigitalUnit oldPhotoSize,
    required DigitalUnit similarPhotoSize,
    required DigitalUnit cacheFileSize,
  }) = _OverallFileCacheInfo;
}
