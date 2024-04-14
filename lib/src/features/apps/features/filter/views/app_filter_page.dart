import 'dart:math';
import 'package:phone_cleaner/router/router.dart';
import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/commons/widgets/items_and_select_action.dart';
import 'package:phone_cleaner/src/commons/widgets/loading.dart';
import 'package:phone_cleaner/src/features/apps/features/apps_consumption/controllers/battery_consumption_controller.dart';
import 'package:phone_cleaner/src/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:phone_cleaner/services/logger/logger.dart';
import 'package:phone_cleaner/src/commons/widgets/action_bottom_bar.dart';
import 'package:phone_cleaner/src/features/features.dart';

import '../../permission/controllers/notification_permission_controller.dart';

class AppFilterArguments {
  const AppFilterArguments({
    required this.appFilterParameter,
  });
  final AppFilterParameter appFilterParameter;
}

class AppFilterPage extends ConsumerStatefulWidget {
  const AppFilterPage({
    super.key,
    required this.args,
  });

  final AppFilterArguments args;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ListAppPageState();
}

class _ListAppPageState extends ConsumerState<AppFilterPage> {
  bool processAnimationRunning = true;
  @override
  void initState() {
    super.initState();
    ref
        .read(appFilterControllerProvider.notifier)
        .setParameters(widget.args.appFilterParameter);
  }

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    final isLoading = ref
        .watch(appFilterControllerProvider.select((value) => value.isLoading));
    if (isLoading || processAnimationRunning) {
      processAnimationRunning = true;
      return Loading(
        loop: isLoading,
        onStop: () => setState(() {
          processAnimationRunning = false;
        }),
      );
    }
    ref.listen(appFilterControllerProvider, (previous, next) {
      if (previous?.hasError == true) {
        return;
      }

      if (next.hasError) {
        appLogger.error('AppFilterPage Error', next.error, next.stackTrace);
        GoRouter.of(context).goNamed(AppRouter.error,
            extra: CleanerException(message: next.error));
      }
    });

    return Scaffold(
      backgroundColor: cleanerColor.neutral3,
      endDrawer: const AppFilterDrawer(),
      body: const Column(
        children: [
          _Header(),
          _ItemNumber(),
          Expanded(child: _AppDisplayPart())
        ],
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appFilterParameter = ref.watch(appFilterControllerProvider
        .select((value) => value.valueOrNull?.appFilterParameter));

    if (appFilterParameter == null) {
      return const SizedBox.shrink();
    }

    String filterLabel = '';
    String seperator = '';

    if (appFilterParameter.appType != AppType.all) {
      filterLabel += seperator + appFilterParameter.appType.description;
      seperator = ' / ';
    }

    filterLabel += seperator + appFilterParameter.sortType.description;
    seperator = ' / ';

    if (appFilterParameter.showType != ShowType.all) {
      filterLabel += seperator + appFilterParameter.showType.description;
      seperator = ' / ';
    }

    if (appFilterParameter.sortType == SortType.unused ||
        appFilterParameter.sortType == SortType.screenTime ||
        appFilterParameter.sortType == SortType.timeOpened) {
      filterLabel += seperator + appFilterParameter.periodType.description;
      seperator = '';
    }

    final sortButton = SizedBox(
      width: 40.0,
      height: 40.0,
      child: IconButton(
        onPressed: () =>
            ref.read(appFilterControllerProvider.notifier).toggleReverse(),
        icon: Transform.rotate(
          angle: appFilterParameter.isReversed ? pi : 0,
          child: const CleanerIcon(icon: CleanerIcons.sort),
        ),
      ),
    );

    return Column(
      children: [
        SecondaryAppBar(
          title: "All apps",
          trailing: sortButton,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 0, 0),
          child: FilterButton(filterLabel: filterLabel),
        ),
      ],
    );
  }
}

class _ItemNumber extends ConsumerWidget {
  const _ItemNumber();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAllChecked = ref.watch(appFilterControllerProvider
        .select((value) => value.valueOrNull?.isAllChecked));

    final appCount = ref.watch(appFilterControllerProvider
        .select((value) => value.valueOrNull?.appDataList.length));
    final totalSize = ref.watch(appFilterControllerProvider.select((value) =>
        value.valueOrNull?.appDataList.fold(0.kb,
            (previousValue, element) => previousValue + element.totalSize)));

