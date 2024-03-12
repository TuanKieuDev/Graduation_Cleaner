import 'dart:ui';
import 'package:device_info/device_info.dart';
import 'package:phone_cleaner/router/router.dart';
import 'package:phone_cleaner/services/logger/logger.dart';
import 'package:phone_cleaner/services/work_manager/work_manager_services.dart';
import 'package:phone_cleaner/src/features/features.dart';
import 'package:phone_cleaner/src/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:monetization/monetization.dart';
import '../../../../commons/commons.dart';

const horizontalPadding = 16.0;

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with WidgetsBindingObserver {
  PermissionController get permissionController =>
      ref.watch(permissionControllerProvider.notifier);

  RefreshDataController get refreshDataController =>
      ref.read(refreshDataControllerProvider.notifier);

  bool _isFirstLoading = true;
  bool _isAdOpenShowed = false;
  bool _waitForAnimation = true;

  Function(AsyncValue? previous, AsyncValue next) logOnError() =>
      (previous, next) {
        if (previous?.hasError == true) {
          return;
        }

        if (next.hasError) {
          appLogger.error('HomePage Error', next.error, next.stackTrace);
          GoRouter.of(context).goNamed(AppRouter.error,
              extra: CleanerException(message: 'HomePage Error'));
        }
      };

  @override
  void initState() {
    super.initState();

    executedWorkTask();

    var adLoadedSubscription = AdManager.instance.adLoaded.listen((adType) {
      if (adType == AdType.appOpen && !_isAdOpenShowed) {
        AdManager.instance.showAdOpen();
      }
    });

    var adShownSubscription = AdManager.instance.adShowedStream.listen((event) {
      if (event == AdType.appOpen) {
        _isAdOpenShowed = true;
      }
    });

    Future.delayed(const Duration(seconds: 7), () async {
      setState(() {
        _isFirstLoading = false;
      });
      adLoadedSubscription.cancel();
      adShownSubscription.cancel();
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        _waitForAnimation = false;
      });
    });

    AppManager().runBatteryAnalysisService();

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      permissionController.build();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      permissionController.checkPermission();
      refreshDataController.refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Build HomePage');
    ref.watch(permissionControllerProvider);

    if (ref.exists(overallSystemControllerProvider)) {
      ref.listen(overallSystemControllerProvider, logOnError());
    }

    if (ref.exists(appsControllerProvider)) {
      ref.listen(appsControllerProvider, logOnError());
    }

    if (ref.exists(fileCacheControllerProvider)) {
      ref.listen(fileCacheControllerProvider, logOnError());
    }

    if (ref.exists(savingTipsControllerProvider)) {
      ref.listen(savingTipsControllerProvider, logOnError());
    }

    final cleanerColor = CleanerColor.of(context)!;
    if (_isFirstLoading || _waitForAnimation) {
      return Scaffold(
        backgroundColor: cleanerColor.neutral3,
        body: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuad,
          opacity: _isFirstLoading ? 1 : 0,
          child: const HomeLoading(),
        ),
      );
    }
    return Scaffold(
      // drawer: const TabDrawer(),
      // endDrawer: const SettingDrawer(),
      backgroundColor: cleanerColor.neutral3,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            // width: constraints.maxWidth,
            // height: constraints.maxHeight,
            color: cleanerColor.neutral3,
            child: OpacityTweener(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutQuad,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsetsDirectional.zero,
                    child: Stack(
                      children: [
                        const Background(),
                        Padding(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).viewPadding.top,
                          ),
                          child: Column(
                            children: const [
                              _Header(),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: horizontalPadding),
                                child: OverallSystemInformation(),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: horizontalPadding),
                                child: NativeAd(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // const _DrawerButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Align(
        alignment: Alignment.topLeft,
        child: GradientText(
          'Cleaner',
          style: bold24,
          gradient: CleanerColor.of(context)!.gradient1,
        ),
      ),
    );
  }
}

class _DrawerButton extends StatelessWidget {
  const _DrawerButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    return Positioned(
      top: MediaQuery.of(context).viewPadding.top + 5,
      right: 16,
      child: Stack(
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: const SizedBox(
                  height: 40,
                  width: 96,
                ),
              )),
          Container(
            width: 96,
            height: 40,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: cleanerColor.neutral3.withAlpha(204),
                // color: cleanerColor.neutral3,
                boxShadow: const [
                  BoxShadow(
                    offset: Offset(2, 2),
                    blurRadius: 30,
                    color: Color.fromRGBO(66, 133, 244, 0.2),
                  )
                ]),
            child: Row(
              children: [
                IconButton(
                  icon: CleanerIcons.menu.toWidget(fit: BoxFit.scaleDown),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
                IconButton(
                  icon: CleanerIcons.setting.toWidget(fit: BoxFit.scaleDown),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
