import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:ui';

import 'package:device_info/device_info.dart';
import 'package:device_info/src/flutter_config/src/utils/file_checker.dart';
import 'package:device_info/src/native_connection/src/native_calling/file_manager_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mime/mime.dart' as mime;
import 'package:path/path.dart' as path_ulti;

class FileManager {
  FileManager();

  late FileChecker _fileChecker;

  Future<Map<SystemEntityType, List<FolderOrFileInfo>>> isolateQuery(
      Map<SystemEntityType, FileQueryParameter?> parameters) async {
    RootIsolateToken rootIsolateToken = ServicesBinding.rootIsolateToken!;
    final result = compute(_callIsolateQuery, [rootIsolateToken, parameters]);
    return result;
  }

  Future<Map<SystemEntityType, List<FolderOrFileInfo>>> _callIsolateQuery(
      List params) {
    BackgroundIsolateBinaryMessenger.ensureInitialized(
        params[0] as RootIsolateToken);
    DartPluginRegistrant.ensureInitialized();
    try {
      return fileQuery(params[1]);
    } catch (e) {
      return Future.value({});
    }
  }

  Future<Map<SystemEntityType, List<FolderOrFileInfo>>> fileQuery(
      Map<SystemEntityType, FileQueryParameter?> parameters) async {
    var externalPath = await FileManagerPlatform.instance.getExternalPath();

    _fileChecker = FileChecker(externalPath);

    FileSystemEntity dir = Directory(externalPath);
    var entities = Queue<FileSystemEntity>();
    var futures = Queue<Future>();
    entities.add(dir);
    var result = <SystemEntityType, List<FolderOrFileInfo>>{};

    for (var type in parameters.keys) {
      result[type] = <FolderOrFileInfo>[];
    }

    final appDataEntities = <FolderOrFileInfo>[];

    final mediaFuture = getMediaByAndroidNative(result, parameters);
    futures.add(mediaFuture);

    while (entities.isNotEmpty || futures.isNotEmpty) {
      if (entities.isEmpty) {
        await futures.removeFirst();
        continue;
      }
      dir = entities.removeFirst();
      if (dir is Directory) {
        final Directory entity = dir;
        final dirFuture = entity.list().toList().then((subEntities) {
          entities.addAll(subEntities);

          final statFuture = entity.stat().then((value) {
            final folderInfo = FolderInfo(
                name: path_ulti.basename(entity.path),
                itemCount: subEntities.length,
                size: value.size,
                path: entity.path,
                lastModified: value.modified);

            final isEmptyFolder =
                parameters.containsKey(SystemEntityType.emptyFolder) &&
                    subEntities.isEmpty;

            final isThumbnail =
                parameters.containsKey(SystemEntityType.thumbnail) &&
                    folderInfo.name == ".thumbnails";

            final isVisibleCache =
                parameters.containsKey(SystemEntityType.visibleCache) &&
                    path_ulti.isWithin(
                        '$externalPath/Android/data', folderInfo.path) &&
                    folderInfo.path.toLowerCase().contains('cache');

            final isAppData =
                parameters.containsKey(SystemEntityType.appData) &&
                    path_ulti.isWithin(
                        '$externalPath/Pictures/', folderInfo.path) &&
                    !folderInfo.name.startsWith('.');

            if (isEmptyFolder) {
              result[SystemEntityType.emptyFolder]!.add(folderInfo);
            }

            if (isThumbnail) {
              result[SystemEntityType.thumbnail]!.add(folderInfo);
            }

            if (isVisibleCache) {
              result[SystemEntityType.visibleCache]!.add(folderInfo);
            }

            if (isAppData) {
              appDataEntities.add(folderInfo);
            }
          });
          futures.add(statFuture);
        }).onError((error, stackTrace) {
          final isVisibleCache =
              path_ulti.equals('$externalPath/Android/data', entity.path);
          if (isVisibleCache &&
              parameters.containsKey(SystemEntityType.visibleCache)) {
            result[SystemEntityType.visibleCache]!.add(ErrorFolderInfo(
                "Due to Android restrictions, visible cache can only be shown on a computer."));
          }
        });
        futures.add(dirFuture);
      } else if (dir is File) {
        final File file = dir;
        final length = file.length();
        final lastModified = file.lastModified();

        final future = Future.wait([length, lastModified]).then((value) {
          final fileInfo = FileInfo(
              mediaId: -1, //TODO: Consider: it seem not safe
              mediaType: 0,
              mimeType: mime.lookupMimeType(file.path),
              name: path_ulti.basename(file.path),
              path: file.path,
              size: value[0] as int,
              extension: path_ulti.extension(file.path),
              lastModified: (value[1] as DateTime));

          final isApk = fileInfo.extension == ".apk";

          final isDownloaded =
              path_ulti.isWithin('$externalPath/Download', fileInfo.path);

          final isImage = fileInfo.mimeType?.startsWith('image') ?? false;
          final isAudio = fileInfo.mimeType?.startsWith('audio') ?? false;
          final isVideo = fileInfo.mimeType?.startsWith('video') ?? false;
          final isMedia = isImage || isAudio || isVideo;
          final isAppData = parameters.containsKey(SystemEntityType.appData) &&
              path_ulti.isWithin('$externalPath/Pictures/', fileInfo.path);

          if (parameters.containsKey(SystemEntityType.downloaded) &&
              isDownloaded) {
            result[SystemEntityType.downloaded]!.add(fileInfo);
          }

          if (parameters.containsKey(SystemEntityType.downloadedDocument) &&
              isDownloaded) {
            final isDocument = fileInfo.mimeType?.contains('document') ?? false;
            if (isDocument) {
              result[SystemEntityType.downloadedDocument]!.add(fileInfo);
            }
          }

          if (parameters.containsKey(SystemEntityType.nonMediaFile) &&
              !isMedia) {
            result[SystemEntityType.nonMediaFile]!.add(fileInfo);
          }

          if (isApk && parameters.containsKey(SystemEntityType.apkFile)) {
            result[SystemEntityType.apkFile]!.add(fileInfo);
          }

          if (isApk && parameters.containsKey(SystemEntityType.installedApk)) {
            final future = FileManagerPlatform.instance
                .isApkInstalled(fileInfo.path)
                .then((value) {
              if (!value) return;

              result[SystemEntityType.installedApk]!.add(fileInfo);
            });

            futures.add(future);
          }

          if (parameters.containsKey(SystemEntityType.largeOldFile)) {
            assert(parameters[SystemEntityType.largeOldFile] != null);

            final largeOldFileParameter =
                parameters[SystemEntityType.largeOldFile]
                    as LargeOldFileParameter;

            final isLargeAndOld =
                (fileInfo.size >= largeOldFileParameter.minimumBytes &&
                    fileInfo.lastModified.isBefore(DateTime.now()
                        .subtract(largeOldFileParameter.oldDuration)));

            if (isLargeAndOld) {
              result[SystemEntityType.largeOldFile]!.add(fileInfo);
            }
          }

          if (parameters.containsKey(SystemEntityType.largeNewFile)) {
            assert(parameters[SystemEntityType.largeNewFile] != null);

            final largeNewFileParameter =
                parameters[SystemEntityType.largeNewFile]
                    as LargeNewFileParameter;

            final isLargeAndNew =
                (fileInfo.size >= largeNewFileParameter.minimumBytes &&
                    fileInfo.lastModified.isAfter(DateTime.now()
                        .subtract(largeNewFileParameter.newDuration)));

            if (isLargeAndNew) {
              result[SystemEntityType.largeNewFile]!.add(fileInfo);
            }
          }

          if (isAppData) {
            appDataEntities.add(fileInfo);
          }
        });
        futures.add(future);
      }
    }

    if (parameters.containsKey(SystemEntityType.appData)) {
      final appDataPath = '$externalPath/Pictures';
      final appDataFolderMap = <String, List<FolderOrFileInfo>>{};
      for (final entity in appDataEntities) {
        FileSystemEntity appDataDirectory =
            entity is FileInfo ? File(entity.path) : Directory(entity.path);
        // Search the app root directory
        while (appDataDirectory.parent.path != appDataPath &&
            !path_ulti.equals(appDataDirectory.path, externalPath)) {
          appDataDirectory = appDataDirectory.parent;
        }

        if (path_ulti.equals(appDataDirectory.path, appDataPath)) {
          continue;
        }

        if (appDataDirectory is File) {
          continue;
        }

        if (path_ulti.basename(appDataDirectory.path).startsWith('.')) {
          continue;
        }

        appDataFolderMap.putIfAbsent(appDataDirectory.path, () => []);
        appDataFolderMap[appDataDirectory.path]!.add(entity);
      }

      for (var appDataFolder in appDataFolderMap.entries) {
        Directory appDataDirectory = Directory(appDataFolder.key);

        final future = appDataDirectory.stat().then((stat) {
          final fileInfos = appDataFolder.value.whereType<FileInfo>().toList();
          final size = appDataFolder.value.fold(
              0, (previousValue, element) => previousValue + element.size);

          var folder = FolderInfo(
            name: path_ulti.basename(appDataFolder.key),
            itemCount: fileInfos.length,
            size: size,
            path: appDataFolder.key,
            lastModified: stat.modified,
          );
          final folderWithChildren = FolderOrFileInfo.folderWithChildren(
            name: folder.name,
            path: folder.path,
            size: size,
            folderInfo: folder,
            children: fileInfos,
          );

          result[SystemEntityType.appData]!.add(folderWithChildren);
        }).onError((error, stackTrace) {
          print(error);
        });
        await future;
        // futures.add(future);
      }
    }

    await Future.wait(futures);

    return result;
  }