    if (isAllChecked == null ||
        appCount == null ||
        totalSize == null ||
        appCount == 0) {
      appLogger.warning('Something is null in _ItemNumber');
      return const SizedBox.shrink();
    }

    return ItemsAndSelectAction(
        displayName: '$appCount Apps ',
        totalSize: totalSize,
        isAllChecked: isAllChecked,
        onPressed: () => ref
            .read(appFilterControllerProvider.notifier)
            .toggleAllAppsState());
  }
}

class _AppDisplayPart extends ConsumerWidget {
  const _AppDisplayPart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortType = ref.watch(appFilterControllerProvider
        .select((value) => value.valueOrNull?.appFilterParameter?.sortType));

    if (sortType == null) {
      return const SizedBox.shrink();
    }

    if (sortType == SortType.notification) return const _NotificationDisplay();
    if (sortType == SortType.batteryUse) return const _BatteryDisplay();
    if (sortType == SortType.sizeChange) return const _GrowingDisplay();
    return const _Display();
  }
}

class _NotificationDisplay extends ConsumerStatefulWidget {
  const _NotificationDisplay();

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      __NotificationDispalyState();
}

class __NotificationDispalyState extends ConsumerState<_NotificationDisplay>
    with WidgetsBindingObserver {
  NotificationPermissionController get notificationPermissionController =>
      ref.watch(notificationPermissionControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      notificationPermissionController.build();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      notificationPermissionController.checkPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(notificationPermissionControllerProvider);

    final isNotificationAccessGranted = ref
        .watch(notificationPermissionControllerProvider)
        .value
        ?.isNotificationAccessGranted;

    if (isNotificationAccessGranted == null) return const SizedBox.shrink();
    if (!isNotificationAccessGranted) {
      return UnavailableWidgetWithNoPermission(
        svgPath: 'assets/icons/app_filter_icon.svg',
        description:
            'Turn on Access Notification Permission to access notification usage.',
        onPressed: () {
          notificationPermissionController
              .requestAccessNotificationPermission();
        },
      );
    }

    return const _Display();
  }
}

class _BatteryDisplay extends ConsumerStatefulWidget {
  const _BatteryDisplay();

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      __BatteryDisplayState();
}

class __BatteryDisplayState extends ConsumerState<_BatteryDisplay>
    with WidgetsBindingObserver {
  NotificationPermissionController get notificationPermissionController =>
      ref.watch(notificationPermissionControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      notificationPermissionController.build();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      notificationPermissionController.checkPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNotificationGranted = ref
        .watch(notificationPermissionControllerProvider)
        .value
        ?.isNotificationGranted;
    if (isNotificationGranted == null) return const SizedBox.shrink();
    if (!isNotificationGranted) {
      return UnavailableWidgetWithNoPermission(
        svgPath: 'assets/icons/battery_boost.svg',
        description:
            "Turn on Background Operation notifications to monitor your battery.\nTo collect info about your battery, this app has to run in the background all the time.",
        onPressed: () {
          notificationPermissionController.requestNotificationPermission();
        },
      );
    }

    final timeRemaining = ref.watch(batteryConsumptionControllerProvider
        .select((value) => value.valueOrNull?.timeRemaining));

    if (timeRemaining == null) {
      return const SizedBox.shrink();
    }

    if (timeRemaining > 0) {
      return _AnalyzingWidget(
        timeRemaining: timeRemaining,
        description:
            "We are analyzing your battery usage data\nCome back later!",
        icon: CleanerIcons.batteryBoost,
      );
    }

    return const _Display();
  }
}

class _GrowingDisplay extends ConsumerWidget {
  const _GrowingDisplay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeRemaining =
        ref.watch(appsGrowingControllerProvider).value?.timeForAnalysis;

    if (timeRemaining == null) {
      return const SizedBox.shrink();
    }

    if (timeRemaining > 0) {
      return _AnalyzingWidget(
        timeRemaining: timeRemaining,
        description: "We are analyzing your growing data\nCome back later!",
        icon: CleanerIcons.appGrow,
      );
    }

