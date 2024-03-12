import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/features/features.dart';
import 'package:device_info/device_info.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../../main.dart';

part 'media_folder_controller.g.dart';

@riverpod
class MediaFolderController extends _$MediaFolderController {
  @override
  FutureOr<List<FileCategory>> build() async {
    final folderData = _getMediaFolder();
    final appListFuture = _getApps();

    final results = await Future.wait([folderData, appListFuture]);
    final apps = results[1] as Map<String, String>;
    final data = (results[0] as List<FolderOrFileInfo>)
        .cast<FolderWithChildren>()
        .map((folder) {
          return FileCategory(
            name: folder.folderInfo.name,
            iconPath: apps[folder.name],
            checkboxItems: folder.children.map((e) {
              return FileCheckboxItemData(
                mediaId: e.mediaId,
                mediaType: e.mediaType,
                name: e.name,
                size: e.size.bytes,
                extensionFile: e.extension,
                path: e.path,
                timeModified: e.lastModified,
                fileType: e.toFileType(),
              );
            }).toList(),
          );
        })
        .toList()
        .filterWithParams(mediaFolderFilterParam);

    ref.keepAlive();
    return data;
  }

  Future<List<FolderOrFileInfo>> _getMediaFolder() async {
    return ref
        .watch(fileControllerProvider.notifier)
        .future
        .then((value) => value[SystemEntityType.mediaFolder]!);
  }

  void deletePathsInState(Set<String> paths) {
    ref.read(fileControllerProvider.notifier).deletePathsInState(paths);
  }

  Future<Map<String, String>> _getApps() async {
    final appManager = ref.watch(appRepository);
    final apps = await appManager.getAllApplications();
    final results = <String, String>{};
    final futures = <Future>[];
    for (var i = 0; i < apps.length; i++) {
      final future = appManager
          .getLabel(apps[i].packageName)
          .then((value) => results[value] = apps[i].packageName);
      futures.add(future);
    }
    await Future.wait(futures);
    return results;
  }
}