  Future<dynamic> getMediaByAndroidNative(
    Map<SystemEntityType, List<FolderOrFileInfo>> result,
    Map<SystemEntityType, FileQueryParameter?> parameters,
  ) {
    List<Future> futures = [];

    futures.add(getPhotoMediaByAndroidNative(result, parameters));
    futures.add(getVideoMediaByAndroidNative(result, parameters));
    futures.add(getAudioMediaByAndroidNative(result, parameters));
    futures.add(getAllMediaFilesByAndroidNative(result, parameters));

    return Future.wait(futures);
  }

  Future<dynamic> getPhotoMediaByAndroidNative(
    Map<SystemEntityType, List<FolderOrFileInfo>> result,
    Map<SystemEntityType, FileQueryParameter?> parameters,
  ) async {
    List<FileInfo> allImages = [];
    if (parameters.containsKey(SystemEntityType.image) ||
        parameters.containsKey(SystemEntityType.optimizablePhoto) ||
        parameters.containsKey(SystemEntityType.sensitiveImage) ||
        parameters.containsKey(SystemEntityType.oldPhotos) ||
        parameters.containsKey(SystemEntityType.largeOldPhoto) ||
        parameters.containsKey(SystemEntityType.screenshot) ||
        parameters.containsKey(SystemEntityType.newScreenshot)) {
      allImages = await getAllImages();
    }

    if (parameters.containsKey(SystemEntityType.image)) {
      result[SystemEntityType.image] = allImages;
    }

    List<Future> futures = [];

    for (FileInfo fileInfo in allImages) {
      if (parameters.containsKey(SystemEntityType.optimizablePhoto)) {
        final future = checkOptimizableImage(fileInfo.path);
        future.then(
          (isOptimizableImage) {
            if (isOptimizableImage) {
              result[SystemEntityType.optimizablePhoto]!.add(fileInfo);
            }
          },
        );
        futures.add(future);
      }

      if (parameters.containsKey(SystemEntityType.sensitiveImage)) {
        final isSensitiveImage = _fileChecker.isSensitiveImage(fileInfo.path);
        if (isSensitiveImage) {
          result[SystemEntityType.sensitiveImage]!.add(fileInfo);
        }
      }

      if (parameters.containsKey(SystemEntityType.oldPhotos)) {
        final oldFileArgument =
            parameters[SystemEntityType.oldPhotos] as OldFileParameter;

        final isOldPhoto = _fileChecker.isOldFile(fileInfo.lastModified,
            DateTime.now().subtract(oldFileArgument.oldDuration));
        if (isOldPhoto) {
          result[SystemEntityType.oldPhotos]!.add(fileInfo);
        }
      }

      if (parameters.containsKey(SystemEntityType.largeOldPhoto)) {
        assert(parameters[SystemEntityType.largeOldPhoto] != null);

        final largeOldPhotoParameter =
            parameters[SystemEntityType.largeOldPhoto] as LargeOldFileParameter;

        final isLargeOldPhoto = _fileChecker.isLargeOldFile(
            fileInfo.lastModified,
            DateTime.now().subtract(largeOldPhotoParameter.oldDuration),
            fileInfo.size,
            largeOldPhotoParameter.minimumBytes);

        if (isLargeOldPhoto) {
          result[SystemEntityType.largeOldPhoto]!.add(fileInfo);
        }
      }

      if (parameters.containsKey(SystemEntityType.screenshot)) {
        final isScreenShot = _fileChecker.isScreenShot(fileInfo.path);
        if (isScreenShot) {
          result[SystemEntityType.screenshot]!.add(fileInfo);
        }
      }

      if (parameters.containsKey(SystemEntityType.newScreenshot)) {
        final newFileArgument =
            parameters[SystemEntityType.newScreenshot] as NewFileParameter;

        final isNewScreenshot = _fileChecker.isNewScreenShot(
            fileInfo.path,
            fileInfo.lastModified,
            DateTime.now().subtract(newFileArgument.newDuration));

        if (isNewScreenshot) {
          result[SystemEntityType.newScreenshot]!.add(fileInfo);
        }
      }
    }

    return Future.wait(futures);
  }

