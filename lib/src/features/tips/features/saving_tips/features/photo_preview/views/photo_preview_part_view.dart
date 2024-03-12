import 'package:phone_cleaner/router/router.dart';
import 'package:phone_cleaner/services/logger/logger.dart';
import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/features/file/features/filter/views/file_filter_page.dart';
import 'package:phone_cleaner/src/features/file/file.dart';
import 'package:phone_cleaner/src/features/file/filter_params.dart';
import 'package:phone_cleaner/src/features/tips/tips.dart';
import 'package:phone_cleaner/src/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PhotoPreviewPartView extends ConsumerStatefulWidget {
  const PhotoPreviewPartView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PhotoPreviewViewState();
}

class _PhotoPreviewViewState extends ConsumerState<PhotoPreviewPartView> {
  void toggleAll() {
    GoRouter.of(context).pushNamed(
      AppRouter.fileFilter,
      extra: const FileFilterArguments(
        fileFilterParameter: FileFilterParameter(
          fileType: FileType.photo,
        ),
      ),
    );
  }

  Function(AsyncValue? previous, AsyncValue next) logOnError() =>
      (previous, next) {
        if (previous?.hasError == true) {
          return;
        }

        if (next.hasError) {
          appLogger.error(
              'Photo Preview Part Error', next.error, next.stackTrace);
          GoRouter.of(context).pushNamed(
            AppRouter.error,
            extra: CleanerException(message: 'Some thing went wrong'),
          );
        }
      };

  @override
  Widget build(BuildContext context) {
    ref.listen(photoPreviewControllerProvider, logOnError());

    final photosPreviewData = ref.watch(photoPreviewControllerProvider);
    if (photosPreviewData.isLoading) {
      return const SizedBox.shrink();
    }
    final photosPreviewInfo = photosPreviewData.requireValue;
    final photoCanOptimizeTotalSize =
        photosPreviewInfo.photoAnalysisData?.optimizeTotalSize;

    final cleanerColor = CleanerColor.of(context)!;
    final titleView = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // TODO: Get number of photos can optimize
        Text(
          'Photos to review',
          style: semibold18.copyWith(color: cleanerColor.primary10),
        ),
      ],
    );
    final subTitle = Text(
      'Can free ${photoCanOptimizeTotalSize!.toStringOptimal()}',
      style: regular14,
    );
    final gridView = GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(0),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      childAspectRatio: 0.7,
      shrinkWrap: true,
      children: [
        if (photosPreviewInfo.isShowSimilarPhotos)
          _PhotosCategory(
            data: photosPreviewInfo.photoAnalysisData!.similarPhotos,
            title: 'Similar photos',
            filterParams: similarPhotosFilterParam,
            isSimilarPhoto: true,
          ),
        if (photosPreviewInfo.isShowBadPhotos)
          _PhotosCategory(
            data: photosPreviewInfo.photoAnalysisData!.badPhotos,
            title: 'Low quality photos',
            filterParams: badPhotosFilterParam,
          ),
        if (photosPreviewInfo.isShowSensitivePhotos)
          _PhotosCategory(
            data: photosPreviewInfo.photoAnalysisData!.sensitivePhotos,
            title: 'Sensitive photos',
            filterParams: sensitivePhotosFilterParam,
          ),
        if (photosPreviewInfo.isShowOldPhotos)
          _PhotosCategory(
            data: photosPreviewInfo.photoAnalysisData!.oldPhotos,
            title: 'Old photos',
            filterParams: oldPhotosFilterParam,
          ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleView,
          subTitle,
          const SizedBox(height: 15),
          gridView,
        ],
      ),
    );
  }
}

class _PhotosCategory extends StatelessWidget {
  const _PhotosCategory({
    Key? key,
    this.isSimilarPhoto = false,
    required this.data,
    required this.filterParams,
    required this.title,
  }) : super(key: key);

  final bool isSimilarPhoto;
  final List data;
  final FileFilterParameter filterParams;
  final String title;

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    final totalSize = isSimilarPhoto
        ? (data).fold(0.kb, (previous, element) => previous + element.totalSize)
        : (data).fold(0.kb, (previous, element) => previous + element.size);
    return LayoutBuilder(
      builder: (context, constraints) {
        return TextButton(
          onPressed: () => GoRouter.of(context).pushNamed(
            AppRouter.fileFilter,
            extra: FileFilterArguments(
              fileFilterParameter: filterParams,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.all(5),
          ),
          child: Column(
            children: [
              MessageLabel(size: totalSize),
              SizedBox(
                width: constraints.maxWidth - 10,
                height: constraints.maxWidth - 10,
                child: ImageLayout(
                  data: isSimilarPhoto
                      ? data.isNotEmpty
                          ? (data)[0].checkboxItems
                          : []
                      : data,
                  length: isSimilarPhoto
                      ? data.isNotEmpty
                          ? (data)[0].checkboxItems.length
                          : 0
                      : data.length,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                title,
                style: regular14.copyWith(color: cleanerColor.primary10),
              )
            ],
          ),
        );
      },
    );
  }
}
