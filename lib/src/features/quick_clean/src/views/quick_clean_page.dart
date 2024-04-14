// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:phone_cleaner/router/router.dart';
import 'package:phone_cleaner/services/logger/logger.dart';
import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/features/features.dart';
import 'package:phone_cleaner/src/themes/themes.dart';
import 'package:delayed_tween_animation_builder/delayed_tween_animation_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:monetization/monetization.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'package:phone_cleaner/src/commons/widgets/loading.dart';

class QuickClean extends ConsumerStatefulWidget {
  const QuickClean({super.key});

  @override
  ConsumerState<QuickClean> createState() => _QuickCleanState();
}

class _QuickCleanState extends ConsumerState<QuickClean> {
  bool _isCleaning = false;
  bool _needsLoading = false;
  bool _loadingAnimationRunning = true;
  bool _contentFullyVisible = false;

  void _clean() async {
    setState(() => _isCleaning = true);
    ref.read(quickCleanControllerProvider.notifier).clean();
  }

  Future _waitForContent() async {
    await ref.read(quickCleanControllerProvider.notifier).future;
    await Future.delayed(const Duration(seconds: 1, milliseconds: 600));
    setState(() {
      _contentFullyVisible = true;
    });
  }

  Function(AsyncValue? previous, AsyncValue next) logOnError() =>
      (previous, next) {
        if (previous?.hasError == true) {
          return;
        }
        if (next.hasError) {
          appLogger.error(
              'Quick Clean Page Error', next.error, next.stackTrace);
          GoRouter.of(context).pushNamed(
            AppRouter.error,
            extra: CleanerException(message: 'Some thing went wrong'),
          );
        }
      };

  @override
  Widget build(BuildContext context) {
    ref.listen(quickCleanControllerProvider, logOnError());

    final isLoading = ref
        .watch(quickCleanControllerProvider.select((value) => value.isLoading));
    final isRefreshing = ref.watch(
        quickCleanControllerProvider.select((value) => value.isRefreshing));
    final totalCleanChecked = ref.watch(quickCleanControllerProvider
        .select((value) => value.valueOrNull?.selectedSize));

    if (isLoading && !isRefreshing || _loadingAnimationRunning) {
      _needsLoading = true;
      _loadingAnimationRunning = true;
      return Loading(
        loop: isLoading,
        onStop: () => setState(() {
          _loadingAnimationRunning = false;
          _waitForContent();
        }),
      );
    }

    if (_isCleaning) {
      return ProcessAndResultLottie(
        loop: isRefreshing,
        child: const CleanResult(),
      );
    }

    return _QuickCleanCore(
      animated: _needsLoading,
      contentFullyVisible: _contentFullyVisible,
      onCleanPressed: () =>
          showConfirmDialog(context, totalCleanChecked!, _clean),
    );
  }
}

class _QuickCleanCore extends ConsumerWidget {
  const _QuickCleanCore({
    required this.animated,
    required this.contentFullyVisible,
    required this.onCleanPressed,
  });

  final bool animated;
  final bool contentFullyVisible;
  final VoidCallback onCleanPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const Background(
            secondaryBackground: true,
          ),
          _Overrall(isAnimated: animated),
          _MainContent(
            isAnimated: animated,
            contentFullyVisible: contentFullyVisible,
          ),
          if (contentFullyVisible || !animated)
            Positioned(
              right: 16,
              bottom: 24,
              child: _ActionButtonClean(onPressed: onCleanPressed),
            )
        ],
      ),
    );
  }
}

class _Overrall extends ConsumerWidget {
  const _Overrall({
    required this.isAnimated,
  });

  final bool isAnimated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double headerHeight = 250;

    final totalClean = ref.watch(quickCleanControllerProvider
        .select((value) => value.valueOrNull?.totalSize));
    final totalCleanChecked = ref.watch(quickCleanControllerProvider
        .select((value) => value.valueOrNull?.selectedSize));

    if (totalClean == null || totalCleanChecked == null) {
      return const SizedBox.shrink();
    }

    Widget secondaryAppBar = const SecondaryAppBar(
      title: "Quick Clean",
    );

    final total = totalCleanChecked > 0.kb
        ? totalCleanChecked.toOptimal()
        : totalClean.toOptimal();
    final cleanerColor = CleanerColor.of(context)!;

