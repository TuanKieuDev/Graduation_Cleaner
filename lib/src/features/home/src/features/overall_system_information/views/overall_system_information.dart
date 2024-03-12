// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:phone_cleaner/services/logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import 'package:phone_cleaner/router/router.dart';
import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/features/features.dart';
import 'package:phone_cleaner/src/themes/cleaner_color.dart';
import 'package:phone_cleaner/src/themes/fonts.dart';

class OverallSystemInformation extends ConsumerStatefulWidget {
  const OverallSystemInformation({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _OverallSystemInformationState();
}

class _OverallSystemInformationState
    extends ConsumerState<OverallSystemInformation> {
  @override
  Widget build(BuildContext context) {
    final permission = ref.watch(permissionControllerProvider).valueOrNull;

    appLogger.debug(
        'isFileGranted: ${permission?.isFileGranted} && isUsageGranted: ${permission?.isUsageGranted}');

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            SizedBox(
              width: constraints.maxWidth,
              height: 13 / 18 * MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Lottie.asset(
                        'assets/lotties/home_rocket.json',
                        width: 172 *
                            MediaQuery.of(context).size.width /
                            originalSizeWidth,
                        repeat: false,
                      ),
                      const _QuickClean(),
                    ],
                  ),
                  _DetailCleanInformation(
                    isGranted: permission?.isFileGranted,
                  ),
                ],
              ),
            ),
            _CategoriesPart(
              isManageAllFileGranted: permission?.isFileGranted,
              isDataUsageGranted: permission?.isUsageGranted,
            ),
          ],
        );
      },
    );
  }
}

class _QuickClean extends ConsumerWidget {
  const _QuickClean({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(overallSystemControllerProvider);

    const size = 160;
    final used = data.value?.usedSpace.to(DigitalUnitSymbol.gigabyte) ?? 0.gb;
    final total = data.value?.totalSpace.to(DigitalUnitSymbol.gigabyte) ?? 0.gb;
    const sizeLottie = 200;

    final cleanerColor = CleanerColor.of(context)!;

    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        alignment: Alignment.center,
        children: [
          ClipPath(
            clipper: ClipCircle(
              x: sizeLottie * constraints.maxWidth / originalSizeWidth,
              y: sizeLottie * constraints.maxWidth / originalSizeWidth,
              w: 20 * constraints.maxWidth / originalSizeWidth,
            ),
            child: Lottie.asset(
              'assets/lotties/home_circular_progress.json',
              width: sizeLottie * constraints.maxWidth / originalSizeWidth,
            ),
          ),
          CustomPaint(
            painter: CircleProgress((used.value / total.value) * 100),
            child: SizedBox(
              width: size * (constraints.maxWidth / originalSizeWidth),
              height: size * (constraints.maxWidth / originalSizeWidth),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Used space",
                      style: regular14.copyWith(color: cleanerColor.neutral5)),
                  if (data.hasValue)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        "$used/$total",
                        style: bold20.copyWith(color: cleanerColor.primary10),
                      ),
                    ),
                  Text(
                    "${DigitalUnitSymbol.gigabyte}",
                    style: regular14.copyWith(color: cleanerColor.primary10),
                  )
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _DetailCleanInformation extends ConsumerWidget {
  const _DetailCleanInformation({
    Key? key,
    required this.isGranted,
  }) : super(key: key);

  final bool? isGranted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('build _DetailCleanInformation');
    String? possibleCleanSize;
    if (isGranted == true) {
      possibleCleanSize = ref
          .watch(quickCleanControllerProvider)
          .value
          ?.totalSize
          .toStringOptimal();
    }
    final cleanerColor = CleanerColor.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            Text(
              "More optimization",
              style: TextStyle(color: cleanerColor.primary10),
            ),
            if (possibleCleanSize != null)
              Text(
                possibleCleanSize,
                style: semibold16.copyWith(
                  color: cleanerColor.primary6,
                ),
              ),
          ],
        ),
        const CleanerIcon(icon: CleanerIcons.forwardArrow),
        PrimaryButton(
          title: Row(
            children: const [
              CleanerIcon(
                icon: CleanerIcons.cleaner,
              ),
              SizedBox(
                width: 9,
              ),
              Text("Quick Clean"),
            ],
          ),
          onPressed: () async {
            if (isGranted == true) {
              final goRouter = GoRouter.of(context);
              await Future.delayed(nextPageTransitionDelayDuration, (() {
                goRouter.pushNamed(AppRouter.quickClean);
              }));
            } else {
              showRequestManageFileDialog(context, ref);
            }
          },
          borderRadius: BorderRadius.circular(16),
        )
      ],
    );
  }
}

