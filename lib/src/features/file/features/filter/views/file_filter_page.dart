// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:developer';

import 'package:phone_cleaner/router/router.dart';
import 'package:phone_cleaner/src/commons/widgets/loading.dart';
import 'package:phone_cleaner/src/commons/widgets/lottie_looper.dart';
import 'package:phone_cleaner/src/commons/widgets/unavailable_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:phone_cleaner/src/themes/themes.dart';
import 'package:go_router/go_router.dart';

import '../../../../../commons/commons.dart';
import '../../../../../commons/widgets/items_and_select_action.dart';
import '../../../../features.dart';
import 'file_filter_drawer.dart';

class FileFilterArguments {
  final FileFilterParameter fileFilterParameter;

  const FileFilterArguments({
    required this.fileFilterParameter,
  });
}

class FileFilterPage extends ConsumerStatefulWidget {
  const FileFilterPage({
    super.key,
    required this.arguments,
  });

  final FileFilterArguments arguments;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ListFilePageState();
}

class _ListFilePageState extends ConsumerState<FileFilterPage> {
  bool animationLoadingRunning = false;
  bool animationCleaningRunning = false;
  @override
  void initState() {
    super.initState();
    ref
        .read(fileFilterControllerProvider.notifier)
        .setParameters(widget.arguments.fileFilterParameter);
  }

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    final cleaning = ref.watch(fileFilterControllerProvider
            .select((value) => value.valueOrNull?.cleaning)) ??
        false;

    log('$cleaning');

    final hasData = ref.watch(fileFilterControllerProvider
        .select((value) => value.valueOrNull != null));

    if (!hasData || animationLoadingRunning) {
      animationLoadingRunning = true;
      return Loading(
          loop: !hasData,
          onStop: () => setState(() {
                animationLoadingRunning = false;
              }));
    }

    if (cleaning || animationCleaningRunning) {
      animationCleaningRunning = true;
      return LottieLooper(
        'assets/lotties/delete_effect.json',
        loop: cleaning,
        description: 'Cleaning...',
        width: 300,
        onStop: () {
          animationCleaningRunning = false;
          final state = ref.read(fileFilterControllerProvider).requireValue;

          context.pushNamed(AppRouter.result,
              extra: ResultArgs(
                title: 'Deleted',
                savedValue: state.cleanedFiles.fold(0.kb,
                    (previousValue, element) => previousValue + element.size),
                successResults: state.cleanedFiles
                    .map((e) => CleanResultData(
                        name: e.name,
                        iconReplacement: CleanResultIcons.photo,
                        subtitle: e.size.toStringOptimal()))
                    .toList(),
                failedResults: state.failedFiles
                    .map((e) => CleanResultData(
                        name: e.name,
                        iconReplacement: CleanResultIcons.photo,
                        subtitle: e.size.toStringOptimal()))
                    .toList(),
              ));

          Future.delayed(const Duration(milliseconds: 300))
              .then((value) => animationCleaningRunning = false);
        },
      );
    }

    debugPrint('rebuild: _ListFilePageState');

    return Scaffold(
      endDrawer: const FileFilterDrawer(),
      backgroundColor: cleanerColor.neutral3,
      body: Column(
        children: const [
          _Header(),
          NativeAd(
            size: NativeAdSize.small,
            padding: EdgeInsets.symmetric(
              vertical: 8,
              horizontal: pageHorizontalPadding,
            ),
          ),
          _ItemNumber(),
          Expanded(child: _MediaDisplayPart())
        ],
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayGridLayout = ref.watch(fileFilterControllerProvider
        .select((value) => value.valueOrNull?.displayGridLayout));
    final fileFilterParameter = ref.watch(fileFilterControllerProvider
        .select((value) => value.valueOrNull?.fileFilterParameter));

    if (displayGridLayout == null || fileFilterParameter == null) {
      return const SizedBox.shrink();
    }

    String filterLabel = '';
    String seperator = '';

    if (fileFilterParameter.photoType != PhotoType.none) {
      filterLabel += seperator + fileFilterParameter.photoType.description;
      seperator = ' / ';
    }

    if (fileFilterParameter.folderType != FolderType.all) {
      filterLabel += seperator + fileFilterParameter.folderType.description;
      seperator = ' / ';
    }

    filterLabel += seperator + fileFilterParameter.sortFileType.description;
    seperator = ' / ';

    if (fileFilterParameter.showFileType != ShowFileType.all) {
      filterLabel += seperator + fileFilterParameter.showFileType.description;
      seperator = ' / ';
    }

    if (fileFilterParameter.groupType != GroupType.none) {
      filterLabel +=
          '${seperator}Group by ${fileFilterParameter.groupType.description}';
      seperator = ' / ';
    }

    final sortAndGridButton = Row(
      children: [
        SizedBox(
          width: 40.0,
          height: 40.0,
          child: IconButton(
            onPressed: () =>
                ref.read(fileFilterControllerProvider.notifier).toggleReverse(),
            icon: RotatedBox(
              quarterTurns: fileFilterParameter.isReversed ? 2 : 0,
              child: const CleanerIcon(icon: CleanerIcons.sort),
            ),
          ),
        ),
        SizedBox(
          width: 40.0,
          height: 40.0,
          child: IconButton(
            onPressed: () =>
                ref.read(fileFilterControllerProvider.notifier).toggleGrid(),
            icon: displayGridLayout
                ? const CleanerIcon(icon: CleanerIcons.list)
                : const CleanerIcon(icon: CleanerIcons.grid),
          ),
        ),
      ],
    );
    return Column(
      children: [
        SecondaryAppBar(
          title: fileFilterParameter.fileType.description,
          trailing: sortAndGridButton,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 0, 0),
          child: FilterButton(filterLabel: filterLabel),
        ),
      ],
    );
  }
}

