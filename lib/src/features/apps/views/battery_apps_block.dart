import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone_cleaner/src/features/apps/apps.dart';

import '../../../commons/commons.dart';
import '../features/permission/controllers/notification_permission_controller.dart';

class BatteryAppsBlock extends ConsumerStatefulWidget {
  const BatteryAppsBlock({
    super.key,
    required this.iconsData,
    required this.size,
    required this.sortType,
    required this.periodType,
    required this.showBadge,
  });

  final List<AppCheckboxItemData> iconsData;
  final String size;
  final SortType sortType;
  final PeriodType periodType;
  final bool showBadge;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BatteryAppsBlockState();
}

class _BatteryAppsBlockState extends ConsumerState<BatteryAppsBlock>
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

    return AppsBlock(
        isNotificationGranted: isNotificationGranted,
        iconsData: widget.iconsData,
        size: widget.size,
        sortType: widget.sortType,
        showBadge: widget.showBadge,
        periodType: widget.periodType);
  }
}
