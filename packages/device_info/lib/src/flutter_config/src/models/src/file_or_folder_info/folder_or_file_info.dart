// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mime/mime.dart' as mime;

part 'folder_or_file_info.freezed.dart';
part 'folder_or_file_info.g.dart';

@freezed
class FolderOrFileInfo with _$FolderOrFileInfo {
  const FolderOrFileInfo._();
  const factory FolderOrFileInfo.folder({
    required String name,
    required int itemCount,
    required int size,
    required String path,
    required DateTime lastModified,
  }) = FolderInfo;
  const factory FolderOrFileInfo.file({
    required int mediaId,
    required int mediaType,
    required String name,
    required String path,
    required int size,
    required String extension,
    @EpochDateTimeConverter() required DateTime lastModified,
    String? mimeType,
  }) = FileInfo;
  const factory FolderOrFileInfo.folderWithChildren({
    required String name,
    required String path,
    required int size,
    required FolderInfo folderInfo,
    required List<FileInfo> children,
  }) = FolderWithChildren;

  factory FolderOrFileInfo.fromJson(Map<String, dynamic> json) =>
      _$FolderOrFileInfoFromJson(json);

  bool get isImage {
    if (this is FolderInfo) return false;
    final file = this as FileInfo;

    var mimeType = file.mimeType ?? mime.lookupMimeType(path);
    return mimeType != null && mimeType.startsWith('image');
  }

  bool get isAudio {
    if (this is FolderInfo) return false;
    final file = this as FileInfo;

    var mimeType = file.mimeType ?? mime.lookupMimeType(path);
    return mimeType != null && mimeType.startsWith('audio');
  }

  bool get isVideo {
    if (this is FolderInfo) return false;
    final file = this as FileInfo;

    var mimeType = file.mimeType ?? mime.lookupMimeType(path);
    return mimeType != null && mimeType.startsWith('video');
  }
}

class EpochDateTimeConverter implements JsonConverter<DateTime, int> {
  const EpochDateTimeConverter();

  @override
  DateTime fromJson(int json) => DateTime.fromMillisecondsSinceEpoch(json);

  @override
  int toJson(DateTime object) => object.millisecondsSinceEpoch;
}
