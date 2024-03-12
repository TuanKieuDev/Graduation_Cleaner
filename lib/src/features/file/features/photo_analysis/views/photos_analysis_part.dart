// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:phone_cleaner/src/features/file/filter_params.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:phone_cleaner/router/router.dart';
import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/features/file/features/features.dart';
import 'package:phone_cleaner/src/features/file/features/filter/views/file_filter_page.dart';
import 'package:phone_cleaner/src/themes/themes.dart';

import '../../../models/models.dart';
import '../../../views/message_label.dart';

class PhotoAnalysis extends ConsumerWidget {
  const PhotoAnalysis({
    super.key,
    required this.padding,
  });

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(imageAnalysisControllerProvider);
    if (data.hasError) {
      return const SizedBox.shrink();
    }
    final photosInfo = data.requireValue;
    final cleanerColor = CleanerColor.of(context)!;

    Future<void> showInfoiDialog() async {
      return showDialog<void>(
          context: context,
          builder: (context) {
            Widget contentSection({
              required String title,
              required String description,
            }) =>
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            semibold14.copyWith(color: cleanerColor.primary10),
                      ),
                      Text(
                        description,
                        style: regular14.copyWith(color: cleanerColor.neutral5),
                      ),
                    ],
                  ),
                );

            return NoteDialog(
              title: 'About photo analysis',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  contentSection(
                    title: "Similar",
                    description:
                        "Groups of photos that have a similar appearance and were taken closely in time are referred to as similar images.",
                  ),
                  contentSection(
                    title: "Bad quality",
                    description:
                        "Groups of photos that may be too dim, out of focus, or of inadequate quality.",
                  ),
                  contentSection(
                    title: "Sensitive",
                    description:
                        "Groups of photos that have been shared or received through social applications and may have a personal or private nature.",
                  ),
                  contentSection(
                    title: "Old",
                    description:
                        "Groups of photos that were either produced or last altered over a month ago.",
                  ),
                ],
              ),
            );
          });
    }

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Text(
                  "Photo analysis",
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
          ),
          GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(0),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              childAspectRatio: 0.7,
              shrinkWrap: true,
              children: [
                _PhotosCategory(
                  data: photosInfo.similarPhotos,
                  title: "Similar photos",
                  filterParams: similarPhotosFilterParam,
                  isSimilarPhoto: true,
                ),
                _PhotosCategory(
                  data: photosInfo.badPhotos,
                  title: "Low quality photos",
                  filterParams: badPhotosFilterParam,
                ),
                _PhotosCategory(
                  data: photosInfo.sensitivePhotos,
                  title: "Sensitive photos",
                  filterParams: sensitivePhotosFilterParam,
                ),
                _PhotosCategory(
                  data: photosInfo.oldPhotos,
                  title: "Old photos",
                  filterParams: oldPhotosFilterParam,
                ),
              ]),
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
        ? (data as List<FileCategory>)
            .fold(0.kb, (previous, element) => previous + element.totalSize)
        : (data as List<FileCheckboxItemData>)
            .fold(0.kb, (previous, element) => previous + element.size);
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
                          ? (data as List<FileCategory>)[0].checkboxItems
                          : []
                      : data as List<FileCheckboxItemData>,
                  length: isSimilarPhoto
                      ? data.isNotEmpty
                          ? (data as List<FileCategory>)[0].checkboxItems.length
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
