import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/features/apps/apps.dart';

const rarelyUsedAppsParams = AppFilterParameter(
  sortType: SortType.screenTime,
  periodType: PeriodType.week,
  isRarelyUsed: true,
  isReversed: true,
);

const appDairyParams = AppFilterParameter(
  sortType: SortType.screenTime,
  periodType: PeriodType.week,
  isReversed: true,
);

const largeAppsParams = AppFilterParameter(
  sortType: SortType.size,
  appType: AppType.installed,
);

const unusedAppsParams = AppFilterParameter(
  periodType: PeriodType.week,
  sortType: SortType.unused,
);

const growingAppsParams = AppFilterParameter(
  sortType: SortType.sizeChange,
  appType: AppType.installed,
);

const systeamAppUnusedParams = AppFilterParameter(
  periodType: PeriodType.week,
  sortType: SortType.unused,
  appType: AppType.system,
);
