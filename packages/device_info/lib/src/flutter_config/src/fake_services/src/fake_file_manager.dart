import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:device_info/device_info.dart';

enum FakeFileType { asset, internet, file }

class FakeFileManager extends FileManager {
  FakeFileManager();

  String _generateRandomString(int length) {
    final random = Random();
    const availableChars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    final randomString = List.generate(length,
            (index) => availableChars[random.nextInt(availableChars.length)])
        .join();

    return randomString;
  }

  String _generateRandomPath([int? depth, int? length]) {
    final random = Random();
    final randomString = List.generate(depth ?? random.nextInt(3) + 1,
            (index) => _generateRandomString(length ?? random.nextInt(5) + 1))
        .join('/');

    return randomString;
  }

  FileInfo _randomFileInfo(
      {String? name,
      String? path,
      String? extension,
      int? size,
      String? mimetype,
      DateTime? lastModified}) {
    return FileInfo(
      mediaId: 0,
      mediaType: 0,
      name: name ?? 'fake_file',
      path: path ??
          '${_generateRandomPath()}/${_generateRandomString(Random().nextInt(10) + 5)}${extension ?? 'exe'}',
      size: size ?? Random().nextInt(200000),
      mimeType: mimetype,
      extension: extension ?? '.exe',
      lastModified: lastModified ??
          DateTime.now().subtract(
            Duration(seconds: Random().nextInt(3000)),
          ),
    );
  }

  FolderInfo _randomFolderInfo(
      {String? name,
      String? path,
      int? itemCount,
      int? size,
      DateTime? lastModified}) {
    return FolderInfo(
      name: name ?? 'fake_folder',
      path: path ?? _generateRandomPath(),
      size: size ?? Random().nextInt(200000),
      itemCount: itemCount ?? Random().nextInt(3),
      lastModified: lastModified ??
          DateTime.now().subtract(Duration(seconds: Random().nextInt(3000))),
    );
  }

  FolderWithChildren _randomFolderWithChildrenInfo(
      {String? name,
      String? path,
      int? itemCount,
      int? size,
      DateTime? lastModified}) {
    final path0 = path ?? _generateRandomPath();
    var randomFolderInfo = _randomFolderInfo(
        name: name,
        path: path0,
        itemCount: itemCount,
        size: size,
        lastModified: lastModified);
    return FolderWithChildren(
      name: name ?? 'fake_folder',
      path: path0,
      size: randomFolderInfo.size,
      children:
          List.generate(Random().nextInt(10) + 1, (index) => _randomFileInfo()),
      folderInfo: randomFolderInfo,
    );
  }

