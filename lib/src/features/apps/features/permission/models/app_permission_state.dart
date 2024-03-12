import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_permission_state.freezed.dart';

@freezed
class NotificationPermissionState with _$NotificationPermissionState {
  const factory NotificationPermissionState({
    bool? isNotificationGranted,
    bool? isNotificationAccessGranted,
  }) = _NotificationPermissionState;
}