class _CategoriesPart extends StatelessWidget {
  const _CategoriesPart({
    Key? key,
    required this.isManageAllFileGranted,
    required this.isDataUsageGranted,
  }) : super(key: key);

  final bool? isManageAllFileGranted;
  final bool? isDataUsageGranted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0),
      child: GridView.count(
        padding: const EdgeInsets.only(top: 16),
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.85,
        crossAxisCount: 2,
        crossAxisSpacing: 23,
        mainAxisSpacing: 16,
        shrinkWrap: true,
        children: [
          _BoostCategory(
            isManageAllFileGranted: isManageAllFileGranted,
          ),
          _TipsCategory(
            isManageAllFileGranted: isManageAllFileGranted,
            isDataUsageGranted: isDataUsageGranted,
          ),
          _MediaCategory(
            isManageAllFileGranted: isManageAllFileGranted,
          ),
          _AppCategory(
            isManageAllFileGranted: isManageAllFileGranted,
            isDataUsageGranted: isDataUsageGranted,
          ),
        ],
      ),
    );
  }
}

class _TipsCategory extends ConsumerWidget {
  final bool? isManageAllFileGranted;
  final bool? isDataUsageGranted;

  const _TipsCategory({
    required this.isManageAllFileGranted,
    required this.isDataUsageGranted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SavingTipsState? data;
    if (isManageAllFileGranted == true && isDataUsageGranted == true) {
      data = ref.watch(savingTipsControllerProvider).valueOrNull;
    }
    return _CleanerCategory(
      icon: CleanerIcons.tip,
      label: 'Tips',
      value: data != null ? '${data.tipCounter} tips' : '',
      isGranted: isManageAllFileGranted == true && isDataUsageGranted == true,
      onPressed: () async {
        if (isDataUsageGranted == true && isManageAllFileGranted == true) {
          final goRouter = GoRouter.of(context);
          await Future.delayed(nextPageTransitionDelayDuration);
          goRouter.pushNamed(AppRouter.savingTips);
        } else {
          if (!(isDataUsageGranted ?? false)) {
            showRequestAccessUsageDialog(context, ref);
          }
          if (!(isManageAllFileGranted ?? false)) {
            showRequestManageFileDialog(context, ref);
          }
        }
      },
    );
  }
}

class _BoostCategory extends ConsumerWidget {
  const _BoostCategory({
    required this.isManageAllFileGranted,
  });

  final bool? isManageAllFileGranted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('build _BoostCategory');
    OverallDeviceStorageInfo? data;
    if (isManageAllFileGranted == true) {
      data = ref.watch(overallSystemControllerProvider).valueOrNull;
    }
    final used = data?.usedMemory.to(DigitalUnitSymbol.gigabyte) ?? 0.gb;
    final total = data?.totalMemory.to(DigitalUnitSymbol.gigabyte) ?? 0.gb;
    return _CleanerCategory(
      icon: CleanerIcons.boost,
      label: "Boost",
      value: data != null ? "RAM: $used/${total.toStringWithSymbol()}" : '',
      isGranted: isManageAllFileGranted ?? false,
      onPressed: () async {
        if (isManageAllFileGranted == true) {
          final goRouter = GoRouter.of(context);
          await Future.delayed(nextPageTransitionDelayDuration);
          goRouter.pushNamed(AppRouter.boost);
        } else {
          showRequestManageFileDialog(context, ref);
        }
      },
    );
  }
}

