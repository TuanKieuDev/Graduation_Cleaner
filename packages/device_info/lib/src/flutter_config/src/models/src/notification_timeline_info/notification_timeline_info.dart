import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_timeline_info.freezed.dart';
part 'notification_timeline_info.g.dart';

@freezed
class NotificationTimelineInfo with _$NotificationTimelineInfo {
  const NotificationTimelineInfo._();

  const factory NotificationTimelineInfo({
    required DateTime dateTime,
    required int notificationQuantity,
  }) = _NotificationTimelineInfo;

  factory NotificationTimelineInfo.fromJson(Map<String, dynamic> json) =>
      _$NotificationTimelineInfoFromJson(json);
}
