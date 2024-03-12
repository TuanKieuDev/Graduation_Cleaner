import 'package:phone_cleaner/services/logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../../router/router.dart';
import '../../../../commons/commons.dart';
import '../../../../commons/widgets/result_detail.dart';
import '../../../../themes/themes.dart';
import '../../../features.dart';

const double _headerHeight = 300;
const double _resultOverviewHeight = 100;
const double _lottieSize = 150;

class CleanResult extends ConsumerStatefulWidget {
  const CleanResult({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CleanResultState();
}

class _CleanResultState extends ConsumerState<CleanResult> {
  @override
  void dispose() {
    super.dispose();
    ref.invalidate(quickCleanControllerProvider);
  }

  Function(AsyncValue? previous, AsyncValue next) logOnError(GoRouter router) =>
      (previous, next) {
        if (previous?.hasError == true) {
          return;
        }

        if (next.hasError) {
          appLogger.error('Clean Result Error', next.error, next.stackTrace);
          router.pushNamed(
            AppRouter.error,
            extra: CleanerException(message: 'Some thing went wrong'),
          );
        }
      };

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    ref.listen(quickCleanControllerProvider, logOnError(router));
    ref.listen(overallSystemControllerProvider, logOnError(router));

    final overallSystemInfo = ref.watch(overallSystemControllerProvider);

    final quickCleanInfo = ref.watch(quickCleanControllerProvider);
    if (!overallSystemInfo.hasValue ||
        !quickCleanInfo.hasValue ||
        quickCleanInfo.requireValue.cleanedSize == null) {
      throw InvalidStateException("CleanResult has no value");
    }

    if (!overallSystemInfo.hasValue) {
      throw InvalidStateException("Overall system info is not loaded");
    }

    final cleanerColor = CleanerColor.of(context)!;
    final overallSystemValue = overallSystemInfo.requireValue;
    final freeValue =
        (overallSystemValue.totalSpace - overallSystemValue.usedSpace)
            .toOptimal();
    final savedValue = quickCleanInfo.requireValue.cleanedSize!.toOptimal();

    final cleanedItems = quickCleanInfo.requireValue.cleanedItems;
    final failedItems = quickCleanInfo.requireValue.failedItems;

    return Scaffold(
      backgroundColor: cleanerColor.primary1,
      body: Stack(
        alignment: Alignment.center,
        children: [
          _Header(
            backgroundColor: cleanerColor.neutral3,
          ),
          Positioned(
            top: _headerHeight - _resultOverviewHeight / 2 + appBarHeight,
            height: _resultOverviewHeight,
            left: pageHorizontalPadding,
            right: pageHorizontalPadding,
            child: _ResultOverview(
              cleanerColor: cleanerColor,
              freeMemory: freeValue,
              savedSpace: savedValue,
            ),
          ),
          Positioned(
            top: _headerHeight + _resultOverviewHeight / 2 + 24 + appBarHeight,
            bottom: 0,
            left: 0,
            right: 0,
            child: _Results(
              resultOf: "Result",
              cleanedItems: cleanedItems,
              failedItems: failedItems,
            ),
          ),
          const Positioned(
            top: 0,
            left: 0,
            child: SecondaryAppBar(
              title: "Result",
            ),
          ),
          // const Positioned(
          //   bottom: 0,
          //   child: NativeAdOptimalSize(),
          // ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.backgroundColor,
  });

  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _HeaderDecoration(
          height: _headerHeight + appBarHeight,
        ),
        Expanded(
          child: Container(
            color: backgroundColor,
            width: double.maxFinite,
            height: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: 24,
              horizontal: pageHorizontalPadding,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderDecoration extends StatelessWidget {
  const _HeaderDecoration({
    required this.height,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      height: height,
      child: SvgPicture.asset(
        'assets/images/clean_finished_particles.svg',
        fit: BoxFit.cover,
      ),
    );
  }
}

class _ResultOverview extends StatelessWidget {
  const _ResultOverview({
    required this.cleanerColor,
    required this.freeMemory,
    required this.savedSpace,
  });

  final CleanerColor cleanerColor;
  final DigitalUnit freeMemory;
  final DigitalUnit savedSpace;

  @override
  Widget build(BuildContext context) {
    final freeMemoryWidget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RichText(
          text: TextSpan(
            text: '${freeMemory.toString()} ',
            style: bold24.copyWith(
              fontWeight: FontWeight.w900,
              color: cleanerColor.primary10,
            ),
            children: <TextSpan>[
              TextSpan(
                text: freeMemory.symbol.symbol,
                style: regular12,
              ),
            ],
          ),
        ),
        Text(
          "Free space",
          style: regular14.copyWith(
            color: cleanerColor.primary10,
          ),
        ),
      ],
    );
    final savedSpaceWidget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RichText(
          text: TextSpan(
            text: "${savedSpace.toString()} ",
            style: bold24.copyWith(
              color: const Color.fromRGBO(51, 167, 82, 1),
            ),
            children: <TextSpan>[
              TextSpan(
                text: savedSpace.symbol.symbol,
                style: regular12,
              ),
            ],
          ),
        ),
        Text(
          "Saved space",
          style:
              regular14.copyWith(color: const Color.fromRGBO(51, 167, 82, 1)),
        ),
      ],
    );

    return Container(
      // width: double.infinity,
      // height: _resultOverviewHeight,
      decoration: BoxDecoration(
          color: cleanerColor.neutral3,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(66, 133, 244, 0.25),
              blurRadius: 5,
              offset: Offset(0, 2),
            )
          ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          freeMemoryWidget,
          savedSpaceWidget,
        ],
      ),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({
    required this.cleanedItems,
    required this.failedItems,
    required this.resultOf,
  });

  final List<FileCheckboxItemData> cleanedItems;
  final List<FileCheckboxItemData> failedItems;
  final String resultOf;

  String _getItemCountString(int count) {
    return count == 1 ? "1 item" : '$count items';
  }

  @override
  Widget build(BuildContext context) {
    const icon = Padding(
      padding: EdgeInsets.only(right: pageHorizontalPadding),
      child: RotatedBox(
        quarterTurns: 3,
        child: Icon(
          Icons.expand_more,
          color: Color.fromRGBO(66, 149, 255, 1),
        ),
      ),
    );
    return CustomScrollView(
      slivers: [
        CleanerCategory(
          title: 'Cleaned items',
          subtitle: _getItemCountString(cleanedItems.length),
          icon: SvgPicture.asset('assets/icons/quick_clean/cleaned_items.svg'),
          trailing: icon,
          onSelect: (value) => context.pushNamed(
            AppRouter.resultDetail,
            extra: ResultDetailArgs(
              title: resultOf,
              results: cleanedItems
                  .map((e) => CleanResultData(
                        name: e.name,
                        iconReplacement: CleanResultIcons.file,
                      ))
                  .toList(),
            ),
          ),
        ),
        // if (failedItems.isNotEmpty)
        //   CleanerCategory(
        //     title: 'Failed items',
        //     subtitle: _getItemCountString(failedItems.length),
        //     icon: SvgPicture.asset('assets/icons/quick_clean/failed_items.svg'),
        //     trailing: icon,
        //     onSelect: (value) => context.pushNamed(
        //       AppRouter.resultDetail,
        //       extra: ResultDetailArgs(
        //         title: resultOf,
        //         results: failedItems
        //             .map((e) => CleanResultData(
        //                   name: e.name,
        //                   iconReplacement: CleanResultIcons.photo,
        //                 ))
        //             .toList(),
        //       ),
        //     ),
        //   ),
        const SliverPadding(
          padding: EdgeInsets.only(top: 16),
          sliver: SliverToBoxAdapter(
            child: NativeAd(),
          ),
        )
      ],
    );
  }
}