  Future<dynamic> getVideoMediaByAndroidNative(
    Map<SystemEntityType, List<FolderOrFileInfo>> result,
    Map<SystemEntityType, FileQueryParameter?> parameters,
  ) async {
    List<FileInfo> allVideos = [];
    if (parameters.containsKey(SystemEntityType.video) ||
        parameters.containsKey(SystemEntityType.largeOldVideo) ||
        parameters.containsKey(SystemEntityType.largeNewVideo)) {
      allVideos = await getAllVideos();
    }

    if (parameters.containsKey(SystemEntityType.video)) {
      result[SystemEntityType.video] = allVideos;
    }

    List<Future> futures = [];

    for (FileInfo fileInfo in allVideos) {
      if (parameters.containsKey(SystemEntityType.largeOldVideo)) {
        assert(parameters[SystemEntityType.largeOldVideo] != null);

        final largeOldFileParameter =
            parameters[SystemEntityType.largeOldVideo] as LargeOldFileParameter;

        final isLargeOldVideo = _fileChecker.isLargeOldFile(
            fileInfo.lastModified,
            DateTime.now().subtract(largeOldFileParameter.oldDuration),
            fileInfo.size,
            largeOldFileParameter.minimumBytes);

        if (isLargeOldVideo) {
          result[SystemEntityType.largeOldVideo]!.add(fileInfo);
        }
      }

      if (parameters.containsKey(SystemEntityType.largeNewVideo)) {
        assert(parameters[SystemEntityType.largeNewVideo] != null);

        final largeNewFileParameter =
            parameters[SystemEntityType.largeNewVideo] as LargeNewFileParameter;

        final isLargeNewVideo = _fileChecker.isLargeNewFile(
            fileInfo.lastModified,
            DateTime.now().subtract(largeNewFileParameter.newDuration),
            fileInfo.size,
            largeNewFileParameter.minimumBytes);

        if (isLargeNewVideo) {
          result[SystemEntityType.largeNewVideo]!.add(fileInfo);
        }
      }
    }

    return Future.wait(futures);
  }