  @override
  Future<Map<SystemEntityType, List<FolderOrFileInfo>>> isolateQuery(
      Map<SystemEntityType, FileQueryParameter?> parameters) async {
    await Future.delayed(const Duration(seconds: 2));

    var result = <SystemEntityType, List<FolderOrFileInfo>>{};

    for (var type in parameters.keys) {
      switch (type) {
        case SystemEntityType.visibleCache:
          result[type] = [
            ErrorFolderInfo(
                "Due to Android restrictions, visible cache can only be shown on a computer.")
          ];
          break;
        case SystemEntityType.thumbnail:
        case SystemEntityType.appData:
        case SystemEntityType.emptyFolder:
          result[type] = List.generate(
            Random().nextInt(30),
            (index) => _randomFolderInfo(),
          );
          break;
        case SystemEntityType.mediaFolder:
          result[type] = List.generate(Random().nextInt(30) + 1,
              (index) => _randomFolderWithChildrenInfo());
          break;
        case SystemEntityType.nonMediaFile:
        case SystemEntityType.downloaded:
          result[type] = List.generate(
            Random().nextInt(30),
            (index) => _randomFileInfo(),
          );
          break;
        case SystemEntityType.optimizablePhoto:
        case SystemEntityType.sensitiveImage:
        case SystemEntityType.screenshot:
        case SystemEntityType.image:
          result[type] = List.generate(
            Random().nextInt(1000) + 30,
            (index) =>
                _randomFileInfo(extension: ".png", mimetype: "image/png"),
          );
          break;
        case SystemEntityType.largeOldPhoto:
          final largeOldPhotoParameter =
              parameters[SystemEntityType.largeOldPhoto]
                  as LargeOldFileParameter;
          result[type] = List.generate(
            Random().nextInt(30),
            (index) => _randomFileInfo(
                extension: ".png",
                lastModified:
                    DateTime.now().subtract(largeOldPhotoParameter.oldDuration),
                size: Random().nextInt(200000) +
                    largeOldPhotoParameter.minimumBytes),
          );
          break;
        case SystemEntityType.installedApk:
          result[type] = List.generate(
            Random().nextInt(30),
            (index) => _randomFileInfo(extension: ".apk"),
          );
          break;

        case SystemEntityType.audio:
          result[type] = List.generate(
            Random().nextInt(1000) + 30,
            (index) =>
                _randomFileInfo(extension: ".mp3", mimetype: "audio/mp3"),
          );
          break;
        case SystemEntityType.video:
          result[type] = List.generate(
            Random().nextInt(1000) + 30,
            (index) => _randomFileInfo(
              extension: ".mp4",
              mimetype: "video/mp4",
            ),
          );
          break;
        case SystemEntityType.largeOldVideo:
          final largeOldPhotoParameter =
              parameters[SystemEntityType.largeOldVideo]
                  as LargeOldFileParameter;
          result[type] = List.generate(
            Random().nextInt(30),
            (index) => _randomFileInfo(
                extension: ".mp4",
                mimetype: "video/mp4",
                size: Random().nextInt(200000) +
                    largeOldPhotoParameter.minimumBytes),
          );
          break;
        case SystemEntityType.largeOldFile:
          final largeOldPhotoParameter =
              parameters[SystemEntityType.largeOldFile]
                  as LargeOldFileParameter;
          result[type] = List.generate(
            Random().nextInt(30),
            (index) => _randomFileInfo(
                size: Random().nextInt(200000) +
                    largeOldPhotoParameter.minimumBytes),
          );
          break;
        case SystemEntityType.mediaFile:
          break;
        case SystemEntityType.downloadedDocument:
          result[type] = List.generate(
            Random().nextInt(1000) + 30,
            (index) => _randomFileInfo(
              extension: ".docx",
              mimetype: "document/docx",
            ),
          );
          break;
        case SystemEntityType.newScreenshot:
          // final largeOldPhotoParameter =
          //     parameters[SystemEntityType.oldPhotos] as NewFileParameter;
          result[type] = List.generate(
            Random().nextInt(30),
            (index) =>
                _randomFileInfo(extension: ".png", mimetype: "image/png"),
          );
          break;
        case SystemEntityType.oldPhotos:
          final largeOldPhotoParameter =
              parameters[SystemEntityType.oldPhotos] as LargeOldFileParameter;
          result[type] = List.generate(
            Random().nextInt(30),
            (index) => _randomFileInfo(
                extension: ".png",
                mimetype: "image/png",
                size: Random().nextInt(200000) +
                    largeOldPhotoParameter.minimumBytes),
          );
          break;
        case SystemEntityType.largeNewVideo:
          final largeOldPhotoParameter =
              parameters[SystemEntityType.largeNewFile]
                  as LargeNewFileParameter;
          result[type] = List.generate(
            Random().nextInt(30),
            (index) => _randomFileInfo(
                extension: ".png",
                mimetype: "image/png",
                size: Random().nextInt(200000) +
                    largeOldPhotoParameter.minimumBytes),
          );
          break;
        case SystemEntityType.largeNewFile:
          final largeOldPhotoParameter =
              parameters[SystemEntityType.largeNewFile]
                  as LargeNewFileParameter;
          result[type] = List.generate(
            Random().nextInt(30),
            (index) => _randomFileInfo(
                extension: ".png",
                mimetype: "image/png",
                size: Random().nextInt(200000) +
                    largeOldPhotoParameter.minimumBytes),
          );
          break;
        case SystemEntityType.apkFile:
          // TODO: Handle this case.
          break;
      }
    }

    if (parameters.containsKey(SystemEntityType.mediaFile)) {
      result[SystemEntityType.mediaFile] = [];
      if (parameters.containsKey(SystemEntityType.audio)) {
        result[SystemEntityType.mediaFile]!
            .addAll(result[SystemEntityType.audio]!);
      } else {
        result[SystemEntityType.mediaFile]!.addAll(List.generate(
          Random().nextInt(30),
          (index) => _randomFileInfo(extension: ".mp3"),
        ));
      }
      if (parameters.containsKey(SystemEntityType.video)) {
        result[SystemEntityType.mediaFile]!
            .addAll(result[SystemEntityType.video]!);
      } else {
        result[SystemEntityType.mediaFile]!.addAll(List.generate(
          Random().nextInt(30),
          (index) => _randomFileInfo(extension: ".mp4"),
        ));
      }
      if (parameters.containsKey(SystemEntityType.image)) {
        result[SystemEntityType.mediaFile]!
            .addAll(result[SystemEntityType.image]!);
      } else {
        result[SystemEntityType.mediaFile]!.addAll(List.generate(
          Random().nextInt(30),
          (index) => _randomFileInfo(extension: ".png"),
        ));
      }
    }

    if (result.containsKey(SystemEntityType.video)) {
      result[SystemEntityType.video] = [
        ...result[SystemEntityType.video]!,
        ...(result[SystemEntityType.largeOldVideo] ?? <FolderOrFileInfo>[])
      ];
    }

    if (result.containsKey(SystemEntityType.largeOldPhoto)) {
      result[SystemEntityType.image] = [
        ...result[SystemEntityType.image]!,
        ...(result[SystemEntityType.largeOldPhoto] ?? <FolderOrFileInfo>[])
      ];
    }

    return result;
  }

