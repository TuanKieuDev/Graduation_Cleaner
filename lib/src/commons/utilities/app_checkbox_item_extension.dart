import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:duration/duration.dart';
import 'package:intl/intl.dart';

import '../../features/apps/models/app_specific_type.dart';
import '../../features/apps/models/models.dart';

extension AppCheckoxItemExtension on AppCheckboxItemData {
  String get subValue {
    if (specificType != null) {
      switch (specificType) {
        case AppSpecificType.app:
          return appSize.toStringOptimal();
        case AppSpecificType.data:
          return dataSize.toStringOptimal();
        case AppSpecificType.cache:
          return cacheSize.toStringOptimal();
        default:
          return totalSize.toStringOptimal();
      }
    }
    switch (sortType) {
      case SortType.size:
        return totalSize.toStringOptimal();
      case SortType.sizeChange:
        return sizeChange.value >= 0
            ? '+${sizeChange.toStringOptimal()}'
            : '-${sizeChange.value.abs().bytes.toStringOptimal()}';
      case SortType.name:
        return name;
      case SortType.screenTime:
        return printDuration(Duration(milliseconds: totalTimeSpent));
      case SortType.batteryUse:
        return "${batteryPercentage.round()}%";
      case SortType.dataUse:
        return dataUsed.toStringOptimal();
      case SortType.notification:
        return notificationCount.toString();
      case SortType.lastUsed:
        if (lastOpened != DateTime(1970, 1, 1, 8)) {
          return DateFormat('HH:mm, dd/MM/yyy ').format(
            lastOpened!,
          );
        }
        return 'Unused';

      case SortType.timeOpened:
        return timeOpened.toString();
      case SortType.unused:
        return 'Unused';
    }
  }
}
