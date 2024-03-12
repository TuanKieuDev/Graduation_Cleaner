// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:phone_cleaner/router/router.dart';
import 'package:phone_cleaner/src/commons/widgets/result_detail.dart';
import 'package:phone_cleaner/src/features/home/home.dart';
import 'package:phone_cleaner/src/themes/themes.dart';
import 'package:lottie/lottie.dart';

import '../commons.dart';

const double _headerHeight = 300;
const double _resultOverviewHeight = 100;
const double _lottieSize = 120;

class ResultArgs {
  final String title;
  final DigitalUnit savedValue;
  final List<CleanResultData> successResults;
  final List<CleanResultData> failedResults;

  ResultArgs({
    required this.title,
    required this.savedValue,
    this.successResults = const [],
    this.failedResults = const [],
  });

  ResultArgs copyWith({
    String? title,
    DigitalUnit? savedValue,
    List<CleanResultData>? successResults,
    List<CleanResultData>? failedResults,
  }) {
    return ResultArgs(
      title: title ?? this.title,
      savedValue: savedValue ?? this.savedValue,
      successResults: successResults ?? this.successResults,
      failedResults: failedResults ?? this.failedResults,
    );
  }
}

class Result extends ConsumerWidget {
  const Result({
    Key? key,
    required this.title,
    required this.savedValue,
    this.successResults = const [],
    this.failedResults = const [],
  }) : super(key: key);

  final String title;
  final DigitalUnit savedValue;
  final List<CleanResultData> successResults;
  final List<CleanResultData> failedResults;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overallSystemInfo = ref.refresh(overallSystemControllerProvider);

    if (!overallSystemInfo.hasValue) {
      throw InvalidStateException("Overall system info is not loaded");
    }

    final overallSystemValue = overallSystemInfo.requireValue;

    final freeValue =
        (overallSystemValue.totalSpace - overallSystemValue.usedSpace)
            .toOptimal();

    final cleanerColor = CleanerColor.of(context)!;
    return Scaffold(
        backgroundColor: cleanerColor.primary1,
        body: Stack(
          alignment: Alignment.center,
          children: [
            _Header(
              backgroundColor: cleanerColor.neutral3,
            ),
            Positioned(
              top: _headerHeight - _resultOverviewHeight - _lottieSize * 2 / 3,
              child: Lottie.asset(
                'assets/lotties/done.json',
                width: _lottieSize,
                repeat: false,
              ),
            ),
            Positioned(
              top: _headerHeight - _resultOverviewHeight / 2,
              height: _resultOverviewHeight,
              left: pageHorizontalPadding,
              right: pageHorizontalPadding,
              child: _ResultOverview(
                cleanerColor: cleanerColor,
                freeMemory: freeValue,
                savedSpace: savedValue.toOptimal(),
              ),
            ),
            Positioned(
              top: _headerHeight + _resultOverviewHeight / 2 + 24,
              bottom: 0,
              left: 0,
              right: 0,
              child: _Results(
                resultOf: title,
                cleanedItems: successResults,
                failedItems: failedResults,
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: SecondaryAppBar(
                title: title,
              ),
            ),
          ],
        ));
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
          height: _headerHeight,
        ),
        Expanded(
          child: Container(
            color: backgroundColor,
            width: double.maxFinite,
            height: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: 24,
              horizontal: horizontalPadding,
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
          style: regular12.copyWith(
            color: cleanerColor.primary10,
          ),
        ),
      ],
    );
    final savedSpaceWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              regular12.copyWith(color: const Color.fromRGBO(51, 167, 82, 1)),
        ),
      ],
    );

    return Container(
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
    Key? key,
    required this.cleanedItems,
    required this.failedItems,
    required this.resultOf,
  }) : super(key: key);

  final List<CleanResultData> cleanedItems;
  final List<CleanResultData> failedItems;
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
          title: 'Processed items',
          subtitle: _getItemCountString(cleanedItems.length),
          icon: SvgPicture.asset('assets/icons/quick_clean/cleaned_items.svg'),
          trailing: icon,
          onSelect: (value) => context.pushNamed(
            AppRouter.resultDetail,
            extra: ResultDetailArgs(title: resultOf, results: cleanedItems),
          ),
        ),
        if (failedItems.isNotEmpty)
          CleanerCategory(
            title: 'Failed items',
            subtitle: _getItemCountString(failedItems.length),
            icon: SvgPicture.asset('assets/icons/quick_clean/failed_items.svg'),
            trailing: icon,
            onSelect: (value) => context.pushNamed(
              AppRouter.resultDetail,
              extra: ResultDetailArgs(title: resultOf, results: failedItems),
            ),
          ),
      ],
    );
  }
}

class CleanResultData {
  final String name;
  final Uint8List? icon;
  final CleanResultIcons? iconReplacement;
  final String? subtitle;

  CleanResultData({
    required this.name,
    this.icon,
    this.iconReplacement,
    this.subtitle,
  }) : assert(icon != null || iconReplacement != null);

  CleanResultData copyWith({
    String? name,
    Uint8List? icon,
    CleanResultIcons? iconReplacement,
    String? subtitle,
  }) {
    return CleanResultData(
      name: name ?? this.name,
      icon: icon ?? this.icon,
      iconReplacement: iconReplacement ?? this.iconReplacement,
      subtitle: subtitle ?? this.subtitle,
    );
  }

  @override
  String toString() =>
      'CleanResultData(name: $name, icon: $icon, iconReplacement: $iconReplacement)';

  @override
  bool operator ==(covariant CleanResultData other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.icon == icon &&
        other.iconReplacement == iconReplacement;
  }

  @override
  int get hashCode => name.hashCode ^ icon.hashCode ^ iconReplacement.hashCode;
}

enum CleanResultIcons { photo, video, file, app }
