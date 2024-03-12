import 'package:phone_cleaner/main.dart';
import 'package:phone_cleaner/services/logger/logger.dart';
import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/features/file/controllers/file_controller/file_controller.dart';
import 'package:phone_cleaner/src/features/file/filter_params.dart';
import 'package:device_info/device_info.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/models.dart';

part 'file_cache_controller.g.dart';

@riverpod
class FileCacheController extends _$FileCacheController {
  late GeneralInfoManager infoManager;
  late FileController fileController;

  @override
  FutureOr<FileCacheInfo> build() {
    ref.watch(fileControllerProvider);

    // TODO: General Info và File Info là 2 nguồn dữ liệu khác nhau, cập nhật khác nhau, cân nhắc tách controller
    infoManager = ref.read(generalInfoRepository);
    fileController = ref.read(fileControllerProvider.notifier);
    final generalInfoFuture = infoManager.getGeneralInfo();

    return Future.wait([generalInfoFuture, fileController.future]).then(
      (value) async {
        final generalInfo = value[0] as GeneralInfo;
        final fileMap =
            value[1] as Map<SystemEntityType, List<FolderOrFileInfo>>;

        appLogger.debug(fileMap.keys.join(', '));

        final images =
            fileMap[SystemEntityType.image]!.toListOfFileCheckBoxItemData();

        final sounds =
            fileMap[SystemEntityType.audio]!.toListOfFileCheckBoxItemData();
        final videos =
            fileMap[SystemEntityType.video]!.toListOfFileCheckBoxItemData();
        final largeVideos = videos.filterWithParams(largeVideosFilterParam);
        final otherFiles = fileMap[SystemEntityType.nonMediaFile]!
            .toListOfFileCheckBoxItemData();

        final files = (images + sounds + videos + otherFiles).sortBySize();
        final usedSpace = files.fold(
            0.bytes, (previousValue, element) => previousValue + element.size);

        return FileCacheInfo(
          usedSpace: usedSpace,
          totalSpace: generalInfo.totalSpace.bytes,
          images: images,
          videos: videos,
          largeVideos: largeVideos,
          sounds: sounds,
          otherFiles: otherFiles,
          files: files,
        );
      },
    );
  }

  void deletePathsInState(Set<String> paths) {
    ref.read(fileControllerProvider.notifier).deletePathsInState(paths);
  }
}