    final size = Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        GradientText(
          total.toString(),
          style: const TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.w700,
          ),
          gradient: cleanerColor.gradient2,
        ),
        GradientText(
          total.symbol.symbol,
          style: regular18,
          gradient: cleanerColor.gradient2,
        )
      ],
    );

    final label = Text(
      totalCleanChecked > 0.kb ? 'Selected Items' : 'Files to clean',
      style: semibold18.copyWith(
        color: cleanerColor.primary10,
      ),
    );

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        size,
        label,
      ],
    );

    Widget recycleBin = SvgPicture.asset(
      'assets/icons/trash_can.svg',
    );

    if (isAnimated) {
      secondaryAppBar = TweenAnimationBuilder(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuad,
        tween: Tween<double>(begin: 0, end: 1),
        builder: (BuildContext context, double scale, Widget? child) {
          return Opacity(
            opacity: scale,
            child: child,
          );
        },
        child: secondaryAppBar,
      );

      secondaryAppBar = TweenAnimationBuilder(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuad,
        tween: Tween<double>(
          begin: 50,
          end: 0,
        ),
        builder: (BuildContext context, double positionTop, Widget? child) {
          return Transform.translate(
              offset: Offset(0, positionTop), child: child!);
        },
        child: secondaryAppBar,
      );
    } else {
      secondaryAppBar = secondaryAppBar;
    }

    if (isAnimated) {
      content = TweenAnimationBuilder(
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOutQuad,
        tween: Tween<double>(begin: 0, end: 1),
        builder: (BuildContext context, double scale, Widget? child) {
          return Opacity(
            opacity: scale,
            child: child,
          );
        },
        child: content,
      );

      content = TweenAnimationBuilder(
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOutQuad,
        tween: Tween<double>(
          begin: 50,
          end: 0,
        ),
        builder: (BuildContext context, double positionTop, Widget? child) {
          return Positioned(
            left: 25,
            child: Transform.translate(
                offset: Offset(0, positionTop), child: child!),
          );
        },
        child: content,
      );
    } else {
      content = Positioned(
        // top: contentHeight / 2,
        left: 25,
        child: content,
      );
    }

    if (isAnimated) {
      recycleBin = TweenAnimationBuilder(
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOutQuad,
        tween: Tween<double>(begin: 0, end: 1),
        builder: (BuildContext context, double scale, Widget? child) {
          return Opacity(
            opacity: scale,
            child: child,
          );
        },
        child: recycleBin,
      );

      recycleBin = TweenAnimationBuilder(
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOutQuad,
        tween: Tween<double>(
          begin: 50,
          end: 0,
        ),
        builder: (BuildContext context, double positionTop, Widget? child) {
          return Positioned(
            // top: positionTop,
            right: 30,
            child: Transform.translate(
              offset: Offset(0, positionTop),
              child: child!,
            ),
          );
        },
        child: recycleBin,
      );
    } else {
      recycleBin = Positioned(
        // top: contentHeight / 2,
        top: 15,
        right: 30,
        child: recycleBin,
      );
    }

    return SizedBox(
      height: headerHeight,
      child: Column(
        children: [
          secondaryAppBar,
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                content,
                recycleBin,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MainContent extends StatelessWidget {
  const _MainContent({
    required this.isAnimated,
    required this.contentFullyVisible,
  });

  final bool isAnimated;
  final bool contentFullyVisible;

  @override
  Widget build(BuildContext context) {
    final contentHeight = MediaQuery.of(context).size.height - 250;

    final itemList = ItemList(
      contentFullyVisible: contentFullyVisible,
    );

    Widget widget = itemList;

    if (isAnimated) {
      widget = DelayedTweenAnimationBuilder(
        delay: const Duration(seconds: 1),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInQuad,
        tween: Tween<double>(begin: 0, end: 1),
        builder: (BuildContext context, double opacity, Widget? child) {
          return Opacity(opacity: opacity, child: child);
        },
        child: widget,
      );

      widget = DelayedTweenAnimationBuilder(
        delay: const Duration(seconds: 1),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutQuad,
        tween: Tween<double>(
          begin: 350,
          end: 250,
        ),
        builder: (BuildContext context, double marginTop, Widget? child) {
          return Container(
            margin: EdgeInsets.only(top: marginTop),
            constraints: BoxConstraints(minHeight: contentHeight),
            color: Colors.transparent,
            child: child,
          );
        },
        child: widget,
      );
    } else {
      widget = Container(
        margin: const EdgeInsets.only(top: 250),
        constraints: BoxConstraints(minHeight: contentHeight),
        color: Colors.transparent,
        child: itemList,
      );
    }

    return widget;
  }
}

class ItemList extends ConsumerWidget {
  const ItemList({
    Key? key,
    required this.contentFullyVisible,
  }) : super(key: key);

  final bool contentFullyVisible;

  @override
  Widget build(context, ref) {
    final cleanerColor = CleanerColor.of(context)!;

    final lowImportantListCount = ref.watch(quickCleanControllerProvider.select(
        (value) => value.valueOrNull?.categories
            .where((element) => element.importantLevel == ImportantLevel.low)
            .length));
    final mediumImportantCount = ref.watch(quickCleanControllerProvider.select(
        (value) => value.valueOrNull?.categories
            .where((element) => element.importantLevel == ImportantLevel.medium)
            .length));
    final highImportantListCount = ref.watch(quickCleanControllerProvider
        .select((value) => value.valueOrNull?.categories
            .where((element) => element.importantLevel == ImportantLevel.low)
            .length));
    final canShowButtonClean = ref.watch(
          quickCleanControllerProvider
              .select((value) => value.valueOrNull?.categories.any(
                    (element) => element.selectedCount > 0,
                  )),
        ) ??
        false;

    final totalCount = ref.watch(quickCleanControllerProvider
        .select((value) => value.valueOrNull?.categories.length));

    if (lowImportantListCount == null ||
        mediumImportantCount == null ||
        highImportantListCount == null ||
        totalCount == null) {
      return const SizedBox.shrink();
    }

    Widget header(int index) {
      if (lowImportantListCount != 0 && index == 0) {
        return _ImportantLabel(
            description: ImportantLevel.low.description,
            gradientColor: cleanerColor.gradient3);
      }
      if (mediumImportantCount != 0 && index == lowImportantListCount) {
        return _ImportantLabel(
            description: ImportantLevel.medium.description,
            gradientColor: cleanerColor.gradient2);
      }
      if (highImportantListCount != 0 &&
          index == lowImportantListCount + mediumImportantCount) {
        return _ImportantLabel(
            description: ImportantLevel.high.description,
            gradientColor: cleanerColor.gradient4);
      }

      return const SizedBox.shrink();
    }

    return CustomScrollView(
      slivers: [
        for (int categoryIndex = 0; categoryIndex < totalCount; categoryIndex++)
          MultiSliver(
            children: [
              header(categoryIndex),
              QuickCleanCategoryItem(
                categoryIndex: categoryIndex,
              ),
              // footer(categoryIndex),
            ],
          ),
        if (contentFullyVisible || true)
          SliverToBoxAdapter(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: SizedBox(height: canShowButtonClean ? 90 : 0),
            ),
          ),
      ],
    );
  }
}

class _ImportantLabel extends StatelessWidget {
  const _ImportantLabel({
    Key? key,
    required this.description,
    required this.gradientColor,
  }) : super(key: key);

  final String description;
  final Gradient gradientColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 8.0, horizontal: pageHorizontalPadding),
      child: GradientText(
        description,
        style: regular16,
        gradient: gradientColor,
      ),
    );
  }
}

