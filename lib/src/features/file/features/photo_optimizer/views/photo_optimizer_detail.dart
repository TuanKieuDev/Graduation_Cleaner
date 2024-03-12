// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:phone_cleaner/services/logger/logger.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';

import 'package:phone_cleaner/router/router.dart';
import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/commons/widgets/lottie_looper.dart';
import 'package:phone_cleaner/src/features/file/features/filter/views/layout/file_grid_item.dart';
import 'package:phone_cleaner/src/features/file/features/photo_optimizer/controllers/photo_optimizer_controller.dart';
import 'package:phone_cleaner/src/features/file/features/photo_optimizer/controllers/photo_optimizer_preview_controller.dart';
import 'package:phone_cleaner/src/features/file/features/photo_optimizer/views/preview_photo.dart';
import 'package:phone_cleaner/src/themes/themes.dart';

import '../models/models.dart';

class PhotoOptimizerScreen extends ConsumerStatefulWidget {
  const PhotoOptimizerScreen({super.key});

  @override
  ConsumerState<PhotoOptimizerScreen> createState() =>
      _PhotoOptimizerScreenState();
}

class _PhotoOptimizerScreenState extends ConsumerState<PhotoOptimizerScreen> {
  bool processAnimationRunning = false;

  @override
  Widget build(BuildContext context) {
    final isRefreshing = ref.watch(
        photoOptimizerControllerProvider.select((value) => value.isRefreshing));

    if (isRefreshing || processAnimationRunning) {
      processAnimationRunning = true;
      return LottieLooper(
        'assets/lotties/optimization.json',
        loop: isRefreshing,
        description: "Optimizing...",
        onStop: () => setState(() {
          processAnimationRunning = true;
          final state = ref.read(photoOptimizerControllerProvider).requireValue;
          final totalOriginalSize = state.photos.fold(0.bytes,
              (previousValue, element) => previousValue + element.size);
          context.pushReplacement(AppRouter.result,
              extra: ResultArgs(
                title: 'Photo Optimization',
                savedValue: totalOriginalSize -
                    state.optimizedPhotos!.fold(
                        0.bytes,
                        (previousValue, element) =>
                            previousValue + element.size),
                successResults: state.optimizedPhotos!.map((e) {
                  final before = state.photos
                      .where((element) => element.path == e.path)
                      .firstOrNull
                      ?.size;
                  return CleanResultData(
                      name: e.name,
                      iconReplacement: CleanResultIcons.photo,
                      subtitle:
                          '${before == null ? '' : 'Before: ${before.toStringOptimal()} '}After: ${e.size.toStringOptimal()}');
                }).toList(),
                failedResults: state.failedToOptimizePhotos!
                    .map((e) => CleanResultData(
                        name: e.name, iconReplacement: CleanResultIcons.photo))
                    .toList(),
              ));
        }),
      );
    }

    return const _PhotoOptimizerCore();
  }
}

class _PhotoOptimizerCore extends StatelessWidget {
  const _PhotoOptimizerCore();

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    return Scaffold(
      backgroundColor: cleanerColor.neutral3,
      body: Column(
        children: [
          const SecondaryAppBar(title: "Photo Optimizer"),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _SetupAndPreview(),
                  SizedBox(height: 24),
                  _PhotoSummary(),
                  SizedBox(height: 24),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: pageHorizontalPadding),
                    child: _OptimizeOptions(),
                  ),
                  SizedBox(height: 24),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: pageHorizontalPadding),
                    child: _OptimizeButton(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoSummary extends ConsumerWidget {
  const _PhotoSummary();

  @override
  Widget build(context, ref) {
    final photos = ref.watch(photoOptimizerControllerProvider
        .select((value) => value.valueOrNull?.photos));

    if (photos == null) {
      return const SizedBox.shrink();
    }

    final totalSize = photos.fold(
        0.kb, (previousValue, element) => previousValue + element.size);

    final cleanerColor = CleanerColor.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: pageHorizontalPadding),
          child: RichText(
            text: TextSpan(
              text:
                  '${photos.length} ${photos.length > 1 ? 'Photos' : 'Photo'} ',
              style: semibold16.copyWith(color: cleanerColor.primary10),
              children: <TextSpan>[
                TextSpan(
                  text: totalSize.toStringOptimal(),
                  style: regular14.copyWith(color: cleanerColor.primary10),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        _PreviewList(
          itemCount: photos.length,
        )
      ],
    );
  }
}

class _PreviewList extends StatelessWidget {
  const _PreviewList({
    required this.itemCount,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      width: double.maxFinite,
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return const LinearGradient(
            colors: [
              Colors.transparent,
              Colors.white,
              Colors.white,
              Colors.transparent
            ],
            stops: [0, 0.02, 0.98, 1],
            // tileMode: TileMode.mirror,
          ).createShader(bounds);
        },
        child: ListView.builder(
          itemCount: itemCount,
          scrollDirection: Axis.horizontal,
          padding:
              const EdgeInsets.symmetric(horizontal: pageHorizontalPadding),
          itemBuilder: (builder, index) {
            return _PreviewItem(index);
          },
        ),
      ),
    );
  }
}

class _PreviewItem extends ConsumerWidget {
  const _PreviewItem(
    this.index,
  );

  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(
      photoOptimizerControllerProvider.select(
        (value) => value.valueOrNull?.photos[index],
      ),
    );

