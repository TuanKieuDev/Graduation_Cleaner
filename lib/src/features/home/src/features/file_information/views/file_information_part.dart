import 'package:phone_cleaner/src/features/file/controllers/file_cache_controller.dart';
import 'package:phone_cleaner/src/features/file/features/photo_analysis/controllers/photo_analysis_controller.dart';
import 'package:phone_cleaner/src/features/file/features/photo_analysis/views/layout_photos/image_layout.dart';
import 'package:phone_cleaner/src/themes/cleaner_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../themes/fonts.dart';
import '../../../../../../commons/commons.dart';

class FileInformationPart extends ConsumerStatefulWidget {
  const FileInformationPart({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FileInformationPartState();
}

class _FileInformationPartState extends ConsumerState<FileInformationPart> {
  bool showInformation = false;

  @override
  Widget build(BuildContext context) {
    watchRouteChange() {
      if (!GoRouter.of(context).location.contains("/media")) {
        setState(() {
          showInformation = ref.exists(fileCacheControllerProvider);
        });
        GoRouter.of(context).removeListener(watchRouteChange);
      }
    }

    GoRouter.of(context).addListener(watchRouteChange);

    if (showInformation == false) {
      return const SizedBox.shrink();
    }
    final fileCacheData = ref.watch(fileCacheControllerProvider);
    final photoCacheData = ref.watch(imageAnalysisControllerProvider);
    final files = fileCacheData.value?.otherFiles;
    final badPhotos = photoCacheData.value?.badPhotos;

    if (files == null || badPhotos == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        _MediaFileCheckPart(
          firstPart: SizedBox(
            width: 100,
            height: 100,
            child: ImageLayout(
              length: badPhotos.length,
              data: badPhotos,
            ),
          ),
          label: "${badPhotos.length} bad photos",
          size: photoCacheData.value!.badPhotoSize,
        ),
        _MediaFileCheckPart(
          firstPart: SizedBox(
            width: 100,
            height: 100,
            child: CleanerIcons.file.toWidget(),
          ),
          label: "${files.length} files",
          size: 0.kb,
        ),
        const SizedBox(
          height: 30,
        ),
        // const _SeeMoreButton(),
      ],
    );
  }
}

class _MediaFileCheckPart extends StatelessWidget {
  final Widget firstPart;
  final String? label;
  final DigitalUnit? size;

  const _MediaFileCheckPart(
      {Key? key, required this.firstPart, this.label, this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;

    Color sizeColor(DigitalUnit size) {
      if (size > 1.gb) {
        return const Color.fromRGBO(244, 59, 46, 1);
      } else if (size > 100.mb) {
        return const Color.fromRGBO(255, 119, 40, 1);
      }
      return const Color.fromRGBO(51, 167, 82, 1);
    }

    return Container(
      decoration: BoxDecoration(
        color: cleanerColor.primary1,
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            firstPart,
            const SizedBox(
              width: 40,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (label != null)
                  Text(
                    label!,
                    style: semibold18.copyWith(color: cleanerColor.primary10),
                  ),
                if (size != null)
                  RichText(
                    text: TextSpan(
                      text: 'Can free ',
                      style: DefaultTextStyle.of(context).style,
                      children: <TextSpan>[
                        TextSpan(
                          text: '${size?.toStringOptimal()}',
                          style: semibold12.copyWith(
                            color: sizeColor(size!),
                          ),
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    Text(
                      "Check now",
                      style: semibold16.copyWith(
                        color: cleanerColor.primary7,
                      ),
                    ),
                    Icon(
                      Icons.navigate_next,
                      color: cleanerColor.primary7,
                    )
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
