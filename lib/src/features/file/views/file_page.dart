// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';

import 'package:phone_cleaner/services/logger/logger.dart';
import 'package:phone_cleaner/src/commons/widgets/loading.dart';
import 'package:phone_cleaner/src/features/file/features/filter/views/file_filter_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:phone_cleaner/router/router.dart';
import 'package:phone_cleaner/share_styles/share_styles_file.dart';

import '../../../commons/commons.dart';
import '../../../themes/cleaner_color.dart';
import '../../features.dart';

class FilePage extends ConsumerStatefulWidget {
  const FilePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FilePageState();
}

class _FilePageState extends ConsumerState<FilePage> {
  late ScrollController _scrollController;

  bool _needsLoading = false;
  bool _loadingAnimationRunning = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  Function(AsyncValue? previous, AsyncValue next) logOnError(
          {bool isGoToErrorPage = false}) =>
      (previous, next) {
        if (previous?.hasError == true) {
          return;
        }

        if (next.hasError) {
          appLogger.error('File Page Error', next.error, next.stackTrace);
          if (isGoToErrorPage) {
            GoRouter.of(context).pushNamed(
              AppRouter.error,
              extra: CleanerException(message: 'Some thing went wrong'),
            );
          }
        }
      };

  @override
  Widget build(BuildContext context) {
    ref.listen(fileCacheControllerProvider, logOnError(isGoToErrorPage: true));
    ref.listen(imageAnalysisControllerProvider, logOnError());
    ref.listen(photoOptimizedControllerProvider, logOnError());
    ref.listen(mediaFolderControllerProvider, logOnError());

    final isFileDataLoading = ref
        .watch(fileCacheControllerProvider.select((value) => value.isLoading));
    final isImageAnalysisLoading = ref.watch(
        imageAnalysisControllerProvider.select((value) => value.isLoading));
    final isPhotoOptimizedLoading = ref.watch(
        photoOptimizedControllerProvider.select((value) => value.isLoading));
    final isMediaFolderLoading = ref.watch(
        mediaFolderControllerProvider.select((value) => value.isLoading));

    bool isLoading = isFileDataLoading ||
        isImageAnalysisLoading ||
        isPhotoOptimizedLoading ||
        isMediaFolderLoading;

    if (isLoading || _loadingAnimationRunning) {
      _loadingAnimationRunning = true;
      _needsLoading = true;
      return Loading(
          loop: isLoading,
          onStop: () {
            setState(() => _loadingAnimationRunning = false);
          });
    }

    final cleanerColor = CleanerColor.of(context)!;
    return Scaffold(
      backgroundColor: cleanerColor.neutral3,
      body: Stack(
        children: [
          ScrollableBackground(scrollController: _scrollController),
          SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: const _MainContent(),
            ),
          ),
          _AppBar(scrollController: _scrollController),
        ],
      ),
    );
  }
}

class _AppBar extends StatefulWidget {
  const _AppBar({
    Key? key,
    required this.scrollController,
  }) : super(key: key);

  final ScrollController scrollController;
  @override
  State<_AppBar> createState() => _AppBarState();
}

class _AppBarState extends State<_AppBar> with SingleTickerProviderStateMixin {
  double _alpha = 1;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(() {
      final newAlpha =
          1 - clampDouble(widget.scrollController.offset / 100, 0, 1);
      if (newAlpha == _alpha) return;
      if (!mounted) return;
      setState(() {
        _alpha = newAlpha;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SecondaryAppBar(
      title: "File",
      titleOpacity: _alpha,
    );
  }
}

class _MainContent extends StatelessWidget {
  const _MainContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        children: [
          const _HeaderContent(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              PhotoAnalysis(padding: EdgeInsets.only(bottom: 12)),
              PhotoOptimizedPart(padding: EdgeInsets.symmetric(vertical: 12)),
              // Align(
              //   alignment: Alignment.center,
              //   child: NativeAd(
              //     padding: EdgeInsets.symmetric(vertical: 12),
              //   ),
              // ),
              MediaFolderPart(padding: EdgeInsets.symmetric(vertical: 12)),
              LargeVideoPart(),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderContent extends ConsumerWidget {
  const _HeaderContent();

  void _goToFilterPage(BuildContext context, FileType fileType) {
    GoRouter.of(context).pushNamed(
      AppRouter.fileFilter,
      extra: FileFilterArguments(
        fileFilterParameter: FileFilterParameter(fileType: fileType),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fileProvider = ref.watch(fileCacheControllerProvider);
    if (fileProvider.hasError) {
      return const SizedBox.shrink();
    }
    final data = fileProvider.requireValue;
    final cleanerColor = CleanerColor.of(context)!;
    //40 is the height of appBar, 280 is the height of headerContent
    const headerContent = 280;
    final contentHeight =
        headerContent - appBarHeight - MediaQuery.of(context).viewPadding.top;
    return SizedBox(
      height: contentHeight,
      child: Row(
        children: [
          Flexible(
            flex: 110,
            fit: FlexFit.tight,
            child: CustomPaint(
              painter: MultipleColorCircle(
                images: data.imagesSize.value.toInt(),
                gradientImages: cleanerColor.gradient3,
                videos: data.videosSize.value.toInt(),
                gradientVideos: cleanerColor.gradient4,
                sounds: data.soundsSize.value.toInt(),
                gradientSounds: const LinearGradient(
                  colors: [
                    Color(0xFFFFD600),
                    Color.fromRGBO(255, 255, 98, 0.5),
                  ],
                  stops: [0, 1],
                ),
                others: data.othersSize.value.toInt(),
                gradientOthers: cleanerColor.gradient1,
              ),
              child: SizedBox(
                width: 125,
                height: 125,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      data.usedSpace.toStringOptimal(),
                      style: semibold18.copyWith(color: cleanerColor.primary10),
                    ),
                    Text(
                      "${((data.usedSpace.value / data.totalSpace.value) * 100).toStringAsFixed(1)}% total",
                      style: regular12.copyWith(color: cleanerColor.neutral1),
                    )
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Flexible(
            flex: 160,
            fit: FlexFit.tight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FileTile(
                  icon: const CleanerIcon(icon: CleanerIcons.fileImage),
                  onPressed: () => _goToFilterPage(context, FileType.photo),
                  numberOfItems: data.images.length,
                  title: 'Photos',
                ),
                FileTile(
                  icon: const CleanerIcon(icon: CleanerIcons.fileVideo),
                  onPressed: () => _goToFilterPage(context, FileType.video),
                  numberOfItems: data.videos.length,
                  title: 'Videos',
                ),
                FileTile(
                  icon: const CleanerIcon(icon: CleanerIcons.fileSound),
                  onPressed: () => _goToFilterPage(context, FileType.audio),
                  numberOfItems: data.sounds.length,
                  title: 'Audios',
                ),
                FileTile(
                  icon: const CleanerIcon(icon: CleanerIcons.otherFile),
                  onPressed: () => _goToFilterPage(context, FileType.other),
                  numberOfItems: data.otherFiles.length,
                  title: 'Other files',
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
