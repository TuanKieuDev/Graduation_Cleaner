import 'dart:io';

import 'package:phone_cleaner/router/router.dart';
import 'package:phone_cleaner/services/logger/logger.dart';
import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/photo_optimizer_controller.dart';
import '../controllers/photo_optimizer_preview_controller.dart';
import 'preview_photo.dart';

class OptimizerPreviewPhotoPage extends ConsumerWidget {
  const OptimizerPreviewPhotoPage({super.key});
  Function(AsyncValue? previous, AsyncValue next) logOnError(GoRouter router) =>
      (previous, next) {
        if (previous?.hasError == true) {
          return;
        }

        if (next.hasError) {
          appLogger.error(
              'Preview Photo Page Error', next.error, next.stackTrace);
          router.pushNamed(
            AppRouter.error,
            extra: CleanerException(message: next.error),
          );
        }
      };
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter.of(context);
    ref.listen(photoOptimizerControllerProvider, logOnError(router));

    final preview = ref.watch(
      photoOptimizerControllerProvider
          .selectAsync((value) => value.photos[value.previewPhotoIndex].path),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: DualPreviewPhoto(
          firstImageProvider: preview.then((value) => FileImage(File(value))),
          secondImageProvider: ref.watch(photoOptimizerPreviewControllerProvider
              .selectAsync((data) => MemoryImage(data.optimizedImage))),
          photoWidgetBuilder: (context, first, second) {
            return Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Center(
                        child: first,
                      ),
                    ),
                    Flexible(
                      child: second,
                    ),
                  ],
                ),
                const SecondaryAppBar(title: ""),
              ],
            );
          },
        ),
      ),
    );
  }
}
