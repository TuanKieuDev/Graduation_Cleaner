import 'package:phone_cleaner/services/notifications/notification_services.dart';
import 'package:phone_cleaner/services/work_manager/work_task.dart';
import 'package:phone_cleaner/services/work_manager/work_task_manager.dart';
import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:device_info/device_info.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void workManagerInitialize() {
  Workmanager().initialize(
    _callbackDispatcher,
    // isInDebugMode: true,
  );
}

@pragma('vm:entry-point')
void _callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case WorkTask.cleanJunk:
        await _showJunkCleaningNotifications();
        break;
      case WorkTask.lowStorage:
        await _showLowStorageNotifications();
        break;
      case WorkTask.unusedApps:
        await _showUnusedAppsNotificaions();
        break;
      case WorkTask.batteryDrainers:
        await _showBatteryDrainersNotifications();
        break;
      case WorkTask.dataConsumers:
        await _showDataComsumersNotifications();
        break;
      case WorkTask.largeApps:
        await _showLargeAppsNotifications();
        break;
      case WorkTask.systemApps:
        await _showSystemAppsNotifications();
        break;
      case WorkTask.leastUsedApp:
        await _showLeastUsedAppNotifications();
        break;
      case WorkTask.biggestApp:
        await _showBiggestAppNotifications();
        break;
      case WorkTask.latestInstalledApp:
        await _showLatestInstalledAppNotifications();
        break;
      case WorkTask.optimizePhotos:
        await _showOptimizePhotosNotifications();
        break;
      case WorkTask.similarPhotos:
        await _showSimilarPhotosNotifications();
        break;
      case WorkTask.lowQualityPhotos:
        await _showLowQualityPhotosNotifications();
        break;
      case WorkTask.screenshots:
        await _showScreenshotsNotifications();
        break;
      case WorkTask.oldPhotos:
        await _showOldPhotosNotifications();
        break;
      case WorkTask.downloadedDocument:
        await _showDownloadDocumentNotifications();
        break;
      case WorkTask.largeFiles:
        await _showLargeFilesNotifications();
        break;
      case WorkTask.largeVideos:
        await _showLargeVideosNotifications();
        break;
      case WorkTask.cleaningTips:
        await _showCleaningTipsNotifications();
        break;
      case WorkTask.quickClean:
        await _showQuickCleanNotifications();
        break;
    }
    return Future.value(true);
  });
}

Future<void> _showJunkCleaningNotifications() async {
  final data = await AppManager().getUnnecessaryData();
  final junkData = data.bytes.toOptimal();
  // The junk data more then 10 MB then show the notification
  if (junkData >= 10.mb) {
    NotificationServices.showJunkCleaningNotification(
      title: 'Unnecessary data',
      body:
          'Delete ${junkData.toStringOptimal()} unnecessary to free up space and improve the performance of your device',
      payload: WorkTask.cleanJunk,
    );
  }
}

Future<void> _showLowStorageNotifications() async {
  final data = await GeneralInfoManager().getGeneralInfo();
  final usedMemory = data.usedSpace.bytes.to(DigitalUnitSymbol.gigabyte);
  final totalMemory = data.totalSpace.bytes.to(DigitalUnitSymbol.gigabyte);

  if (usedMemory >= totalMemory * 0.95) {
    NotificationServices.showJunkCleaningNotification(
      title: 'Low storage',
      body: 'Your device memory is running out',
      payload: WorkTask.lowStorage,
    );
  }
}

Future<void> _showUnusedAppsNotificaions() async {
  final appManager = AppManager();
  final apps = await appManager.getAllApplications();
  final unusedApps = await appManager.getAppsUnused(apps, UsagePeriod.week);
  if (unusedApps.length >= 4) {
    NotificationServices.showApplicationsNotification(
      title: 'Unused Apps',
      body:
          'The detection of ${unusedApps.length} apps that have not been used in the past week',
      payload: WorkTask.unusedApps,
    );
  }
}

Future<void> _showBatteryDrainersNotifications() async {
  // TODO: Implement the logic to show the notification
  NotificationServices.showApplicationsNotification(
    title: 'Battery Drainers',
    body: 'Detect several battery drainers',
    payload: WorkTask.batteryDrainers,
  );
}

Future<void> _showDataComsumersNotifications() async {
  final appManager = AppManager();
  final apps = await appManager.getAllApplications();
  var appCount = 0;
  for (var app in apps) {
    final dataUsed = await appManager.getUsageDataApps(app.packageName);
    if (dataUsed.bytes.toOptimal() >= 10.mb) appCount++;
  }
  if (appCount >= 4) {
    NotificationServices.showApplicationsNotification(
      title: 'Data Consumers',
      body:
          'The detection of $appCount apsp using a large amount of data in the past week',
      payload: WorkTask.dataConsumers,
    );
  }
}

