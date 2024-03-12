import 'package:app_settings/app_settings.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../../main.dart';
import '../models/app_permission_state.dart';

part 'notification_permission_controller.g.dart';

@riverpod
class NotificationPermissionController
    extends _$NotificationPermissionController {
  @override
  FutureOr<NotificationPermissionState> build() async {
    final isNotificationAccessGranted =
        await AppSettings.checkNotificationListenerPermissions();
    final isNotificationGranted = await Permission.notification.isGranted;
    if (isNotificationGranted) {
      ref.read(appRepository).runBatteryAnalysisService();
    }
    return NotificationPermissionState(
      isNotificationGranted: isNotificationGranted,
      isNotificationAccessGranted: isNotificationAccessGranted,
    );
  }

  Future<void> checkPermission() async {
    final isNotificationAccessGranted =
        await AppSettings.checkNotificationListenerPermissions();
    final isNotificationGranted = await Permission.notification.isGranted;
    if (isNotificationGranted) {
      ref.read(appRepository).runBatteryAnalysisService();
    }
    state = AsyncData(NotificationPermissionState(
      isNotificationGranted: isNotificationGranted,
      isNotificationAccessGranted: isNotificationAccessGranted,
    ));
  }

  Future<void> requestAccessNotificationPermission() async {
    await AppSettings.openNotificationSettings();
  }

  Future<void> requestNotificationPermission() async {
    await NotificationPermissions.requestNotificationPermissions();
  }
}