class _AppCategory extends ConsumerWidget {
  const _AppCategory({
    required this.isManageAllFileGranted,
    required this.isDataUsageGranted,
  });

  final bool? isManageAllFileGranted;
  final bool? isDataUsageGranted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('build _AppCategory');
    AppsInfo? apps;
    if (isDataUsageGranted == true && isManageAllFileGranted == true) {
      apps = ref.watch(appsControllerProvider).valueOrNull;
    }

    return _CleanerCategory(
      icon: CleanerIcons.apps,
      label: "Apps",
      value: (apps != null) ? "+${apps.totalAppsSize.toStringOptimal()}" : '',
      isGranted: isManageAllFileGranted == true && isDataUsageGranted == true,
      onPressed: () async {
        if (isDataUsageGranted == true && isManageAllFileGranted == true) {
          final goRouter = GoRouter.of(context);
          await Future.delayed(nextPageTransitionDelayDuration);
          goRouter.pushNamed(AppRouter.apps);
        } else {
          if (!(isDataUsageGranted ?? false)) {
            showRequestAccessUsageDialog(context, ref);
          }
          if (!(isManageAllFileGranted ?? false)) {
            showRequestManageFileDialog(context, ref);
          }
        }
      },
    );
  }
}

class _MediaCategory extends ConsumerWidget {
  const _MediaCategory({
    required this.isManageAllFileGranted,
  });

  final bool? isManageAllFileGranted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('build _MediaCategory');

    FileCacheInfo? files;
    if (isManageAllFileGranted == true) {
      files = ref.watch(fileCacheControllerProvider).valueOrNull;
    }

    return _CleanerCategory(
      icon: CleanerIcons.media,
      label: 'Media',
      value: (files != null) ? "+${files.usedSpace.toStringOptimal()}" : '',
      isGranted: isManageAllFileGranted ?? false,
      onPressed: () async {
        if (isManageAllFileGranted == true) {
          final goRouter = GoRouter.of(context);
          await Future.delayed(nextPageTransitionDelayDuration);
          goRouter.pushNamed(AppRouter.media);
        } else {
          showRequestManageFileDialog(context, ref);
        }
      },
    );
  }
}

class _CleanerCategory extends StatelessWidget {
  const _CleanerCategory({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onPressed,
    required this.isGranted,
  }) : super(key: key);

  final CleanerIcons icon;
  final String label;
  final String value;
  final Function() onPressed;
  final bool isGranted;
  @override
  Widget build(BuildContext context) {
    var cleanerColor = CleanerColor.of(context)!;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: cleanerColor.neutral3,
          foregroundColor: cleanerColor.primary3.withAlpha(150),
          shadowColor: const Color.fromRGBO(0, 0, 0, 0.3),
          elevation: 20,
          padding: const EdgeInsets.symmetric(horizontal: 16)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CleanerIcon(icon: icon),
          Text(
            label,
            style: semibold16.copyWith(color: cleanerColor.primary10),
          ),
          Text(
            isGranted ? value : 'Access Denied',
            style: regular12.copyWith(
              color: cleanerColor.neutral1,
            ),
          ),
        ],
      ),
    );
  }
}

class ClipCircle extends CustomClipper<Path> {
  ClipCircle({
    required this.x,
    required this.y,
    required this.w,
  });

  final double x;
  final double y;
  final double w;

  @override
  Path getClip(Size size) {
    var path = Path();
    var rect = Rect.fromLTRB(0, 0, x, y);
    path.addOval(rect);
    path.fillType = PathFillType.evenOdd;
    var rect2 = Rect.fromLTRB(0 + w, 0 + w, x - w, y - w);
    path.addOval(rect2);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