  Future<dynamic> getAudioMediaByAndroidNative(
    Map<SystemEntityType, List<FolderOrFileInfo>> result,
    Map<SystemEntityType, FileQueryParameter?> parameters,
  ) {
    if (parameters.containsKey(SystemEntityType.audio)) {
      return getAllAudios().then((allAudios) {
        result[SystemEntityType.audio] = allAudios;
      });
    }
    return Future.value(null);
  }

  Future<dynamic> getAllMediaFilesByAndroidNative(
    Map<SystemEntityType, List<FolderOrFileInfo>> result,
    Map<SystemEntityType, FileQueryParameter?> parameters,
  ) async {
    List<FileInfo> allMediaFiles = [];
    if (parameters.containsKey(SystemEntityType.mediaFile) ||
        parameters.containsKey(SystemEntityType.mediaFolder)) {
      allMediaFiles = await getAllMediaFiles();
    }

    if (parameters.containsKey(SystemEntityType.mediaFile)) {
      result[SystemEntityType.mediaFile] = allMediaFiles;
    }

    List<Future> futures = [];

    if (parameters.containsKey(SystemEntityType.mediaFolder)) {
      final mediaFolderMap = <String, List<FileInfo>>{};
      for (FileInfo fileInfo in allMediaFiles) {
        final parent = File(fileInfo.path).parent;
        if (!mediaFolderMap.containsKey(parent.path)) {
          mediaFolderMap[parent.path] = [];
        }
        mediaFolderMap[parent.path]!.add(fileInfo);
      }

      final mediaFolders = <FolderWithChildren>[];
      for (final entry in mediaFolderMap.entries) {
        final directory = Directory(entry.key);
        final fileInfos = entry.value;
        final name = path_ulti.basename(directory.path);
        final future = directory.stat().then((stat) {
          final folder = FolderInfo(
              name: name,
              itemCount: fileInfos.length,
              size: fileInfos.fold(
                  0, (previousValue, element) => element.size + previousValue),
              path: directory.path,
              lastModified: stat.modified);
          mediaFolders.add(FolderWithChildren(
              name: name,
              path: directory.path,
              size: folder.size,
              folderInfo: folder,
              children: fileInfos));
        });
        futures.add(future);
      }

      final mediaFolderFuture = Future.wait(futures);

      mediaFolderFuture.then((value) {
        result[SystemEntityType.mediaFolder] = mediaFolders;
      });

      futures.add(mediaFolderFuture);
    }

    return Future.wait(futures);
  }