class _ItemNumber extends ConsumerWidget {
  const _ItemNumber();

  String _getDisplayName(
      FileType fileType, GroupType groupType, int length, int folderCount) {
    String prefix;
    String suffix = '';
    if (groupType == GroupType.folder) {
      prefix = 'Folder';
      length = folderCount;
    } else if (groupType == GroupType.type) {
      prefix = 'Type';
    } else if (fileType == FileType.all) {
      prefix = "File";
    } else if (fileType == FileType.media) {
      prefix = "Media";
    } else {
      prefix = fileType.description;
    }
    if (length > 1 && fileType != FileType.other) {
      suffix = "s";
    }
    return "$length $prefix$suffix";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAllChecked = ref.watch(fileFilterControllerProvider
        .select((value) => value.valueOrNull?.isAllChecked));

    final fileCount = ref.watch(fileFilterControllerProvider.select((value) =>
        value.valueOrNull?.fileDataList.fold(
            0, (value, element) => value + element.checkboxItems.length)));
    final folderCount = ref.watch(fileFilterControllerProvider
        .select((value) => value.valueOrNull?.fileDataList.length));
    final totalSize = ref.watch(fileFilterControllerProvider.select((value) =>
        value.valueOrNull?.fileDataList.fold(0.kb,
            (previousValue, element) => previousValue + element.totalSize)));

    final fileType = ref.watch(fileFilterControllerProvider
        .select((value) => value.valueOrNull?.fileFilterParameter?.fileType));

    final groupType = ref.watch(fileFilterControllerProvider
        .select((value) => value.valueOrNull?.fileFilterParameter?.groupType));

    if (isAllChecked == null ||
        fileCount == null ||
        folderCount == null ||
        totalSize == null ||
        fileType == null ||
        groupType == null) {
      return const SizedBox.shrink();
    }

    final displayName =
        '${_getDisplayName(fileType, groupType, fileCount, folderCount)} ';

    if (folderCount == 0) {
      return const SizedBox.shrink();
    }

    return ItemsAndSelectAction(
      displayName: displayName,
      totalSize: totalSize,
      isAllChecked: isAllChecked,
      onPressed: () =>
          ref.read(fileFilterControllerProvider.notifier).toggleAllChecked(),
    );
  }
}

class _MediaDisplayPart extends ConsumerWidget {
  const _MediaDisplayPart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cleanerColor = CleanerColor.of(context)!;
    final displayGrid = ref.watch(fileFilterControllerProvider
        .select((value) => value.valueOrNull?.displayGridLayout));

    final dataCount = ref.watch(fileFilterControllerProvider
        .select((value) => value.valueOrNull?.fileDataList.length));

    final groupType = ref.watch(fileFilterControllerProvider
        .select((value) => value.valueOrNull?.fileFilterParameter?.groupType));

    if (displayGrid == null || dataCount == null || groupType == null) {
      return const SizedBox.shrink();
    }

    debugPrint('rebuild: _MediaDisplayPart');
    if (dataCount == 0) {
      return const UnavailableDataWidget(
        description:
            'No matching file found\nChange the filter to see different results',
        svgPath: 'assets/icons/file_filter_icon.svg',
      );
    }
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height - 180,
            child: CustomScrollView(
              slivers: [
                for (int i = 0; i < dataCount; i++)
                  FileCategoryItem(
                    categoryIndex: i,
                    displayGrid: displayGrid,
                  ),

                const SliverPadding(
                  padding: EdgeInsets.only(top: 90 + 16),
                ) // TODO: height of action botton bar
              ],
            )),
        const FileBottomBar()
      ],
    );
  }
}