    return const _Display();
  }
}

class _AnalyzingWidget extends StatelessWidget {
  const _AnalyzingWidget(
      {required this.timeRemaining,
      required this.icon,
      required this.description});

  final int timeRemaining;
  final String description;
  final CleanerIcons icon;

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;

    return Column(
      children: [
        const SizedBox(height: 56),
        CleanerIcon(icon: icon),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: regular12.copyWith(
              color: cleanerColor.neutral5,
            ),
          ),
        ),
        TimeRemaining(timeRemaining: timeRemaining),
      ],
    );
  }
}

class _Display extends ConsumerWidget {
  const _Display();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void onToggleAppState(int index) {
      ref.read(appFilterControllerProvider.notifier).toggleAppState(index);
    }

    final data = ref.watch(appFilterControllerProvider
        .select((value) => value.valueOrNull?.appDataList));

    if (data == null) {
      return const SizedBox.shrink();
    }

    if (data.isEmpty) {
      return const UnavailableDataWidget(
        svgPath: 'assets/icons/app_filter_icon.svg',
        description:
            'No matching app found\nChange the filter to see different results',
      );
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        ListView.builder(
          padding: const EdgeInsets.only(
              bottom: 90 + 16), // TODO: height of action botton bar
          itemCount: data.length,
          itemBuilder: (context, index) {
            return AppCheckboxItem(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              onTap: () {
                GoRouter.of(context).pushNamed(
                  AppRouter.appDetail,
                  extra: index,
                );
              },
              onCheckboxTap: () {
                onToggleAppState(index);
              },
              data: data[index],
            );
          },
        ),
        const _BottomBar(),
      ],
    );
  }
}

class _BottomBar extends ConsumerWidget {
  const _BottomBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkedApp = ref.watch(appFilterControllerProvider
        .select((value) => value.valueOrNull?.checkedApp));

    if (checkedApp == null) {
      return const SizedBox.shrink();
    }
    final checkedSize = checkedApp.fold(
        0.kb, ((previousValue, element) => previousValue + element.totalSize));
    final isIgnoreTypeView = ref.watch(
      appFilterControllerProvider.select((value) =>
          value.valueOrNull?.appFilterParameter?.appType == AppType.ignored),
    );

    return isIgnoreTypeView
        ? _buildStopIgnoreBottomBar(checkedApp, checkedSize, ref)
        : _buildActionBar(checkedApp, checkedSize, ref, context);
  }

  Widget _buildActionBar(List<AppCheckboxItemData> checkedApp,
      DigitalUnit checkedSize, WidgetRef ref, BuildContext context) {
    return ActionBottomBar(
      selectedCount: checkedApp.length,
      checkedSize: checkedSize,
      actions: [
        ActionButton(
          icon: const CleanerIcon(icon: CleanerIcons.navIgnore),
          title: 'Ignore',
          onPressed: () async {
            final packageNameList =
                checkedApp.map((e) => e.packageName).toList();
            await ref
                .read(appsControllerProvider.notifier)
                .saveAppsToIgnoredApps(packageNameList);
          },
        ),
        ActionButton(
          icon: const CleanerIcon(icon: CleanerIcons.navUninstall),
          title: 'Uninstall',
          onPressed: () async {
            GoRouter.of(context).pushNamed(AppRouter.uninstallApp,
                extra: UninstallAppArguments(appUninstall: checkedApp));
            appLogger.info('Remove app success');
          },
        )
      ],
    );
  }

  Widget _buildStopIgnoreBottomBar(List<AppCheckboxItemData> checkedApp,
      DigitalUnit checkedSize, WidgetRef ref) {
    return ActionBottomBar(
      selectedCount: checkedApp.length,
      checkedSize: checkedSize,
      actions: [
        ActionButton(
          icon: const CleanerIcon(icon: CleanerIcons.navIgnore),
          isExpanded: true,
          title: 'Stop Ignore',
          onPressed: () async {
            final packageNameList =
                checkedApp.map((e) => e.packageName).toList();
            await ref
                .read(appsControllerProvider.notifier)
                .removeAppsFromIgnoredApps(packageNameList);
          },
        ),
      ],
    );
  }
}
