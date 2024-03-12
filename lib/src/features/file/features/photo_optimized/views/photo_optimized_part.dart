import 'package:phone_cleaner/router/router.dart';
import 'package:phone_cleaner/src/features/file/features/filter/views/file_filter_page.dart';
import 'package:phone_cleaner/src/features/file/file.dart';
import 'package:phone_cleaner/src/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../commons/commons.dart';

class PhotoOptimizedPart extends ConsumerWidget {
  const PhotoOptimizedPart({
    super.key,
    required this.padding,
  });

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosOptimizable = ref.watch(photoOptimizedControllerProvider);

    if (photosOptimizable.hasError) {
      return const SizedBox.shrink();
    }
    final photosOptimized = photosOptimizable.requireValue;
    if (photosOptimized.photos.isEmpty) return const SizedBox.shrink();

    final totalPhotos = photosOptimized.photos.length;

    final totalPhotosSize = photosOptimized.totalSize;

    final cleanerColor = CleanerColor.of(context)!;

    Future<void> showInfoiDialog() async {
      return showDialog<void>(
          context: context,
          builder: (context) {
            return NoteDialog(
              title: 'About can be optimized',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "A collection of images that can be resized and compressed to reduce their storage space without significantly affecting their quality. This process frees up a significant amount of storage. Additionally, there is an option to save the original files as a backup.",
                    style: regular14.copyWith(color: cleanerColor.neutral5),
                  )
                ],
              ),
            );
          });
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Can be optimized",
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
                '$totalPhotos ${totalPhotos > 1 ? 'photos' : 'photo'} ${totalPhotosSize.toStringOptimal()}',
                style: regular14.copyWith(color: cleanerColor.neutral1),
              ),
              TextButton(
                onPressed: () => GoRouter.of(context).pushNamed(
                  AppRouter.fileFilter,
                  extra: const FileFilterArguments(
                    fileFilterParameter: FileFilterParameter(
                      fileType: FileType.photo,
                      photoType: PhotoType.optimize,
                      showFileType: ShowFileType.all,
                    ),
                  ),
                ),
                style: TextButton.styleFrom(
                  textStyle: regular14,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  minimumSize: Size(constraints.maxWidth, 180),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                            child: MessageLabel(
                                size: photosOptimized.photos[0].size)),
                        ImageCard(
                          width: constraints.maxWidth / 3,
                          height: constraints.maxWidth / 3,
                          source: photosOptimized.photos[0].path,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Text(
                            "Before",
                            style: TextStyle(color: cleanerColor.primary10),
                          ),
                        ),
                      ],
                    ),
                    CustomPaint(
                      painter: TrapeziumPainter(),
                      child: SizedBox(
                        width: constraints.maxWidth / 5,
                        height: constraints.maxWidth / 4,
                      ),
                    ),
                    Column(
                      children: [
                        MessageLabel(
                            size: (photosOptimized.photos[0].size * 0.3)),
                        ImageCard(
                          width: constraints.maxWidth / 4,
                          height: constraints.maxWidth / 4,
                          source: photosOptimized.photos[0].path,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Text(
                            "After",
                            style: TextStyle(color: cleanerColor.primary10),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Hình thang painter
class TrapeziumPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color.fromRGBO(150, 202, 255, 0.15),
          Color.fromRGBO(150, 202, 255, 1),
        ],
      ).createShader(Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..strokeWidth = 15;

    var path = Path();

    path.moveTo(0, 10);

    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height * 7 / 8);
    path.lineTo(size.width, size.height * 1 / 8 + 11);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