Future<void> _showLargeAppsNotifications() async {
  final appManager = AppManager();
  final apps = await appManager.getAllApplications();
  var appCount = 0;
  for (var app in apps) {
    final appGrowingSize = await appManager.getAppSizeGrowingInByte(
        app.packageName, 7, (appGrowingSize) => appGrowingSize);
    if (appGrowingSize.bytes.to(DigitalUnitSymbol.megabyte) >= 50.mb) {
      appCount++;
    }
  }
  if (appCount >= 4) {
    NotificationServices.showApplicationsNotification(
      title: 'Large Apps',
      body: 'The detection of $appCount large apps in the past week',
      payload: WorkTask.largeApps,
    );
  }
}

Future<void> _showSystemAppsNotifications() async {
  final appManager = AppManager();
  final apps = await appManager.getAllApplications();
  final systemApps =
      apps.where((element) => element.appType == AppType.system.name).toList();

  final appsUseLastTimeMap = await appManager.getLastAppsUsageTime(systemApps);

  final appsUseLastTimeList = appsUseLastTimeMap.entries
      .map((e) => e.value)
      .where((element) =>
          element.isBefore(DateTime.now().subtract(const Duration(days: 9))))
      .toList();

  if (appsUseLastTimeList.length >= 4) {
    NotificationServices.showApplicationsNotification(
      title: 'System Apps',
      body:
          'The detection of ${appsUseLastTimeList.length} system apps that have not been used',
      payload: WorkTask.systemApps,
    );
  }
}

Future<void> _showLeastUsedAppNotifications() async {
  final appManager = AppManager();
  final apps = await appManager.getAllApplications();
  final appsUseLastTimeMap = await appManager.getLastAppsUsageTime(apps);
  final appsUseLastTimeList =
      appsUseLastTimeMap.entries.map((e) => e.value).toList();
  appsUseLastTimeList.sort((a, b) => b.compareTo(a));
  final lastOpenedDateTime = appsUseLastTimeList.first;
  if (lastOpenedDateTime
      .isBefore(DateTime.now().subtract(const Duration(days: 9)))) {
    NotificationServices.showApplicationsNotification(
      title: 'Least Used App',
      body: 'The detection of one app that has not been used in the past week',
      payload: WorkTask.leastUsedApp,
    );
  }
}

Future<void> _showBiggestAppNotifications() async {
  final appManager = AppManager();
  final apps = await appManager.getAllApplications();
  final data = await GeneralInfoManager().getGeneralInfo();
  final totalSpace = data.totalSpace.bytes.to(DigitalUnitSymbol.gigabyte);
  for (var app in apps) {
    final appInfoSize = await appManager.getAppSize(
        app.packageName, (appInfoSize) => appInfoSize);

    if (appInfoSize.totalSize.bytes.to(DigitalUnitSymbol.gigabyte) >=
        totalSpace * 0.8) {
      NotificationServices.showApplicationsNotification(
        title: 'Biggest App',
        body: 'The detection of one app occupying all storage space',
        payload: WorkTask.biggestApp,
      );
      break;
    }
  }
}

Future<void> _showLatestInstalledAppNotifications() async {}

Future<void> _showOptimizePhotosNotifications() async {
  final fileManager = FileManager();
  final fileInfo = await fileManager.fileQuery({
    SystemEntityType.optimizablePhoto: null,
  });
  final optimizePhotoAmount =
      fileInfo[SystemEntityType.optimizablePhoto]!.length;
  if (optimizePhotoAmount >= 2) {
    NotificationServices.showPhotosNotification(
      title: 'Optimize Photos',
      body:
          'The detection of $optimizePhotoAmount photos that can be optimized',
      payload: WorkTask.optimizePhotos,
    );
  }
}

Future<void> _showSimilarPhotosNotifications() async {
  final fileManager = FileManager();
  final similarImages = await fileManager.getSimilarImages();
  if (similarImages.length >= 2) {
    NotificationServices.showPhotosNotification(
      title: 'Similar Photos',
      body: 'The detection of ${similarImages.length} similar photos',
      payload: WorkTask.similarPhotos,
    );
  }
}

Future<void> _showLowQualityPhotosNotifications() async {
  final fileManager = FileManager();
  final lowImages = await fileManager.getLowImages();
  if (lowImages.length >= 2) {
    NotificationServices.showPhotosNotification(
      title: 'Low Quality Photos',
      body: 'The detection of ${lowImages.length} low quality photos',
      payload: WorkTask.lowQualityPhotos,
    );
  }
}

Future<void> _showScreenshotsNotifications() async {
  final fileManager = FileManager();
  final fileInfo = await fileManager.fileQuery({
    SystemEntityType.newScreenshot: const NewFileParameter(
      Duration(days: 3),
    ),
  });
  final newScreenshotAmount = fileInfo[SystemEntityType.newScreenshot]!.length;
  if (newScreenshotAmount >= 2) {
    NotificationServices.showPhotosNotification(
      title: 'Screenshots',
      body: 'The detection of $newScreenshotAmount screenshots',
      payload: WorkTask.screenshots,
    );
  }
}

