import 'dart:math';

import 'package:phone_cleaner/router/router.dart';
import 'package:phone_cleaner/src/features/apps/apps.dart';
import 'package:phone_cleaner/src/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../commons/commons.dart';

class AppsBlock extends StatelessWidget {
  const AppsBlock({
    required this.iconsData,
    required this.size,
    required this.sortType,
    required this.showBadge,
    required this.periodType,
    this.isNotificationGranted = false,
    super.key,
  });

  final List<AppCheckboxItemData> iconsData;
  final String size;
  final SortType sortType;
  final PeriodType periodType;
  final bool showBadge;
  final bool isNotificationGranted;

  @override
  Widget build(BuildContext context) {
    const paddingHorizontal = 32;
    final appsDisplayNumber = min(iconsData.length, 3);
    final cleanerColor = CleanerColor.of(context)!;

    return TextButton(
      onPressed: () {
        GoRouter.of(context).pushNamed(
          AppRouter.listApp,
          extra: AppFilterArguments(
            appFilterParameter: AppFilterParameter(
              sortType: sortType,
              periodType: periodType,
            ),
          ),
        );
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.only(top: 10),
      ),
      child: SizedBox(
        width: (MediaQuery.of(context).size.width - paddingHorizontal) / 3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: appsDisplayNumber == 0
                    ? cleanerColor.neutral4
                    : Colors.transparent,
                boxShadow: [
                  appsDisplayNumber > 0
                      ? BoxShadow(
                          color: CleanerColor.of(context)!
                              .neutral4
                              .withOpacity(0.7),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      : const BoxShadow(),
                ],
                borderRadius: BorderRadius.circular(4),
              ),
              child: appsDisplayNumber == 0 ||
                      (sortType == SortType.batteryUse &&
                          !isNotificationGranted)
                  ? Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(15),
                          child: CleanerIcon(
                            icon: CleanerIcons.questionMark,
                          ),
                        ),
                        if (isNotificationGranted)
                          _Badge(
                            isNotificationGranted: isNotificationGranted,
                            isLoading: true,
                          ),
                      ],
                    )
                  : Stack(
                      clipBehavior: Clip.none,
                      children: [
                        GridView.count(
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(0),
                          crossAxisCount: 2,
                          mainAxisSpacing: 2,
                          crossAxisSpacing: 2,
                          shrinkWrap: true,
                          children: [
                            for (int i = 0; i < appsDisplayNumber; i++)
                              LayoutBuilder(builder: (context, constraints) {
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: Colors.white,
                                  ),
                                  child: iconsData[i].iconData != null
                                      ? Image.memory(
                                          iconsData[i].iconData!,
                                          cacheHeight: (MediaQuery.of(context)
                                                      .devicePixelRatio *
                                                  constraints.maxWidth)
                                              .toInt(),
                                        )
                                      : SvgPicture.asset(
                                          'assets/icons/ic_apps/3dots.svg'),
                                );
                              }),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: SvgPicture.asset(
                                  'assets/icons/ic_apps/3dots.svg'),
                            ),
                          ],
                        ),
                        if (showBadge)
                          _Badge(
                            label: size,
                          ),
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    toCapitalize(sortType.description),
                    style: regular14.copyWith(color: cleanerColor.primary10),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    Key? key,
    this.label = '',
    this.isNotificationGranted = false,
    this.isLoading = false,
  }) : super(key: key);

  final String label;
  final bool isNotificationGranted;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    return Positioned(
      top: -15,
      right: -25,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        constraints: const BoxConstraints(minWidth: 40),
        height: 24,
        decoration: BoxDecoration(
            gradient: isNotificationGranted
                ? cleanerColor.gradient1
                : cleanerColor.gradient4,
            borderRadius: BorderRadius.circular(14)),
        child: isLoading
            ? SizedBox.square(
                dimension: 10,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: cleanerColor.neutral3,
                ),
              )
            : Text(
                label,
                style: semibold12.copyWith(
                    color: CleanerColor.of(context)!.neutral3),
              ),
      ),
    );
  }
}