  Future<Set<SystemEntityType>> convertToSystemEntityType(
      FolderOrFileInfo folderOrFileInfo) async {
    final result = <SystemEntityType>{};
    if (folderOrFileInfo is FolderInfo &&
        folderOrFileInfo.name == '.thumbnail') {
      result.add(SystemEntityType.thumbnail);
      return result;
    }

    if (folderOrFileInfo is! FileInfo) return result;

    final fileInfo = folderOrFileInfo;
    final isImage = fileInfo.mimeType?.startsWith('image') ?? false;
    final isAudio = fileInfo.mimeType?.startsWith('audio') ?? false;
    final isVideo = fileInfo.mimeType?.startsWith('video') ?? false;
    final isMedia = isImage || isAudio || isVideo;
    final isApk = fileInfo.extension == ".apk";

    if (isImage) {
      result.add(SystemEntityType.image);
    }

    if (isAudio) {
      result.add(SystemEntityType.audio);
    }

    if (isVideo) {
      result.add(SystemEntityType.video);
    }

    if (!isMedia) {
      result.add(SystemEntityType.nonMediaFile);
    }

    if (isApk &&
        await FileManagerPlatform.instance.isApkInstalled(fileInfo.path)) {
      result.add(SystemEntityType.installedApk);
    }

    return result;
  }