Future<void> _showOldPhotosNotifications() async {
  final fileManager = FileManager();
  final fileInfo = await fileManager.fileQuery({
    SystemEntityType.oldPhotos: const OldFileParameter(
      Duration(days: 30),
    ),
  });

  final oldPhotoAmount = fileInfo[SystemEntityType.oldPhotos]!.length;
  if (oldPhotoAmount >= 2) {
    NotificationServices.showPhotosNotification(
      title: 'Old Photos',
      body: 'The detection of $oldPhotoAmount old photos a month ago',
      payload: WorkTask.oldPhotos,
    );
  }
}

Future<void> _showDownloadDocumentNotifications() async {
  final fileManager = FileManager();
  final fileInfo = await fileManager.fileQuery({
    SystemEntityType.downloadedDocument: null,
  });
  final downloadedDocumentAmount =
      fileInfo[SystemEntityType.downloadedDocument]!.length;
  if (downloadedDocumentAmount >= 4) {
    NotificationServices.showOtherFilesNotification(
      title: 'Download Files',
      body: 'The detection of $downloadedDocumentAmount download files',
      payload: WorkTask.downloadedDocument,
    );
  }
}

Future<void> _showLargeFilesNotifications() async {
  final fileManager = FileManager();
  final fileInfo = await fileManager.fileQuery({
    SystemEntityType.largeNewFile: LargeNewFileParameter(
      const Duration(days: 7),
      largeCapacity.to(DigitalUnitSymbol.byte).value.toInt(),
    ),
  });
  final largeNewFilesAmount = fileInfo[SystemEntityType.largeNewFile]!.length;
  if (largeNewFilesAmount >= 4) {
    NotificationServices.showOtherFilesNotification(
      title: 'Large Files',
      body: 'The detection of $largeNewFilesAmount large files',
      payload: WorkTask.largeFiles,
    );
  }
}

Future<void> _showLargeVideosNotifications() async {
  final fileManager = FileManager();
  final fileInfo = await fileManager.fileQuery({
    SystemEntityType.largeNewVideo: LargeNewFileParameter(
      const Duration(days: 7),
      largeCapacity.to(DigitalUnitSymbol.byte).value.toInt(),
    ),
  });
  final largeNewVideosAmount = fileInfo[SystemEntityType.largeNewVideo]!.length;
  if (largeNewVideosAmount >= 4) {
    NotificationServices.showOtherFilesNotification(
      title: 'Large Videos',
      body: 'The detection of $largeNewVideosAmount large new videos',
      payload: WorkTask.largeVideos,
    );
  }
}

Future<void> _showCleaningTipsNotifications() async {
  NotificationServices.showOtherFilesNotification(
    title: 'Cleaning Tips',
    body: 'The detection of several cleaning tips',
    payload: WorkTask.cleaningTips,
  );
}

Future<void> _showQuickCleanNotifications() async {
  NotificationServices.showCommonNotification(
    title: 'Quick Clean',
    body: 'Clean up unnecessary things',
    payload: WorkTask.quickClean,
  );
}

void executedWorkTask() {
  // Junk Cleaning
  WorkTaskManager.registerPeriodicForLowStorageNotifications();
  // Applications
  WorkTaskManager.registerPeriodicForUnusedAppsFindingNotifications();
  WorkTaskManager.registerPeriodicForDataConsumersFindingNotifications();
  WorkTaskManager.registerPeriodicForLargeAppsFindingNotifications();
  WorkTaskManager.registerPeriodicForSystemAppsFindingNotifications();
  WorkTaskManager.registerPeriodicForLeastUsedAppFindingNotifications();
  WorkTaskManager.registerPeriodicForBiggestAppFindingNotifications();
  // Photos
  WorkTaskManager.registerPeriodicForLowQualityPhotosFindingNotifications();
  WorkTaskManager.registerPeriodicForOptimizePhotosFindingNotifications();
  WorkTaskManager.registerPeriodicForScreenshotsFindingNotifications();
  WorkTaskManager.registerPeriodicForSimilarPhotosFindingNotifications();
  WorkTaskManager.registerPeriodicForOldPhotosFindingNotifications();
  // Other Files
  // TODO: Uncomment when the download file feature is ready
  // WorkTaskManager.registerPeriodicForDownloadedDocumentFindingNotifications();
  WorkTaskManager.registerPeriodicForLargeFilesFindingNotifications();
  WorkTaskManager.registerPeriodicForLargeVideosFindingNotifications();
  //
  WorkTaskManager.registerPeriodicForCleaningTipsFindingNotifications();
  // QuickClean
  WorkTaskManager.registerPeriodicForQuickCleanNotifications();
}