    final isSelected = ref.watch(
      photoOptimizerControllerProvider.select(
        (value) => value.valueOrNull?.previewPhotoIndex == index,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: FileGridItemIcon(
        data: data,
        width: 64,
        height: 64,
        selected: isSelected,
        onPreviewPressed: () => ref
            .read(photoOptimizerControllerProvider.notifier)
            .setSelectedIndex(index),
      ),
    );
  }
}

class _SetupAndPreview extends ConsumerWidget {
  const _SetupAndPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final optimizeValue = ref.watch(photoOptimizerControllerProvider
        .select((value) => value.valueOrNull?.optimizeValue));

    if (optimizeValue == null) {
      return const SizedBox.shrink();
    }

    late String optimizeDescription;
    switch (optimizeValue) {
      case OptimizeValue.low:
        optimizeDescription = 'Good printing quality';
        break;
      case OptimizeValue.moderate:
        optimizeDescription = 'Good for large screens';
        break;
      case OptimizeValue.high:
        optimizeDescription = 'Good for device screens';
        break;
      case OptimizeValue.aggressive:
        optimizeDescription = 'Prioritizes space over quality';
        break;
    }

    void setOptimizeValue(OptimizeValue optimizeValue) {
      ref
          .read(photoOptimizerControllerProvider.notifier)
          .setOptimizeValue(optimizeValue);
    }