  Future<List<FileInfo>> getAllImages() async {
    List result = await FileManagerPlatform.instance.getImages();

    return result
        .map((e) => FileInfo.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> runPhotoAnalysisProcess() async {
    FileManagerPlatform.instance.runPhotoAnalysisProcess();
  }

  Future<List<FileInfo>> getLowImages() async {
    List result = await FileManagerPlatform.instance.getLowImages();
    return result
        .map((e) => FileInfo.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<bool> isImageValid(String path) async {
    return await FileManagerPlatform.instance.isImageValid(path);
  }

  Future<bool> checkOptimizableImage(String path) async {
    return await FileManagerPlatform.instance.isOptimizableImage(path);
  }

  Future<PhotoOptimizationResult> optimizeImagePreview(String path,
      String fileNameToSave, int quality, double resolutionScale) async {
    Map result = await FileManagerPlatform.instance
        .optimizeImagePreview(path, quality, resolutionScale);
    return PhotoOptimizationResult(
        beforeSize: result["beforeSize"],
        afterSize: result["afterSize"],
        optimizedImage: result["optimizedImage"]);
  }

  Future<OptimizationResult> optimizeImage(String path, int quality,
      double resolutionScale, bool deleteOriginal) async {
    Map result = await FileManagerPlatform.instance
        .optimizeImage(path, quality, resolutionScale, deleteOriginal);

    return OptimizationResult(
        originalPhotoWithNewPath: result["originalPhotoWithNewPath"] != null
            ? FileInfo.fromJson(Map.from(result["originalPhotoWithNewPath"]))
            : null,
        optimizedPhoto: FileInfo.fromJson(Map.from(result["optimizedPhoto"])),
        savedSpaceInBytes: result["savedSpaceInBytes"]);
  }

  Stream<OptimizationResult> optimizeImages(List<String> listPaths, int quality,
      double resolutionScale, bool deleteOriginal) {
    List<Future<OptimizationResult>> futures = [];

    for (var i = 0; i < listPaths.length; i++) {
      final future =
          optimizeImage(listPaths[i], quality, resolutionScale, deleteOriginal);
      futures.add(future);
    }

    return Stream.fromFutures(futures);
  }

  Future<List<List<FileInfo>>> getSimilarImages() async {
    List<dynamic> similarGroups =
        await FileManagerPlatform.instance.getSimilarImages();
    return similarGroups
        .map((paths) => (paths as List)
            .map((e) => FileInfo.fromJson(Map<String, dynamic>.from(e)))
            .toList())
        .toList();
  }

  Stream<FileSystemEntity> deleteFiles(Iterable<String> filePaths) {
    final futures = <Future<FileSystemEntity>>[];

    for (var filePath in filePaths) {
      var deleteFileFuture = deleteFile(filePath);
      futures.add(deleteFileFuture);
    }

    return Stream.fromFutures(futures);
  }

  Future<FileSystemEntity> deleteFile(String filePath) async {
    final file = File(filePath);
    return await file.delete(recursive: true);
  }

  String? lookupMimeType(String path) {
    return mime.lookupMimeType(path);
  }

  Future<List<FileInfo>> getAllAudios() async {
    List result = await FileManagerPlatform.instance.getAllAudios();
    return result
        .map((e) => FileInfo.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<FileInfo>> getAllVideos() async {
    List result = await FileManagerPlatform.instance.getAllVideos();
    return result
        .map((e) => FileInfo.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<FileInfo>> getAllMediaFiles() async {
    List result = await FileManagerPlatform.instance.getAllMediaFiles();
    return result
        .map((e) => FileInfo.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Uint8List?> loadPhotoOrVideoThumbnail(
      int mediaId, int mediaType, int thumbnailSize) async {
    return await FileManagerPlatform.instance
        .loadPhotoOrVideoThumbnail(mediaId, mediaType, thumbnailSize);
  }

  Future<Uint8List?> loadAudioThumbnail(String path) async {
    return await FileManagerPlatform.instance.loadAudioThumbnail(path);
  }
}
