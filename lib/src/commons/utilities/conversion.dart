import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/features/file/models/file_type.dart';
import 'package:device_info/device_info.dart';

extension FolderOrFileInfoX on FolderOrFileInfo {
  FileCheckboxItemData toFileCheckBoxItemData() {
    return map(
      file: (value) => FileCheckboxItemData(
        mediaId: value.mediaId,
        mediaType: value.mediaType,
        name: name,
        size: value.size.bytes,
        extensionFile: value.extension,
        path: path,
        timeModified: value.lastModified,
        fileType: value.toFileType(),
      ),
      folder: (value) => throw TypeError(),
      folderWithChildren: (value) => throw TypeError(),
    );
  }
}

extension ListFolderOrFileInfoX on List<FolderOrFileInfo> {
  List<FileCheckboxItemData> toListOfFileCheckBoxItemData() {
    return map((e) => e.toFileCheckBoxItemData()).toList();
  }
}

extension FileInfoX on FileInfo {
  FileType toFileType() {
    if (isImage) {
      return FileType.photo;
    }

    if (isVideo) {
      return FileType.video;
    }

    if (isAudio) {
      return FileType.audio;
    }

    return FileType.other;
  }
}
