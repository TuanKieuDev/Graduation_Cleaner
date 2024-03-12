// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';
import 'package:duration/duration.dart';
import 'package:phone_cleaner/src/features/apps/features/apps_consumption/controllers/battery_consumption_controller.dart';
import 'package:device_apps/device_apps.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:phone_cleaner/services/logger/logger.dart';
import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/features/features.dart';
import 'package:phone_cleaner/src/themes/themes.dart';

import '../../../../../../router/router.dart';
import '../../apps_usage/views/bar_chart.dart';

class AppDetail extends ConsumerStatefulWidget {
  const AppDetail({
    super.key,
    required this.index,
  });

  final int index;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AppDetailState();
}

class _AppDetailState extends ConsumerState<AppDetail> {
  late PageController pageController;
  late ScrollController scrollController;
  late double pageOffset;
  late double iconSize = MediaQuery.of(context).size.width / 6;

  @override
  void initState() {
    super.initState();
    pageOffset = widget.index.toDouble();
    pageController = PageController(
      initialPage: widget.index,
    )..addListener(() {
        setState(() {
          pageOffset = pageController.page!;
        });
      });

    scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      iconSize = _getIconSize(context);
      scrollController.jumpTo(iconSize * widget.index);
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  double _getIconSize(BuildContext context) {
    return MediaQuery.of(context).size.width / 6;
  }

  Function(AsyncValue? previous, AsyncValue next) goToErrorPageOnError() =>
      (previous, next) {
        if (previous?.hasError == true) {
          return;
        }

        if (next.hasError) {
          appLogger.error('App Detail Error', next.error, next.stackTrace);
          GoRouter.of(context).goNamed(AppRouter.error,
              extra: CleanerException(message: next.error));
        }
      };
  @override
  Widget build(BuildContext context) {
    ref.listen(appFilterControllerProvider, (previous, next) {
      if (previous?.hasError == true) {
        return;
      }

      if (next.hasError) {
        appLogger.error('App Filter Error', next.error, next.stackTrace);
      }
    });

    ref.listen(appsUsageControllerProvider, (previous, next) {
      if (previous?.hasError == true) {
        return;
      }

      if (next.hasError) {
        appLogger.error('App Usage Error', next.error, next.stackTrace);
      }
    });

    final cleanerColor = CleanerColor.of(context)!;
    final itemSize = iconSize;
    return Scaffold(
      backgroundColor: cleanerColor.neutral3,
      body: Column(
        children: [
          const SecondaryAppBar(title: ""),
          Stack(
            children: [
              _Masked(itemSize: itemSize),
              _AppDetail(
                scrollController: scrollController,
                pageController: pageController,
                itemSize: itemSize,
              ),
              _AppIconList(
                scrollController: scrollController,
                pageController: pageController,
                pageOffset: pageOffset,
                itemSize: itemSize,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AppIconList extends ConsumerWidget {
  const _AppIconList({
    Key? key,
    required this.scrollController,
    required this.pageController,
    required this.pageOffset,
    required this.itemSize,
  }) : super(key: key);

  final ScrollController scrollController;
  final PageController pageController;

  final double pageOffset;
  final double itemSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appData = ref.watch(appFilterControllerProvider
            .select((value) => value.valueOrNull?.appDataList)) ??
        [];
    return SizedBox(
      height: itemSize + 10,
      child: ListView.builder(
          padding:
              EdgeInsets.symmetric(horizontal: itemSize * 2.5, vertical: 5),
          scrollDirection: Axis.horizontal,
          controller: scrollController,
          itemCount: appData.length,
          itemBuilder: (context, index) {
            double scale = max(0.5, (1 - (pageOffset - index).abs()));
            return Transform.scale(
              scale: scale,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(66, 133, 244, 0.3),
                      blurRadius: 2,
                    )
                  ],
                ),
                child: Stack(
                  children: [
                    Container(
                      width: itemSize,
                      height: itemSize,
                      decoration: BoxDecoration(
                        color: CleanerColor.of(context)!.neutral3,
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        pageController.jumpToPage(index);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.memory(
                          appData[index].iconData!,
                          width: itemSize,
                          height: itemSize,
                          cacheHeight: (itemSize *
                                  MediaQuery.of(context).devicePixelRatio)
                              .toInt(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

      // child: ScrollSnapList(
      //   // scrollPhysics: const PageScrollPhysics(),
      //   listController: scrollController,
      //   itemBuilder: (context, index) {
      //     double scale = max(0.5, (1 - (pageOffset - index).abs()));
      //     return Transform.scale(
      //       scale: scale,
      //       child: Container(
      //         decoration: const BoxDecoration(
      //           shape: BoxShape.circle,
      //           boxShadow: [
      //             BoxShadow(
      //               color: Color.fromRGBO(66, 133, 244, 0.3),
      //               blurRadius: 2,
      //             )
      //           ],
      //         ),
      //         child: Stack(
      //           children: [
      //             Container(
      //               width: itemSize,
      //               height: itemSize,
      //               decoration: BoxDecoration(
      //                 color: CleanerColor.of(context)!.neutral3,
      //                 borderRadius: BorderRadius.circular(50),
      //               ),
      //             ),
      //             GestureDetector(
      //               onTap: () {
      //                 scrollController.animateTo(
      //                   index * itemSize,
      //                   duration: const Duration(milliseconds: 300),
      //                   curve: Curves.easeInOut,
      //                 );
      //                 pageController.animateTo(
      //                   index * MediaQuery.of(context).size.width,
      //                   duration: const Duration(milliseconds: 300),
      //                   curve: Curves.easeInOut,
      //                 );
      //               },
      //               child: ClipRRect(
      //                 borderRadius: BorderRadius.circular(50),
      //                 child: Image.memory(
      //                   appData[index].iconData!,
      //                   width: itemSize,
      //                   height: itemSize,
      //                 ),
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //     );
      //   },
      //   itemCount: appData.length,
      //   itemSize: itemSize,
      //   onItemFocus: (value) {
      //     pageController.animateTo(
      //       value * MediaQuery.of(context).size.width,
      //       duration: const Duration(milliseconds: 300),
      //       curve: Curves.easeInOut,
      //     );
      //   },
      // ),
    );
  }
}

class _Masked extends StatelessWidget {
  const _Masked({
    Key? key,
    required this.itemSize,
  }) : super(key: key);

  final double itemSize;

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    return Container(
      margin: EdgeInsets.only(
        top: itemSize + 10,
      ),
      height: 200,
      width: double.maxFinite,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: cleanerColor.primary6.withOpacity(0.5),
            blurRadius: 8,
          )
        ],
      ),
    );
  }
}

class _AppDetail extends ConsumerWidget {
  const _AppDetail({
    Key? key,
    required this.scrollController,
    required this.pageController,
    required this.itemSize,
  }) : super(key: key);

  final ScrollController scrollController;
  final PageController pageController;
  final double itemSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appData = ref.watch(appFilterControllerProvider
            .select((value) => value.valueOrNull?.appDataList)) ??
        [];
    final cleanerColor = CleanerColor.of(context)!;
    return SizedBox(
      width: double.maxFinite,
      height: MediaQuery.of(context).size.height - itemSize - appBarHeight + 20,
      child: PageView.builder(
          onPageChanged: (value) {
            scrollController.animateTo(
              value * itemSize,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          controller: pageController,
          scrollDirection: Axis.horizontal,
          itemCount: appData.length,
          itemBuilder: (context, index) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onTap: () {
                    scrollController.animateTo(
                      index * itemSize,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                      top: itemSize + 10,
                    ),
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      color: cleanerColor.neutral3,
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      child: Column(
                        children: [
                          Text(
                            appData[index].name,
                            style:
                                bold20.copyWith(color: cleanerColor.primary10),
                          ),
                          _Storage(
                            data: appData[index],
                            padding: const EdgeInsets.only(top: 12, bottom: 8),
                          ),
                          _Growing(
                            data: appData[index],
                            padding: const EdgeInsets.only(top: 8, bottom: 12),
                          ),
                          _ShowAppInfoButton(
                            packageName: appData[index].packageName,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          _Usage(
                            data: appData[index],
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          const NativeAd(
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          _DrainImpact(
                            data: appData[index],
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          LayoutBuilder(builder: (context, constraints) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  PrimaryButton(
                                    onPressed: () async {
                                      DeviceApps.openApp(
                                          appData[index].packageName);
                                    },
                                    title: const Text("Open app"),
                                    borderRadius: BorderRadius.circular(16),
                                    width: constraints.maxWidth / 2 - 8,
                                    height: 40,
                                  ),
                                  PrimaryButton(
                                    onPressed: () {
                                      GoRouter.of(context)
                                          .pushNamed(AppRouter.toBeUpdated);
                                    },
                                    title: const Text("Force stop"),
                                    borderRadius: BorderRadius.circular(16),
                                    width: constraints.maxWidth / 2 - 8,
                                    height: 40,
                                  ),
                                ],
                              ),
                            );
                          }),
                          SecondaryButton(
                            title: "Uninstall",
                            onPressed: () {
                              GoRouter.of(context).pushReplacement(
                                AppRouter.uninstallApp,
                                extra: UninstallAppArguments(
                                  appUninstall: [appData[index]],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
    );
  }
}

class _Storage extends StatelessWidget {
  const _Storage({
    Key? key,
    required this.data,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final AppCheckboxItemData data;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Storage",
                  style: semibold18.copyWith(color: cleanerColor.primary10),
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomPaint(
                    painter: CircleBreak(
                      appSize: data.appSize,
                      dataSize: data.dataSize,
                      cacheSize: data.cacheSize,
                      gradientApp: cleanerColor.gradient1,
                      gradientData: cleanerColor.gradient2,
                      gradientCache: cleanerColor.gradient3,
                    ),
                    child: SizedBox(
                      width: constraints.maxWidth / 3,
                      height: constraints.maxWidth / 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            data.totalSize.toStringOptimal(),
                            style: bold18.copyWith(
                              color: cleanerColor.primary10,
                            ),
                          ),
                          Text(
                            "Total",
                            style: regular16,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _AppSizeTile(
                        label: 'App',
                        color: cleanerColor.gradient1,
                        size: data.appSize,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      _AppSizeTile(
                        label: 'Data',
                        color: cleanerColor.gradient2,
                        size: data.dataSize,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      _AppSizeTile(
                        label: 'Cache',
                        color: cleanerColor.gradient3,
                        size: data.cacheSize,
                      ),
                    ],
                  )
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AppSizeTile extends StatelessWidget {
  const _AppSizeTile({
    Key? key,
    required this.label,
    required this.color,
    required this.size,
  }) : super(key: key);

  final String label;
  final Gradient color;
  final DigitalUnit size;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      GradientText(label, gradient: color),
      Container(
        width: 8,
        height: 8,
        margin: const EdgeInsets.symmetric(
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: color,
        ),
      ),
      SizedBox(
        width: 80,
        child: Align(
          alignment: Alignment.centerLeft,
          child: GradientText(
            size.toStringOptimal(),
            gradient: color,
          ),
        ),
      )
    ]);
  }
}

class _Growing extends ConsumerWidget {
  const _Growing({
    Key? key,
    required this.data,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final AppCheckboxItemData data;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cleanerColor = CleanerColor.of(context)!;
    var value = ref.watch(
        appsGrowingControllerProvider.select((value) => value.valueOrNull));

    if (value == null) {
      return const CircularProgressIndicator();
    }
    final timeRemaining = value.timeForAnalysis;
    final sizeChange = value.growingData
        .where((element) => element.name == data.name)
        .first
        .sizeChange;

    // if (timeRemaining > 0 || sizeChange == const DigitalUnit.fromByte(0)) {
    //   return const SizedBox.shrink();
    // }

    return Padding(
      padding: padding,
      child: Column(
        children: [
          Text(
            "Change last 7 days",
            style: regular16.copyWith(
              color: cleanerColor.primary10,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          GrowingApp(
            isCenter: true,
            size: sizeChange,
            iconData: data.iconData ?? Uint8List(0),
          ),
        ],
      ),
    );
  }
}

class _ShowAppInfoButton extends StatelessWidget {
  const _ShowAppInfoButton(
      {required this.packageName, this.padding = EdgeInsets.zero});

  final String packageName;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SecondaryButton(
        title: "Show app info",
        onPressed: () {
          DeviceApps.openAppSettings(packageName);
        },
      ),
    );
  }
}

class _Usage extends ConsumerStatefulWidget {
  const _Usage({
    Key? key,
    required this.data,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final AppCheckboxItemData data;
  final EdgeInsets padding;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UsageState();
}

class _UsageState extends ConsumerState<_Usage> {
  List<List<BarChartData>> barChartData = [];
  // List<AppInfoUsage> usageData = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, getUsageData);
  }

  Future<void> getUsageData() async {
    final dataWeekly = ref
        .read(appsUsageControllerProvider.notifier)
        .getAppBarChartData(UsagePeriod.week, widget.data.packageName);
    final dataDaily = ref
        .read(appsUsageControllerProvider.notifier)
        .getAppBarChartData(UsagePeriod.day, widget.data.packageName);
    Future.wait([dataWeekly, dataDaily]).then((value) {
      setState(() {
        barChartData = value;
      });
    });
  }

  bool isDataDaily = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    final usageData = ref.watch(
        appsUsageControllerProvider.select((value) => value.valueOrNull));
    if (usageData == null || barChartData.isEmpty) {
      return const SizedBox.shrink();
    }

    final data = isDataDaily ? barChartData[1] : barChartData[0];

    var timeSpentDuration = printDuration(
      Duration(
          milliseconds: usageData[isDataDaily ? 1 : 0]
              .usageData
              .where(
                  (element) => element.packageName == widget.data.packageName)
              .first
              .totalTimeSpent),
      abbreviated: true,
    );
    return Padding(
      padding: widget.padding,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Usage",
                style: semibold18.copyWith(color: cleanerColor.primary10),
              ),
              TimeSwitch(
                value: isDataDaily,
                onChanged: (value) {
                  setState(() {
                    isDataDaily = !isDataDaily;
                    isLoading = true;
                  });
                },
                onComplete: () {
                  setState(() {
                    isLoading = false;
                  });
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: AnimatedOpacity(
              opacity: isLoading ? 0 : 1,
              curve: Curves.easeOutQuad,
              duration: const Duration(milliseconds: 500),
              child: SizedBox(
                height:
                    data.any((element) => element.y > 0) ? barChartHeight : 0,
                child: BarChartUsage(
                  barChartData: isLoading
                      ? data.map((e) => e.copyWith(y: 0)).toList()
                      : data,
                  isDataDaily: isDataDaily,
                ),
              ),
            ),
          ),
          _UsageImpactTile(
            icon: const CleanerIcon(icon: CleanerIcons.totalTime),
            padding: const EdgeInsets.symmetric(vertical: 8),
            title: "Total time spent",
            trailing: timeSpentDuration,
          ),
          _UsageImpactTile(
            icon: const CleanerIcon(icon: CleanerIcons.lastOpened),
            padding: const EdgeInsets.symmetric(vertical: 8),
            title: "Time opened",
            trailing: usageData[isDataDaily ? 1 : 0]
                .usageData
                .where(
                    (element) => element.packageName == widget.data.packageName)
                .first
                .timeOpened
                .toString(),
          ),
        ],
      ),
    );
  }
}

class _UsageImpactTile extends StatelessWidget {
  const _UsageImpactTile({
    Key? key,
    required this.icon,
    required this.padding,
    required this.title,
    required this.trailing,
  }) : super(key: key);

  final CleanerIcon icon;
  final EdgeInsets padding;
  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              icon,
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(color: cleanerColor.primary10),
              ),
            ],
          ),
          Row(
            children: [
              Text(trailing),
            ],
          ),
        ],
      ),
    );
  }
}

class SnapScrollSize extends ScrollPhysics {
  const SnapScrollSize({super.parent, required this.snapSize});

  final double snapSize;

  @override
  SnapScrollSize applyTo(ScrollPhysics? ancestor) {
    return SnapScrollSize(parent: buildParent(ancestor), snapSize: snapSize);
  }

  double _getPage(ScrollMetrics position) {
    return position.pixels / snapSize;
  }

  double _getPixels(ScrollMetrics position, double page) {
    return page * snapSize;
  }

  double _getTargetPixels(
      ScrollMetrics position, Tolerance tolerance, double velocity) {
    double page = _getPage(position);
    if (velocity < -tolerance.velocity) {
      page -= 0.5;
    } else if (velocity > tolerance.velocity) {
      page += 0.5;
    }
    return _getPixels(position, page.roundToDouble());
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    // If we're out of range and not headed back in range, defer to the parent
    // ballistics, which should put us back in range at a page boundary.
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final Tolerance tolerance = this.tolerance;
    final double target = _getTargetPixels(position, tolerance, velocity);
    if (target != position.pixels) {
      return ScrollSpringSimulation(spring, position.pixels, target, velocity,
          tolerance: tolerance);
    }
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}

class SnapScrollPhysics extends ScrollPhysics {
  const SnapScrollPhysics({super.parent, required this.snapSize});

  final double snapSize;

  @override
  SnapScrollSize applyTo(ScrollPhysics? ancestor) {
    return SnapScrollSize(parent: buildParent(ancestor), snapSize: snapSize);
  }

  double _getPage(ScrollMetrics position) {
    return position.pixels / snapSize;
  }

  double _getPixels(ScrollMetrics position, double page) {
    return page * snapSize;
  }

  double _getTargetPixels(
      ScrollMetrics position, Tolerance tolerance, double velocity) {
    double page = _getPage(position);
    if (velocity < -tolerance.velocity) {
      page -= 0.5;
    } else if (velocity > tolerance.velocity) {
      page += 0.5;
    }
    return _getPixels(position, page.roundToDouble());
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    // If we're out of range and not headed back in range, defer to the parent
    // ballistics, which should put us back in range at a page boundary.
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final Tolerance tolerance = this.tolerance;
    final double target = _getTargetPixels(position, tolerance, velocity);
    if (target != position.pixels) {
      return ScrollSpringSimulation(spring, position.pixels, target, velocity,
          tolerance: tolerance);
    }
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}

class _DrainImpact extends ConsumerWidget {
  const _DrainImpact({
    Key? key,
    required this.data,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final AppCheckboxItemData data;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cleanerColor = CleanerColor.of(context)!;
    final timeRemaining = ref
        .read(batteryConsumptionControllerProvider)
        .valueOrNull
        ?.timeRemaining;
    return Padding(
      padding: padding,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Drain impact",
              style: semibold18.copyWith(color: cleanerColor.primary10),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          _UsageImpactTile(
            icon: const CleanerIcon(icon: CleanerIcons.data),
            padding: const EdgeInsets.symmetric(vertical: 8),
            title: "Data",
            trailing: data.dataUsed.toStringOptimal(),
          ),
          _UsageImpactTile(
            icon: const CleanerIcon(icon: CleanerIcons.battery),
            padding: const EdgeInsets.symmetric(vertical: 8),
            title: "Battery",
            trailing: (timeRemaining == null || timeRemaining > 0)
                ? '-'
                : "${data.batteryPercentage.round()}%",
          ),
        ],
      ),
    );
  }
}