    final cleanerColor = CleanerColor.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const _ImagePreviewWrapper(),
              Align(
                alignment: Alignment.topCenter,
                child: Center(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(40),
                      ),
                      onTap: () {
                        GoRouter.of(context).pushNamed(
                          AppRouter.previewPhoto,
                        );
                      },
                      child: const CleanerIcon(
                        icon: CleanerIcons.expand,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Flexible(
              child: Center(child: _OriginalImageSizeLabel()),
            ),
            Flexible(
              child: Center(child: _OptimizedImageLabel()),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.center,
          child: GradientText(
            optimizeDescription,
            gradient: cleanerColor.gradient2,
            style: semibold14,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: pageHorizontalPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    "${optimizeValue.scaleValue}x",
                    style: semibold16.copyWith(color: cleanerColor.primary10),
                  ),
                  Text(
                    'Screen Size',
                    style: regular12.copyWith(color: cleanerColor.primary10),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    "${optimizeValue.quality}%",
                    style: semibold16.copyWith(color: cleanerColor.primary10),
                  ),
                  Text(
                    'Compression',
                    style: regular12.copyWith(color: cleanerColor.primary10),
                  ),
                ],
              ),
              Column(
                children: [
                  Consumer(builder: (context, ref, child) {
                    final state =
                        ref.watch(photoOptimizerPreviewControllerProvider);
                    late String info;
                    if (!state.hasValue) {
                      info = '-';
                    } else {
                      final value = state.requireValue;
                      final savedSpaceRatio =
                          (((value.beforeSize - value.afterSize) /
                                  value.beforeSize) *
                              100);
                      info = "${savedSpaceRatio.toInt()}%";
                    }

                    return Text(
                      info,
                      style: semibold16.copyWith(color: cleanerColor.primary10),
                    );
                  }),
                  Text(
                    'Saved Space',
                    style: regular12.copyWith(color: cleanerColor.primary10),
                  ),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: pageHorizontalPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ChoiceChip(
                selected: optimizeValue == OptimizeValue.low,
                label: Text(
                  'Low',
                  style: TextStyle(
                    color: optimizeValue == OptimizeValue.low
                        ? cleanerColor.neutral3
                        : cleanerColor.neutral5,
                  ),
                ),
                disabledColor: cleanerColor.neutral4,
                selectedColor: cleanerColor.primary7,
                onSelected: (value) {
                  setOptimizeValue(OptimizeValue.low);
                },
              ),
              ChoiceChip(
                selected: optimizeValue == OptimizeValue.moderate,
                label: Text(
                  'Moderate',
                  style: TextStyle(
                    color: optimizeValue == OptimizeValue.moderate
                        ? cleanerColor.neutral3
                        : cleanerColor.neutral5,
                  ),
                ),
                disabledColor: cleanerColor.neutral4,
                selectedColor: cleanerColor.primary7,
                onSelected: (value) {
                  setOptimizeValue(OptimizeValue.moderate);
                },
              ),
              ChoiceChip(
                selected: optimizeValue == OptimizeValue.high,
                label: Text(
                  'High',
                  style: TextStyle(
                    color: optimizeValue == OptimizeValue.high
                        ? cleanerColor.neutral3
                        : cleanerColor.neutral5,
                  ),
                ),
                disabledColor: cleanerColor.neutral4,
                selectedColor: cleanerColor.primary7,
                onSelected: (value) {
                  setOptimizeValue(OptimizeValue.high);
                },
              ),
              ChoiceChip(
                selected: optimizeValue == OptimizeValue.aggressive,
                label: Text(
                  'Aggressive',
                  style: TextStyle(
                    color: optimizeValue == OptimizeValue.aggressive
                        ? cleanerColor.neutral3
                        : cleanerColor.neutral5,
                  ),
                ),
                disabledColor: cleanerColor.neutral4,
                selectedColor: cleanerColor.primary7,
                onSelected: (value) {
                  setOptimizeValue(OptimizeValue.aggressive);
                },
              ),
            ],
          ),
        )
      ],
    );
  }
}

class _OptimizeOptions extends ConsumerWidget {
  const _OptimizeOptions();

  @override
  Widget build(context, ref) {
    final originalOption = ref.watch(photoOptimizerControllerProvider
            .select((value) => value.valueOrNull?.originalOption)) ??
        OriginalOption.backup;

    final cleanerColor = CleanerColor.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Original photos",
          style: semibold16.copyWith(color: cleanerColor.primary10),
        ),
        const SizedBox(
          height: 8,
        ),
        _OptimizeOption(
          originalOption: originalOption,
          radio: SvgPicture.asset('assets/icons/file/change.svg'),
          onChanged: (_) {
            showModalBottomSheet(
              context: context,
              constraints: BoxConstraints.expand(
                height: MediaQuery.of(context).size.height / 3,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              builder: (context) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        "Original photos",
                        style:
                            semibold16.copyWith(color: cleanerColor.primary10),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      //! DO NOT REMOVE THIS
                      // _OptimizeOption(
                      //   originalOption: OriginalOption.backup,
                      //   onChanged: (value) => ref
                      //       .read(photoOptimizerControllerProvider.notifier)
                      //       .setOriginalValue(value),
                      // ),
                      _OptimizeOption(
                        originalOption: OriginalOption.delete,
                        onChanged: (value) => ref
                            .read(photoOptimizerControllerProvider.notifier)
                            .setOriginalValue(value),
                      ),
                      _OptimizeOption(
                        originalOption: OriginalOption.keepOriginal,
                        onChanged: (value) => ref
                            .read(photoOptimizerControllerProvider.notifier)
                            .setOriginalValue(value),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _OptimizeOption extends ConsumerWidget {
  const _OptimizeOption({
    Key? key,
    required this.originalOption,
    this.radio,
    this.onChanged,
  }) : super(key: key);

  final OriginalOption originalOption;
  final Widget? radio;
  final ValueSetter<OriginalOption>? onChanged;

  CleanerIcons get icon {
    switch (originalOption) {
      case OriginalOption.backup:
        return CleanerIcons.optionBackup;
      case OriginalOption.delete:
        return CleanerIcons.optionDelete;
      case OriginalOption.keepOriginal:
        return CleanerIcons.optionKeep;
    }
  }

  @override
  Widget build(context, ref) {
    final selectedOriginalOption = ref.watch(photoOptimizerControllerProvider
            .select((value) => value.valueOrNull?.originalOption)) ??
        OriginalOption.backup;

    final cleanerColor = CleanerColor.of(context)!;

    return TextButton(
      onPressed: () => onChanged?.call(originalOption),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CleanerIcon(
                icon: icon,
                size: 32,
              ),
              const SizedBox(
                width: 8,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    originalOption.description,
                    style: regular14.copyWith(color: cleanerColor.primary10),
                  ),
                  // Text(
                  //   "example@gmail.com",
                  //   style: semibold12.copyWith(color: cleanerColor.primary10),
                  // )
                ],
              ),
            ],
          ),
          radio ??
              Radio(
                value: originalOption,
                groupValue: selectedOriginalOption,
                onChanged: (value) => onChanged?.call(originalOption),
              )
        ],
      ),
    );
  }
}

