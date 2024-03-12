// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:phone_cleaner/router/router.dart';
import 'package:phone_cleaner/services/logger/logger.dart';
import 'package:phone_cleaner/src/features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:phone_cleaner/src/themes/themes.dart';
import 'package:go_router/go_router.dart';

import '../../../../../commons/commons.dart';

class FileFilterDrawer extends ConsumerWidget {
  const FileFilterDrawer({
    super.key,
  });
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
    final cleanerColor = CleanerColor.of(context)!;
    final router = GoRouter.of(context);

    ref.listen(fileFilterControllerProvider, logOnError(router));

    final params = ref.watch(fileFilterControllerProvider
        .select((value) => value.valueOrNull?.fileFilterParameter));

    void updateFilterParameters(FileFilterParameter params) {
      ref.read(fileFilterControllerProvider.notifier).setParameters(params);
    }

    return Drawer(
      backgroundColor: CleanerColor.of(context)!.neutral3,
      child: ListView(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).viewPadding.top, bottom: 32),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerRight,
                      icon: const Icon(
                        Icons.close,
                        color: Color.fromRGBO(66, 134, 244, 1),
                        size: 20,
                      ),
                      onPressed: () => Scaffold.of(context).closeEndDrawer(),
                    ),
                  ),
                  GradientText(
                    'Filters',
                    style: bold24,
                    gradient: cleanerColor.gradient1,
                  ),
                  FilterGroup<FileType>(
                    label: 'File type',
                    options: FileType.values,
                    selected: params?.fileType,
                    onOptionSeleted: (value) => updateFilterParameters(
                        params!.copyWith(fileType: value)),
                  ),
                  if (params?.fileType == FileType.photo)
                    FilterGroup<PhotoType>(
                      label: 'Filter by',
                      options: PhotoType.values,
                      selected: params?.photoType,
                      onOptionSeleted: (value) => updateFilterParameters(
                          params!.copyWith(photoType: value)),
                    ),
                  if (params != null &&
                      params.fileType != FileType.all &&
                      params.fileType != FileType.media &&
                      params.fileType != FileType.other)
                    FilterGroup<FolderType>(
                      label: 'Folders',
                      options: params.fileType == FileType.audio
                          ? [FolderType.all, FolderType.download]
                          : FolderType.values,
                      selected: params.folderType,
                      onOptionSeleted: (value) => updateFilterParameters(
                          params.copyWith(folderType: value)),
                    ),
                  FilterGroup<SortFileType>(
                    label: 'Sort by',
                    options: SortFileType.values,
                    selected: params?.sortFileType,
                    onOptionSeleted: (value) => updateFilterParameters(
                        params!.copyWith(sortFileType: value)),
                  ),
                  FilterGroup<ShowFileType>(
                    label: 'Show only',
                    options: ShowFileType.values,
                    selected: params?.showFileType,
                    onOptionSeleted: (value) => updateFilterParameters(
                        params!.copyWith(showFileType: value)),
                  ),
                  if (params != null && params.photoType != PhotoType.similar)
                    FilterGroup<GroupType>(
                      label: 'Group by',
                      options: GroupType.values,
                      selected: params.groupType,
                      onOptionSeleted: (value) => updateFilterParameters(
                          params.copyWith(groupType: value)),
                    ),
                ],
              ),
            ),
            const SizedBox(
              height: 7,
            ),
          ]),
    );
  }
}

class FilterGroup<T> extends StatelessWidget {
  const FilterGroup({
    Key? key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onOptionSeleted,
  }) : super(key: key);

  final String label;
  final List<T> options;
  final T? selected;
  final ValueSetter<T> onOptionSeleted;

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FilterLabel(label: label),
        Wrap(
          spacing: 8,
          children: [
            for (int i = 0; i < options.length; i++)
              ChoiceChip(
                backgroundColor: cleanerColor.neutral4,
                label: Text(options[i].toString()),
                labelStyle: regular14.copyWith(
                  color: selected == options[i]
                      ? cleanerColor.neutral3
                      : cleanerColor.neutral5,
                ),
                selected: selected == options[i],
                onSelected: (bool selected) {
                  onOptionSeleted(options[i]);
                },
                selectedColor: cleanerColor.primary6,
                disabledColor: cleanerColor.neutral4,
              ),
          ],
        )
      ],
    );
  }
}

class _FilterLabel extends StatelessWidget {
  const _FilterLabel({
    Key? key,
    required this.label,
  }) : super(key: key);

  final String label;

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        label,
        style: regular16.copyWith(
          color: cleanerColor.primary10,
        ),
      ),
    );
  }
}