class _ActionButtonClean extends ConsumerWidget {
  const _ActionButtonClean({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canShowButtonClean = ref.watch(
          quickCleanControllerProvider
              .select((value) => value.valueOrNull?.categories.any(
                    (element) => element.selectedCount > 0,
                  )),
        ) ??
        false;
    return OpacityTweener(
      duration: const Duration(milliseconds: 300),
      child: AnimatedOpacity(
        opacity: canShowButtonClean ? 1 : 0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuad,
        child: PrimaryButton(
          onPressed: onPressed,
          enable: canShowButtonClean,
          title: Row(
            children: const [
              CleanerIcon(
                icon: CleanerIcons.cleaner,
              ),
              SizedBox(
                width: 9,
              ),
              Text("Clean"),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          textStyle: bold20,
          height: 46,
          width: MediaQuery.of(context).size.width - 32,
        ),
      ),
    );
  }
}

Future<void> showConfirmDialog(
  BuildContext context,
  DigitalUnit cleanSize,
  Function actionClean,
) async {
  final cleanerColor = CleanerColor.of(context)!;

  var cancelButton = PrimaryButton(
      title: Text('Cancel',
          style: regular14.copyWith(color: cleanerColor.primary7)),
      onPressed: () {
        Navigator.of(context).pop();
      },
      height: 32,
      width: (MediaQuery.of(context).size.width - 120) / 2,
      enableShadow: false,
      borderRadius: BorderRadius.circular(16),
      gradientColor: LinearGradient(colors: [
        cleanerColor.primary1,
        cleanerColor.primary1,
      ]));
  var cleanButton = PrimaryButton(
    title: Text(
      'Clean',
      style: regular14.copyWith(color: cleanerColor.neutral3),
    ),
    onPressed: () {
      actionClean();
      Navigator.of(context).pop();
    },
    height: 32,
    width: (MediaQuery.of(context).size.width - 120) / 2,
    enableShadow: false,
    borderRadius: BorderRadius.circular(16),
    gradientColor: cleanerColor.gradient1,
  );

  const lottiePath = 'assets/lotties/delete_effect.json';

  return showDialog<void>(
      context: context,
      builder: (context) {
        return CleanerDialog(
            lottiePath: lottiePath,
            title: 'Clean ${cleanSize.toStringOptimal()}',
            content:
                'The items you choose will be cleaned up and permanently deleted',
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  cancelButton,
                  cleanButton,
                ],
              ),
            ]);
      });
}
