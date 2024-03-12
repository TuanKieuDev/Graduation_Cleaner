import 'package:device_info/device_info.dart';

class ErrorFileInfo extends PermissionException implements FileInfo {
  ErrorFileInfo(super.message);

  @override
  String get extension => throw this;

  @override
  DateTime get lastModified => throw this;

  @override
  String? get mimeType => throw this;

  @override
  String get name => throw this;

  @override
  String get path => throw this;

  @override
  int get size => throw this;

  @override
  Map<String, dynamic> toJson() => throw this;

  @override
  bool get isAudio => throw this;

  @override
  bool get isImage => throw this;

  @override
  bool get isVideo => throw this;

  @override
  get copyWith => throw this;

  @override
  TResult map<TResult extends Object?>(
      {required TResult Function(FolderInfo value) folder,
      required TResult Function(FileInfo value) file,
      required TResult Function(FolderWithChildren value) folderWithChildren}) {
    throw this;
  }

  @override
  TResult? mapOrNull<TResult extends Object?>(
      {TResult? Function(FolderInfo value)? folder,
      TResult? Function(FileInfo value)? file,
      TResult? Function(FolderWithChildren value)? folderWithChildren}) {
    throw this;
  }

  @override
  TResult maybeMap<TResult extends Object?>(
      {TResult Function(FolderInfo value)? folder,
      TResult Function(FileInfo value)? file,
      TResult Function(FolderWithChildren value)? folderWithChildren,
      required TResult Function() orElse}) {
    throw this;
  }

  @override
  TResult maybeWhen<TResult extends Object?>(
      {TResult Function(String name, int itemCount, int size, String path,
              DateTime lastModified)?
          folder,
      TResult Function(
              int mediaId,
              int mediaType,
              String name,
              String path,
              int size,
              String extension,
              DateTime lastModified,
              String? mimeType)?
          file,
      TResult Function(String name, String path, int size,
              FolderInfo folderInfo, List<FileInfo> children)?
          folderWithChildren,
      required TResult Function() orElse}) {
    throw this;
  }

  @override
  // TODO: implement mediaId
  int get mediaId => throw this;

  @override
  // TODO: implement mediaType
  int get mediaType => throw this;

  @override
  TResult when<TResult extends Object?>(
      {required TResult Function(String name, int itemCount, int size,
              String path, DateTime lastModified)
          folder,
      required TResult Function(
              int mediaId,
              int mediaType,
              String name,
              String path,
              int size,
              String extension,
              DateTime lastModified,
              String? mimeType)
          file,
      required TResult Function(String name, String path, int size,
              FolderInfo folderInfo, List<FileInfo> children)
          folderWithChildren}) {
    // TODO: implement when
    throw this;
  }

  @override
  TResult? whenOrNull<TResult extends Object?>(
      {TResult? Function(String name, int itemCount, int size, String path,
              DateTime lastModified)?
          folder,
      TResult? Function(
              int mediaId,
              int mediaType,
              String name,
              String path,
              int size,
              String extension,
              DateTime lastModified,
              String? mimeType)?
          file,
      TResult? Function(String name, String path, int size,
              FolderInfo folderInfo, List<FileInfo> children)?
          folderWithChildren}) {
    // TODO: implement whenOrNull
    throw this;
  }
}
