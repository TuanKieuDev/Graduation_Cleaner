// ignore_for_file: public_member_api_docs, sort_constructors_first, unnecessary_null_comparison
import 'package:phone_cleaner/router/router.dart';
import 'package:phone_cleaner/services/logger/logger.dart';
import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/features/features.dart';
import 'package:phone_cleaner/src/features/file/features/filter/views/layout/file_item.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FileCategoryItem extends ConsumerWidget {
  const FileCategoryItem({
    Key? key,
    required this.categoryIndex,
    required this.displayGrid,
  }) : super(key: key);

  final int categoryIndex;
  final bool displayGrid;

  Function(AsyncValue? previous, AsyncValue next) logOnError(GoRouter router) =>
      (previous, next) {
        if (previous?.hasError == true) {
          return;
        }

        if (next.hasError) {
          appLogger.error(
              'File Filter Drawer Error', next.error, next.stackTrace);
          router.pushNamed(
            AppRouter.error,
            extra: CleanerException(message: 'Some thing went wrong'),
          );
        }
      };
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter.of(context);
    ref.listen(fileFilterControllerProvider, logOnError(router));

    final groupType = ref.watch(fileFilterControllerProvider
        .select((value) => value.valueOrNull?.fileFilterParameter?.groupType));

    final dataLength = ref.watch(fileFilterControllerProvider.select((value) =>
        value.valueOrNull?.fileDataList
            .elementAtOrNull(categoryIndex)
            ?.checkboxItems
            .length));

    if (groupType == null || dataLength == null) {
      return const SizedBox.shrink();
    }

    debugPrint('rebuild: FileCategoryItem  $categoryIndex');
    final sliverChildBuilderDelegate = SliverChildBuilderDelegate(
      (context, index) {
        debugPrint('rebuild: FileItem $categoryIndex $index');

        return FileItem(
          itemIndex: index,
          categoryIndex: categoryIndex,
          displayGrid: displayGrid,
        );
      },
      childCount: dataLength,
    );

    if (groupType == GroupType.none) {
      return displayGrid
          ? SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.75,
                ),
                delegate: sliverChildBuilderDelegate,
              ),
            )
          : SliverList(
              delegate: sliverChildBuilderDelegate,
            );
    }

    void toggleCategory() {
      ref
          .read(fileFilterControllerProvider.notifier)
          .toggleCategoryAtIndex(categoryIndex);
    }

    final dataName = ref.watch(fileFilterControllerProvider.select((value) =>
        value.valueOrNull?.fileDataList.elementAtOrNull(categoryIndex)?.name));

    final checkboxStatus = ref.watch(fileFilterControllerProvider.select(
        (value) => value.valueOrNull?.fileDataList
            .elementAtOrNull(categoryIndex)
            ?.checkboxStatus));

    // TODO the cause of rebulding the whole category when selecting an item, extract this
    final selectedCount = ref.watch(fileFilterControllerProvider.select(
        (value) => value.valueOrNull?.fileDataList
            .elementAtOrNull(categoryIndex)
            ?.selectedCount));

    // TODO the cause of rebulding the whole category when selecting an item, extract this
    final selectedSize = ref.watch(fileFilterControllerProvider.select(
        (value) => value.valueOrNull?.fileDataList
            .elementAtOrNull(categoryIndex)
            ?.selectedSize));

    final totalSize = ref.watch(fileFilterControllerProvider.select((value) =>
        value.valueOrNull?.fileDataList
            .elementAtOrNull(categoryIndex)
            ?.totalSize));

    final name = ref.watch(fileFilterControllerProvider.select((value) =>
        value.valueOrNull?.fileDataList.elementAtOrNull(categoryIndex)?.name));

    if (dataName == null ||
        name == null ||
        checkboxStatus == null ||
        selectedCount == null ||
        selectedSize == null ||
        totalSize == null ||
        totalSize == null) {
      return const SizedBox.shrink();
    }

    final nameOptimal =
        (dataName.length > 20) ? '${dataName.substring(0, 20)}...' : dataName;

    final itemText =
        '$selectedCount/$dataLength ${dataLength > 1 ? 'Items' : 'Item'}';
    final totalSizeText =
        '${selectedSize.toStringOptimal()} /${totalSize.toStringOptimal()}';

    return CleanerCategory(
      title: nameOptimal,
      subtitle: '$itemText  $totalSizeText',
      checkboxStatus: checkboxStatus,
      icon: name.iconWidget,
      onSelect: (_) => toggleCategory(),
      childSliver: displayGrid
          ? SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.75,
                ),
                delegate: sliverChildBuilderDelegate,
              ),
            )
          : SliverList(
              delegate: sliverChildBuilderDelegate,
            ),
    );
  }
}

extension on String {
  Widget get iconWidget {
    if (this == FileType.audio.description) {
      return CleanerIcons.fileSound.toWidget();
    } else if (this == FileType.photo.description) {
      return CleanerIcons.fileImage.toWidget();
    } else if (this == FileType.video.description) {
      return CleanerIcons.fileVideo.toWidget();
    } else {
      return CleanerIcons.otherFile.toWidget();
    }
  }
}
