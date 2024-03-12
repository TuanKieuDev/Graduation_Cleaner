// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:phone_cleaner/router/router.dart';
import 'package:phone_cleaner/services/logger/logger.dart';
import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/commons/widgets/lottie_looper.dart';
import 'package:phone_cleaner/src/features/features.dart';
import 'package:phone_cleaner/src/themes/themes.dart';

class SavingTipsView extends ConsumerStatefulWidget {
  const SavingTipsView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SavingTipsViewState();
}

class _SavingTipsViewState extends ConsumerState<SavingTipsView> {
  late ScrollController _scrollController;

  bool _loadingAnimationRunning = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Function(AsyncValue? previous, AsyncValue next) logOnError() =>
      (previous, next) {
        if (previous?.hasError == true) {
          return;
        }

        if (next.hasError) {
          appLogger.error(
              'Saving Tips Part Error', next.error, next.stackTrace);
          GoRouter.of(context).pushNamed(
            AppRouter.error,
            extra: CleanerException(message: 'Some thing went wrong'),
          );
        }
      };

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    final isLoading = ref
        .watch(savingTipsControllerProvider.select((value) => value.isLoading));

    if (isLoading || _loadingAnimationRunning) {
      return LottieLooper(
        'assets/lotties/tips_loading.json',
        loop: isLoading,
        height: 150,
        width: 150,
        onStop: () => setState(() => _loadingAnimationRunning = false),
      );
    }
    return Scaffold(
      backgroundColor: cleanerColor.neutral3,
      body: Stack(
        children: [
          ScrollableBackground(scrollController: _scrollController),
          _DetailContent(scrollController: _scrollController),
          _AppBar(scrollController: _scrollController),
        ],
      ),
    );
  }
}

class _DetailContent extends ConsumerWidget {
  const _DetailContent({
    required this.scrollController,
    Key? key,
  }) : super(key: key);

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cleanerColor = CleanerColor.of(context)!;
    final state = ref.watch(savingTipsControllerProvider).requireValue;
    return SafeArea(
      child: SingleChildScrollView(
        controller: scrollController,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 72 + 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // const UnnecessaryDataPartView(),
                  // const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 45,
                      top: 10,
                      right: 27,
                      bottom: 45,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GradientText(
                              state.tipCounter.toString(),
                              style: const TextStyle(
                                fontSize: 75,
                                fontWeight: FontWeight.w600,
                              ),
                              gradient: cleanerColor.gradient2,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              state.tipCounter <= 1 ? 'Tip' : 'Tips',
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFFF29428),
                                height: 2.8,
                              ),
                            ),
                          ],
                        ),
                        SvgPicture.asset(
                          'assets/images/bg_tips.svg',
                          // height: 93,
                          // width: 133,
                          // fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  ),
                  if (state.isShowRarelyUsedAppsTip) ...[
                    const RarelyUsedAppsPartView(),
                    const AppVerticalDivider(verticalPadding: 20),
                  ],
                  if (state.isShowUnUsedAppsTip) ...[
                    const UnusedAppsPartView(),
                    const AppVerticalDivider(verticalPadding: 20),
                  ],

                  if (state.isShowPhotoTip) ...[
                    const PhotoPreviewPartView(),
                    const AppVerticalDivider(verticalPadding: 20),
                  ],

                  if (state.isShowLargeAppsTips) ...[
                    const LargeAppsPartView(),
                    const AppVerticalDivider(verticalPadding: 20),
                  ],

                  // const AppDiaryPartView(),
                ],
              ),
            ),
          ],
        ),
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
    widget.scrollController.addListener(_syncAlpha);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_syncAlpha);
    super.dispose();
  }

  void _syncAlpha() {
    final newAlpha =
        1 - clampDouble(widget.scrollController.offset / 100, 0, 1);
    if (newAlpha == _alpha) return;
    if (!mounted) {
      return;
    }
    setState(() {
      _alpha = newAlpha;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SecondaryAppBar(
      title: "Tips",
      titleOpacity: _alpha,
    );
  }
}