  @override
  Stream<FileSystemEntity> deleteFiles(Iterable<String> filePaths) {
    final futures = <Future<FileSystemEntity>>[];
    for (var filePath in filePaths) {
      var deleteFileFuture = deleteFile(filePath);
      futures.add(deleteFileFuture);
    }

    return Stream.fromFutures(futures);
  }

  @override
  Future<FileSystemEntity> deleteFile(String filePath) async {
    var failed = Random().nextBool();
    if (failed) {
      throw Exception();
    }
    await Future.delayed(const Duration(seconds: 2));

    return File(filePath);
  }

  @override
  Future<List<FileInfo>> getLowImages() async {
    return List.generate(
      Random().nextInt(30),
      (index) => _randomFileInfo(extension: '.png', mimetype: 'image/png'),
    );
  }

  @override
  Future<bool> checkSensitiveImage(String path) async {
    return Random().nextBool();
  }

  @override
  Future<List<List<FileInfo>>> getSimilarImages() async {
    return [];
  }

  @override
  Future<OptimizationResult> optimizeImage(String path, int quality,
      double resolutionScale, bool deleteOriginal) async {
    await Future.delayed(const Duration(seconds: 3));
    return OptimizationResult(
      originalPhotoWithNewPath: deleteOriginal ? null : _randomFileInfo(),
      optimizedPhoto: _randomFileInfo(),
      savedSpaceInBytes: Random().nextInt(1000000),
    );
  }

  @override
  Future<PhotoOptimizationResult> optimizeImagePreview(String path,
      String fileNameToSave, int quality, double resolutionScale) async {
    await Future.delayed(const Duration(seconds: 3));
    return PhotoOptimizationResult(
        beforeSize: 3, afterSize: 300000, optimizedImage: Uint8List(0));
  }

  // @override
  // Future<OptimizationResult> optimizeImage(String path, int quality,
  //     double resolutionScale, bool deleteOriginal, String packageName) async {
  //   await Future.delayed(const Duration(seconds: 3));

  //   return OptimizationResult(
  //     originalPhotoWithNewPath: _randomFileInfo(),
  //     optimizedPhoto: _randomFileInfo(path: path),
  //     savedSpaceInBytes: 12000,
  //   );
  // }

  @override
  Future<void> runPhotoAnalysisProcess() async {
    // return super.runPhotoAnalysisProcess();
  }
}
