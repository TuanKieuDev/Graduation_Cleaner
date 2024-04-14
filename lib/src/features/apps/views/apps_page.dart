import 'dart:ui';
import 'package:phone_cleaner/src/commons/widgets/lottie_looper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:phone_cleaner/router/router.dart';
import 'package:phone_cleaner/services/logger/logger.dart';
import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/features/apps/features/boost_performance/views/boost_performance.dart';
import 'package:phone_cleaner/src/features/apps/features/notification/views/notification.dart';
import 'package:phone_cleaner/src/features/features.dart';
import 'package:phone_cleaner/src/themes/themes.dart';
import 'package:go_router/go_router.dart';

class AppsPage extends ConsumerStatefulWidget {
  const AppsPage({super.key});

  @override
  ConsumerState<AppsPage> createState() => _AppsPageState();
}

class _AppsPageState extends ConsumerState<AppsPage> {
  late ScrollController _scrollController;

  bool _loadingAnimationRunning = true;

  Function(AsyncValue? previous, AsyncValue next) logOnError({
    bool isGoToErrorPage = false,
  }) =>
      (previous, next) {
        if (previous?.hasError == true) {
          return;
        }

        if (next.hasError) {
          appLogger.error('Apps Page Error', next.error, next.stackTrace);
          if (isGoToErrorPage) {
            GoRouter.of(context).goNamed(AppRouter.error,
                extra: CleanerException(message: next.error));
          }
        }
      };

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

  @override
  Widget build(BuildContext context) {
    final isAppsLoading =
        ref.watch(appsControllerProvider.select((value) => value.isLoading));
    final isAppsConsumptionLoading = ref.watch(
        appsConsumptionControllerProvider.select((value) => value.isLoading));
    final isAppsUsageLoading = ref
        .watch(appsUsageControllerProvider.select((value) => value.isLoading));
    final isAppsGrowingLoading = ref.watch(
        appsGrowingControllerProvider.select((value) => value.isLoading));

    bool isLoading = isAppsLoading ||
        isAppsConsumptionLoading ||
        isAppsUsageLoading ||
        isAppsGrowingLoading;

    if (isLoading || _loadingAnimationRunning) {
      _loadingAnimationRunning = true;

      return LottieLooper(
        'assets/lotties/app_loading.json',
        loop: isLoading,
        onStop: () {
          setState(() => _loadingAnimationRunning = false);
        },
      );
    }

    final cleanerColor = CleanerColor.of(context)!;

    ref.listen(appsControllerProvider, logOnError(isGoToErrorPage: true));
    ref.listen(appsGrowingControllerProvider, logOnError());
    ref.listen(appsUsageControllerProvider, logOnError());
    ref.listen(appsConsumptionControllerProvider, logOnError());

    return Scaffold(
      backgroundColor: cleanerColor.neutral3,
      body: Stack(
        children: [
          ScrollableBackground(scrollController: _scrollController),
          SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: const _DetailContent(),
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
      if (mounted) {
        setState(() {
          _alpha = newAlpha;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SecondaryAppBar(
      title: "Apps",
      titleOpacity: _alpha,
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _MainContent(),
          AppsConsumption(),
          // Center(
          //     child: NativeAd(
          //   padding: EdgeInsets.only(
          //     top: 24,
          //     bottom: 12,
          //   ),
          // )),
          AppsUsage(padding: EdgeInsets.symmetric(vertical: 12.0)),
          BoostPerformance(padding: EdgeInsets.symmetric(vertical: 12.0)),
          AppsGrowing(padding: EdgeInsets.symmetric(vertical: 12.0)),
          NotificationPart(),
        ],
      ),
    );
  }
}

class _MainContent extends ConsumerWidget {
  const _MainContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceMemory =
        ref.read(overallSystemControllerProvider).value!.totalSpace;
    final data = ref.watch(appsControllerProvider).requireValue;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            flex: 110,
            child: CustomPaint(
              painter: AppCircle(
                systemApp: data.systemAppsSize.value.toInt(),
                installedApp: data.installedAppsSize.value.toInt(),
              ),
              child: SizedBox(
                width: 110,
                height: 110,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      (data.systemAppsSize + data.installedAppsSize)
                          .toStringOptimal(),
                      style: semibold14.copyWith(
                        color: CleanerColor.of(context)!.primary10,
                      ),
                    ),
                    Text(
                      "${((data.totalAppsSize.to(DigitalUnitSymbol.byte).value / deviceMemory.value) * 100).toStringAsFixed(0)}% capacity",
                      style: const TextStyle(fontSize: 10),
                    ),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _AppTile(
                  type: AppType.system,
                  numberOfItems: data.systemApps.length,
                  size: data.systemAppsSize,
                ),
                _AppTile(
                  type: AppType.installed,
                  numberOfItems: data.installedApps.length,
                  size: data.installedAppsSize,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _AppTile extends StatelessWidget {
  const _AppTile({
    Key? key,
    required this.type,
    required this.numberOfItems,
    required this.size,
  }) : super(key: key);

  final AppType type;
  final int numberOfItems;
  final DigitalUnit size;

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;

    return TextButton(
      onPressed: () {
        GoRouter.of(context).pushNamed(
          AppRouter.listApp,
          extra: AppFilterArguments(
            appFilterParameter: AppFilterParameter(
              appType: type,
              sortType: SortType.size,
            ),
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: (type == AppType.system)
                    ? SvgPicture.asset('assets/icons/ic_apps/system.svg')
                    : SvgPicture.asset('assets/icons/ic_apps/installed.svg'),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                        text: "$numberOfItems ",
                        style: semibold18.copyWith(
                          color: cleanerColor.primary10,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: type.description,
                            style: regular14.copyWith(
                                color: cleanerColor.primary10),
                          ),
                        ]),
                  ),
                  Text(
                    size.toStringOptimal(),
                    style: regular12.copyWith(color: cleanerColor.neutral5),
                  ),
                ],
              ),
            ],
          ),
          Icon(
            Icons.navigate_next,
            color: cleanerColor.primary7,
          )
        ],
      ),
    );
  }
}