class _OptimizeButton extends ConsumerWidget {
  const _OptimizeButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PrimaryButton(
      width: double.maxFinite,
      borderRadius: BorderRadius.circular(16),
      title: Row(
        children: [
          const CleanerIcon(icon: CleanerIcons.upgrade),
          const SizedBox(
            width: 10,
          ),
          Text(
            "Optimize",
            style: bold18,
          ),
        ],
      ),
      onPressed: () =>
          ref.read(photoOptimizerControllerProvider.notifier).optimize(),
    );
  }
}

class _ImagePreviewWrapper extends ConsumerWidget {
  const _ImagePreviewWrapper();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preview = ref.watch(
      photoOptimizerControllerProvider.select((value) =>
          value.valueOrNull?.photos[value.valueOrNull!.previewPhotoIndex]),
    );

    if (preview == null) {
      return const SizedBox.shrink();
    }

    var dualPreviewPhoto = GestureDetector(
      onVerticalDragStart: (_) {},
      child: PhotoViewGestureDetectorScope(
        axis: Axis.vertical,
        child: DualPreviewPhoto(
          firstImageProvider: FileImage(File(preview.path)),
          secondImageProvider: ref.watch(photoOptimizerPreviewControllerProvider
              .selectAsync((data) => MemoryImage(data.optimizedImage))),
          photoWidgetBuilder: (context, first, second) => Row(
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
        ),
      ),
    );
    return Stack(
      alignment: Alignment.center,
      children: [
        dualPreviewPhoto,
        const _ExpandButton(),
      ],
    );
  }
}

class _ExpandButton extends StatelessWidget {
  const _ExpandButton();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        height: 200,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.all(
                Radius.circular(40),
              ),
              onTap: () {
                GoRouter.of(context).pushNamed(
                  AppRouter.previewPhoto,
                );
              },
              child: const CleanerIcon(
                icon: CleanerIcons.expand,
                size: 48,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OriginalImageSizeLabel extends ConsumerWidget {
  const _OriginalImageSizeLabel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preview = ref.watch(
      photoOptimizerControllerProvider.select((value) =>
          value.valueOrNull?.photos[value.valueOrNull!.previewPhotoIndex]),
    );

    return _ImagePreviewPlaceholder(
      size: preview?.size.toStringOptimal(),
      text: 'Before ',
    );
  }
}

class _OptimizedImageLabel extends ConsumerWidget {
  const _OptimizedImageLabel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(photoOptimizerPreviewControllerProvider);
    return state.when(
      data: (data) => _ImagePreviewPlaceholder(
        size: data.afterSize.bytes.toStringOptimal(),
        text: 'After ',
      ),
      error: (error, stackTrace) {
        appLogger.error('Error while optimizing image', error, stackTrace);
        return const Center(
          child: Text('Error'),
        );
      },
      loading: () => const _ImagePreviewPlaceholder(
        size: null,
        text: 'After ',
      ),
    );
  }
}

class _ImagePreviewPlaceholder extends StatelessWidget {
  const _ImagePreviewPlaceholder({
    Key? key,
    this.size,
    required this.text,
  }) : super(key: key);

  final String? size;
  final String text;

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;

    return RichText(
      text: TextSpan(
        text: text,
        style: regular14.copyWith(color: cleanerColor.neutral1),
        children: <TextSpan>[
          TextSpan(
            text: size ?? '-',
            style: semibold12.copyWith(color: cleanerColor.neutral1),
          ),
        ],
      ),
    );
  }
}
