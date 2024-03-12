import 'package:phone_cleaner/router/router.dart';
import 'package:phone_cleaner/src/commons/models/models.dart';
import 'package:phone_cleaner/src/features/file/features/filter/views/file_filter_page.dart';
import 'package:phone_cleaner/src/features/file/file.dart';
import 'package:phone_cleaner/src/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../commons/commons.dart';

class LargeVideoPart extends ConsumerWidget {
  const LargeVideoPart({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoProvider = ref.watch(fileCacheControllerProvider);

    if (videoProvider.hasError) {
      return const SizedBox.shrink();
    }

    final largeVideos =
        LargeVideos(videos: videoProvider.requireValue.largeVideos);

    if (largeVideos.videos.isEmpty) return const SizedBox.shrink();

    final cleanerColor = CleanerColor.of(context)!;

    var screenWidth = MediaQuery.of(context).size.width;

    Future<void> showInfoiDialog() async {
      return showDialog<void>(
          context: context,
          builder: (context) {
            return NoteDialog(
              title: 'About large videos',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "A catalogue of any videos over 20MB in size, located anywhere on your device.",
                    style: regular14.copyWith(color: cleanerColor.neutral5),
                  )
                ],
              ),
            );
          });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Large videos",
              style: bold20.copyWith(color: cleanerColor.primary10),
            ),
            TextButton(
              onPressed: () {
                showInfoiDialog();
              },
              child: const Icon(
                Icons.info_outline,
                size: 20,
                color: Color.fromRGBO(51, 167, 82, 1),
              ),
            ),
          ],
        ),
        Text(
          '${largeVideos.totalVideos} ${largeVideos.totalVideos > 1 ? 'videos' : 'video'} ${largeVideos.totalSize.toStringOptimal()}',
          style: regular14.copyWith(color: cleanerColor.neutral1),
        ),
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            if (largeVideos.videos.length > 1)
              _Thumbnail(
                videoInfo: largeVideos.videos[1],
                marginRight: screenWidth / 10,
                width: MediaQuery.of(context).size.width / 3.4,
                height: screenWidth / 4,
              ),
            if (largeVideos.videos.length > 2)
              _Thumbnail(
                videoInfo: largeVideos.videos[2],
                marginLeft: screenWidth / 10,
                width: screenWidth / 3.4,
                height: screenWidth / 4,
              ),
            _Thumbnail(
              videoInfo: largeVideos.videos[0],
              // iconSize: screenWidth / 10,
              width: screenWidth / 2.4,
              height: screenWidth / 3,
            ),
            TextButton(
              onPressed: () {
                GoRouter.of(context).pushNamed(
                  AppRouter.fileFilter,
                  extra: const FileFilterArguments(
                    fileFilterParameter: largeVideosFilterParam,
                  ),
                );
              },
              child: SizedBox(
                width: screenWidth,
                height: screenWidth / 2.5,
              ),
            )
          ],
        )
      ],
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    Key? key,
    required this.videoInfo,
    this.marginRight,
    this.marginLeft,
    required this.width,
    required this.height,
  }) : super(key: key);

  final FileCheckboxItemData videoInfo;
  final double? marginRight;
  final double? marginLeft;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    return Positioned(
      left: marginLeft,
      right: marginRight,
      width: width,
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: VideoPreview(
                mediaId: videoInfo.mediaId,
                mediaType: videoInfo.mediaType,
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  width: 3,
                  strokeAlign: BorderSide.strokeAlignCenter,
                  // color: Colors.blue,
                  color: cleanerColor.primary1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
