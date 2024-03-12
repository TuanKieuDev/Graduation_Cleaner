import 'package:phone_cleaner/src/commons/models/models.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../features.dart';

part 'notification_count_info.freezed.dart';

@freezed
class NotificationCountInfo with _$NotificationCountInfo {
  const NotificationCountInfo._();

  const factory NotificationCountInfo({
    @Default([]) List<AppCheckboxItemData> dataWithNotificationWeekly,
    List<BarChartData>? barChartData,
  }) = _NotificationCountInfo;
  int get totalNotificationWeekly => dataWithNotificationWeekly.fold(
      0, (previousValue, element) => previousValue + element.notificationCount);
}
