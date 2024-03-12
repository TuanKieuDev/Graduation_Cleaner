import 'package:phone_cleaner/router/router.dart';
import 'package:phone_cleaner/services/logger/logger.dart';
import 'package:phone_cleaner/src/features/features.dart';
import 'package:phone_cleaner/src/features/quick_clean/src/views/quick_clean_category_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../commons/commons.dart';
import '../../../../commons/widgets/file_checkbox_item.dart';

final _quickCleanCategoryData =
    FutureProvider.autoDispose.family<QuickCleanCategory, int>((ref, index) {
  return ref.watch(quickCleanControllerProvider
      .selectAsync((data) => data.categories[index]));
});

class QuickCleanCategoryItem extends ConsumerWidget {
  const QuickCleanCategoryItem({required this.categoryIndex, super.key});

  Function(AsyncValue? previous, AsyncValue next) logOnError(GoRouter router) =>
      (previous, next) {
        if (previous?.hasError == true) {
          return;
        }

        if (next.hasError) {
          appLogger.error(
              'Quick Clean Category Error', next.error, next.stackTrace);
          router.pushNamed(
            AppRouter.error,
            extra: CleanerException(message: 'Some thing went wrong'),
          );
        }
      };
  final int categoryIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter.of(context);
    ref.listen(quickCleanControllerProvider, logOnError(router));
    // Assuming the data is always available as this widget can only be called once data is available
    final data = ref.watch(_quickCleanCategoryData(categoryIndex)).valueOrNull;

    final checkboxStatus = data?.isAllChecked ?? false
        ? CheckboxStatus.checked
        : data?.hasItemChecked ?? false
            ? CheckboxStatus.partiallyChecked
            : CheckboxStatus.unchecked;

    final itemText = data == null
        ? ''
        : '${data.selectedCount}/${data.checkboxItems.length} ${data.checkboxItems.length == 1 ? 'file' : 'files'}';
    final totalSizeText = data == null
        ? ''
        : "${data.selectedSize.toStringOptimal()}/${data.totalSize.toStringOptimal()}";

    return CleanerCategory(
      title: data?.categoryType.toName(context) ?? '',
      subtitle: "$itemText $dividerIcon $totalSizeText",
      icon: data?.categoryType.toIcon(),
      checkboxStatus: checkboxStatus,
      onSelect: (_) => ref
          .read(quickCleanControllerProvider.notifier)
          .toggleCategoryState(categoryIndex),
      childSliver: data == null
          ? null
          : SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, categoryItemIndex) => FileCheckboxItem(
                  padding: const EdgeInsets.fromLTRB(42, 4, 16, 4),
                  onTap: () => ref
                      .read(quickCleanControllerProvider.notifier)
                      .toggleCategoryItemState(
                          categoryIndex, categoryItemIndex),
                  data: data.checkboxItems[categoryItemIndex],
                ),
                childCount: data.checkboxItems.length,
              ),
            ),
    );
  }
}
