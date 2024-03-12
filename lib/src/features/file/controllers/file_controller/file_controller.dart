import 'dart:async';
import 'dart:io';

import 'package:phone_cleaner/main.dart';
import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:device_info/device_info.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'file_controller.g.dart';

@riverpod
class FileController extends _$FileController {
  late FileManager fileManager;

  @override
  FutureOr<Map<SystemEntityType, List<FolderOrFileInfo>>> build() {
    fileManager = ref.read(fileManagerRepository);
    final queryResult = fileManager.isolateQuery({
      SystemEntityType.emptyFolder: null,
      SystemEntityType.screenshot: null,
      SystemEntityType.thumbnail: null,
      SystemEntityType.visibleCache: null,
      SystemEntityType.appData: null,
      SystemEntityType.downloaded: null,
      SystemEntityType.installedApk: null,
      SystemEntityType.mediaFile: null,
      SystemEntityType.image: null,
      SystemEntityType.audio: null,
      SystemEntityType.video: null,
      SystemEntityType.mediaFolder: null,
      SystemEntityType.nonMediaFile: null,
      SystemEntityType.sensitiveImage: null,
      SystemEntityType.largeOldVideo: LargeOldFileParameter(
          DateTime.now().difference(DateTime.fromMicrosecondsSinceEpoch(0)),
          100000000),
      SystemEntityType.largeOldFile:
          const LargeOldFileParameter(Duration(days: 30), 104857600),
      SystemEntityType.largeOldPhoto:
          const LargeOldFileParameter(Duration(days: 30), 0),
      SystemEntityType.optimizablePhoto: null,
    });
    return queryResult;
  }

  void deleteFiles(List<FolderOrFileInfo> folderOrFileInfo) {
    deleteAtPaths(folderOrFileInfo.map((e) => e.path).toList());
  }

  void deleteFile(FolderOrFileInfo folderOrFileInfo) {
    deleteAtPath(folderOrFileInfo.path);
  }

  Stream<FileSystemEntity> deleteAtPaths(Iterable<String> paths) {
    if (!state.hasValue) {
      throw InvalidStateException("File Controller data is not available!");
    }
    deletePathsInState(paths.toSet());
    return fileManager.deleteFiles(paths);
  }

  void deleteAtPath(String path) {
    if (!state.hasValue) {
      throw InvalidStateException("File Controller data is not available!");
    }
    fileManager.deleteFile(path);
    deletePathsInState({path});
  }

  void deleteAndAddPaths(
      Set<String> deletedPaths, List<FolderOrFileInfo> addedPaths) {
    update((state) async {
      final newState = {...state};
      // _deletePathsShouldNotNotify(newState, deletedPaths);

      //TODO: need to improve
      _deleteImage(newState, deletedPaths);
      _addImage(newState, addedPaths);
      return newState;
    });
  }

  void deletePathsInState(Set<String> paths) {
    update((state) {
      final newState = {...state};

      _deletePathsShouldNotNotify(newState, paths);
      return newState;
    });
  }

  void _deletePathsShouldNotNotify(
      Map<SystemEntityType, List<FolderOrFileInfo>> map, Set<String> paths) {
    map.forEach((key, value) {
      value.removeWhere((element) {
        try {
          return paths.contains(element.path);
        } catch (e) {
          return false;
        }
      });
    });
  }

  void _addImage(Map<SystemEntityType, List<FolderOrFileInfo>> map,
      List<FolderOrFileInfo> newFolderOrFiles) {
    map[SystemEntityType.image]?.addAll(newFolderOrFiles);
  }

  void _deleteImage(
      Map<SystemEntityType, List<FolderOrFileInfo>> map, Set<String> paths) {
    map[SystemEntityType.image]
        ?.removeWhere((element) => paths.contains(element.path));
    map[SystemEntityType.oldPhotos]
        ?.removeWhere((element) => paths.contains(element.path));
    map[SystemEntityType.optimizablePhoto]
        ?.removeWhere((element) => paths.contains(element.path));
    map[SystemEntityType.sensitiveImage]
        ?.removeWhere((element) => paths.contains(element.path));
  }

  void addToState(List<FolderOrFileInfo> newFolderOrFiles) {
    update((state) async {
      final newState = {...state};

      _addToStateShouldNotNotify(newState, newFolderOrFiles);
      return newState;
    });
  }

  Future _addToStateShouldNotNotify(
      Map<SystemEntityType, List<FolderOrFileInfo>> map,
      List<FolderOrFileInfo> newFolderOrFiles) {
    final futures = <Future>[];

    final fileManager = ref.read(fileManagerRepository);

    for (var folderOrFile in newFolderOrFiles) {
      final future =
          fileManager.convertToSystemEntityType(folderOrFile).then((value) {
        for (var element in value) {
          map[element]?.add(folderOrFile);
        }
      });
      futures.add(future);
    }
    return Future.wait(futures);
  }

  Future<Stream<OptimizationResult>> optimize(
    List<String> pathImages,
    int quality,
    double scaleValue,
    bool isSaved,
  ) async {
    var androidInfo = await DeviceInfoPlugin().androidInfo;
    var sdkInt = androidInfo.version.sdkInt;

    // TODO Check từ trước khi gọi hàm
    Permission permission;
    if (sdkInt < 33) {
      permission = Permission.storage;
    } else {
      permission = Permission.photos;
    }
    if (await permission.status.isDenied) {
      await permission.request();
    }

    final resultStream = fileManager
        .optimizeImages(
          pathImages,
          quality,
          scaleValue,
          isSaved,
        )
        .asBroadcastStream();

    resultStream.toList().then((optimizationResults) {
      update((state) {
        final newState = {...state};

        _deletePathsShouldNotNotify(
          newState,
          optimizationResults.map((e) => e.optimizedPhoto.path).toSet(),
        );
        _addToStateShouldNotNotify(
          newState,
          optimizationResults
              .map((e) => e.optimizedPhoto.copyWith(
                  mimeType: fileManager.lookupMimeType(e.optimizedPhoto.path)))
              .toList(),
        );

        _addToStateShouldNotNotify(
          newState,
          optimizationResults
              .where((element) => element.originalPhotoWithNewPath != null)
              .map((e) => e.originalPhotoWithNewPath!.copyWith(
                  mimeType: fileManager.lookupMimeType(e.optimizedPhoto.path)))
              .toList(),
        );

        return newState;
      });
    });

    return resultStream;
  }
}
