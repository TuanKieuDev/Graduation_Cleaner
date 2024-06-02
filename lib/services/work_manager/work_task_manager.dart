import 'package:phone_cleaner/services/work_manager/work_task.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

class WorkTaskManager {
  static void registerPeriodicForLowStorageNotifications() {
    Workmanager().registerPeriodicTask(
      WorkTask.lowStorage,
      WorkTask.lowStorage,
      existingWorkPolicy: ExistingWorkPolicy.keep,
      frequency: const Duration(days: 3),
      initialDelay: const Duration(days: 1),
    );
    debugPrint('Register periodic for low storage notifications');
  }

  static void unregisterPeriodicForLowStorageNotifications() {
    Workmanager().cancelByUniqueName(WorkTask.lowStorage);
    debugPrint('Unregister periodic for low storage notifications');
  }

  static void registerPeriodicForUnusedAppsFindingNotifications() {
    Workmanager().registerPeriodicTask(
      WorkTask.unusedApps,
      WorkTask.unusedApps,
      existingWorkPolicy: ExistingWorkPolicy.keep,
      frequency: const Duration(days: 7),
      initialDelay: const Duration(days: 1),
    );
    debugPrint('Register peroiodic for unused apps finding notifications');
  }

  static void unregisterPeriodicForUnusedAppsFindingNotifications() {
    Workmanager().cancelByUniqueName(WorkTask.unusedApps);
    debugPrint('Unregister perioidic for unused apps finding notifications');
  }

  static void registerPeriodicForBatteryDrainersFindingNotifications() {
    Workmanager().registerPeriodicTask(
      WorkTask.batteryDrainers,
      WorkTask.batteryDrainers,
      existingWorkPolicy: ExistingWorkPolicy.keep,
      frequency: const Duration(days: 7),
      initialDelay: const Duration(days: 1),
    );
    debugPrint('Register peroiodic for battery drainers finding notifications');
  }

  static void unregisterPeriodicForBatteryDrainersFindingNotifications() {
    Workmanager().cancelByUniqueName(WorkTask.batteryDrainers);
    debugPrint(
        'Unregister perioidic for battery drainers finding notifications');
  }

  static void registerPeriodicForDataConsumersFindingNotifications() {
    Workmanager().registerPeriodicTask(
      WorkTask.dataConsumers,
      WorkTask.dataConsumers,
      existingWorkPolicy: ExistingWorkPolicy.keep,
      frequency: const Duration(days: 7),
      initialDelay: const Duration(days: 1),
    );
    debugPrint('Register peroiodic for data consumers finding notifications');
  }

  static void unregisterPeriodicForDataConsumersFindingNotifications() {
    Workmanager().cancelByUniqueName(WorkTask.dataConsumers);
    debugPrint('Unregister perioidic for data consumers finding notifications');
  }

  static void registerPeriodicForLargeAppsFindingNotifications() {
    Workmanager().registerPeriodicTask(
      WorkTask.largeApps,
      WorkTask.largeApps,
      existingWorkPolicy: ExistingWorkPolicy.keep,
      frequency: const Duration(days: 7),
      initialDelay: const Duration(days: 1),
    );
    debugPrint('Register peroiodic for large apps finding notifications');
  }

  static void unregisterPeriodicForLargeAppsFindingNotifications() {
    Workmanager().cancelByUniqueName(WorkTask.largeApps);
    debugPrint('Unregister perioidic for large apps finding notifications');
  }

  static void registerPeriodicForSystemAppsFindingNotifications() {
    Workmanager().registerPeriodicTask(
      WorkTask.systemApps,
      WorkTask.systemApps,
      existingWorkPolicy: ExistingWorkPolicy.keep,
      frequency: const Duration(days: 7),
      initialDelay: const Duration(days: 1),
    );
    debugPrint('Register periodic for system apps finding notifications');
  }

  static void unregisterPeroiodicForSystemAppsFindingNotifications() {
    Workmanager().cancelByUniqueName(WorkTask.systemApps);
    debugPrint('Unregister perioidic for system apps finding notifications');
  }

  static void registerPeriodicForLeastUsedAppFindingNotifications() {
    Workmanager().registerPeriodicTask(
      WorkTask.leastUsedApp,
      WorkTask.leastUsedApp,
      existingWorkPolicy: ExistingWorkPolicy.keep,
      frequency: const Duration(days: 7),
      initialDelay: const Duration(days: 1),
    );
    debugPrint('Register periodic for least used app finding notifications');
  }

  static void unregisterPeriodicForLeastUsedAppFindingNotifications() {
    Workmanager().cancelByUniqueName(WorkTask.leastUsedApp);
    debugPrint('Unregister perioidic for least used app finding notifications');
  }

  static void registerPeriodicForBiggestAppFindingNotifications() {
    Workmanager().registerPeriodicTask(
      WorkTask.biggestApp,
      WorkTask.biggestApp,
      existingWorkPolicy: ExistingWorkPolicy.keep,
      frequency: const Duration(days: 7),
      initialDelay: const Duration(days: 1),
    );
    debugPrint('Register periodic for biggest app finding notifications');
  }

  static void unregisterPeriodicForBiggestAppFindingNotifications() {
    Workmanager().cancelByUniqueName(WorkTask.biggestApp);
    debugPrint('Unregister perioidic for biggest app finding notifications');
  }

  static void registerForLatestInstalledAppFindingNotifications() {
    Workmanager().registerOneOffTask(
      WorkTask.latestInstalledApp,
      WorkTask.latestInstalledApp,
    );
    debugPrint('Register for latest app finding notifications');
  }

  static void unregisterPeroidicForLatestInstalledAppFindingNotifications() {
    Workmanager().cancelByUniqueName(WorkTask.latestInstalledApp);
    debugPrint('Unregister perioidic for latest app finding notifications');
  }

  static void registerPeriodicForOptimizePhotosFindingNotifications() {
    Workmanager().registerPeriodicTask(
      WorkTask.optimizePhotos,
      WorkTask.optimizePhotos,
      existingWorkPolicy: ExistingWorkPolicy.keep,
      frequency: const Duration(days: 3),
      initialDelay: const Duration(days: 1),
    );
    debugPrint('Register periodic for optimize photos finding notifications');
  }

  static void unregisterPeriodicForOptimizePhotosFindingNotifications() {
    Workmanager().cancelByUniqueName(WorkTask.optimizePhotos);
    debugPrint('Unregister periodic for optimize photos finding notifications');
  }

  static void registerPeriodicForSimilarPhotosFindingNotifications() {
    Workmanager().registerPeriodicTask(
      WorkTask.similarPhotos,
      WorkTask.similarPhotos,
      existingWorkPolicy: ExistingWorkPolicy.keep,
      frequency: const Duration(days: 3),
      initialDelay: const Duration(days: 1),
    );
    debugPrint('Register periodic for similar photos finding notifications');
  }

  static void unregisterPeriodicForSimilarPhotosFindingNotifications() {
    Workmanager().cancelByUniqueName(WorkTask.similarPhotos);
    debugPrint('Unregister periodic for similar photos finding notifications');
  }

  static void registerPeriodicForLowQualityPhotosFindingNotifications() {
    Workmanager().registerPeriodicTask(
      WorkTask.lowQualityPhotos,
      WorkTask.lowQualityPhotos,
      existingWorkPolicy: ExistingWorkPolicy.keep,
      frequency: const Duration(days: 3),
      initialDelay: const Duration(days: 1),
    );
    debugPrint(
        'Register periodic for low quality photos finding notifications');
  }

  static void unregisterPeriodicForLowQualityPhotosFindingNotifications() {
    Workmanager().cancelByUniqueName(WorkTask.lowQualityPhotos);
    debugPrint(
        'Unregister periodic for low quality photos finding notifications');
  }

  static void registerPeriodicForScreenshotsFindingNotifications() {
    Workmanager().registerPeriodicTask(
      WorkTask.screenshots,
      WorkTask.screenshots,
      existingWorkPolicy: ExistingWorkPolicy.keep,
      frequency: const Duration(days: 3),
      initialDelay: const Duration(days: 1),
    );
    debugPrint('Register periodic for screenshots finding notifications');
  }

  static void unregisterPeriodicForScreenshotsFindingNotifications() {
    Workmanager().cancelByUniqueName(WorkTask.screenshots);
    debugPrint('Unregister periodic for screenshots finding notifications');
  }

  static void registerPeriodicForOldPhotosFindingNotifications() {
    Workmanager().registerPeriodicTask(
      WorkTask.oldPhotos,
      WorkTask.oldPhotos,
      existingWorkPolicy: ExistingWorkPolicy.keep,
      frequency: const Duration(days: 7),
      initialDelay: const Duration(days: 1),
    );
    debugPrint('Register periodic for old photos finding notifications');
  }

  static void unregisterPeriodicForOldPhotosFindingNotifications() {
    Workmanager().cancelByUniqueName(WorkTask.oldPhotos);
    debugPrint('Unregister periodic for old photos finding notifications');
  }

  static void registerPeriodicForDownloadedDocumentFindingNotifications() {
    Workmanager().registerPeriodicTask(
      WorkTask.downloadedDocument,
      WorkTask.downloadedDocument,
      existingWorkPolicy: ExistingWorkPolicy.keep,
      frequency: const Duration(days: 3),
      initialDelay: const Duration(days: 1),
    );
    debugPrint(
        'Register periodic for downloaded document finding notifications');
  }

  static void unregisterPeriodicForDownloadedFilesFindingNotifications() {
    Workmanager().cancelByUniqueName(WorkTask.downloadedDocument);
    debugPrint(
        'Unregister periodic for downloaded files finding notifications');
  }

  static void registerPeriodicForLargeFilesFindingNotifications() {
    Workmanager().registerPeriodicTask(
      WorkTask.largeFiles,
      WorkTask.largeFiles,
      existingWorkPolicy: ExistingWorkPolicy.keep,
      frequency: const Duration(days: 7),
      initialDelay: const Duration(days: 1),
    );
    debugPrint('Register periodic for large files finding notifications');
  }

  static void unregisterPeriodicForLargeFilesFindingNotification() {
    Workmanager().cancelByUniqueName(WorkTask.largeFiles);
    debugPrint('Unregister periodic for large files finding notifications');
  }

  static void registerPeriodicForLargeVideosFindingNotifications() {
    Workmanager().registerPeriodicTask(
      WorkTask.largeVideos,
      WorkTask.largeVideos,
      existingWorkPolicy: ExistingWorkPolicy.keep,
      frequency: const Duration(days: 7),
      initialDelay: const Duration(days: 1),
    );
    debugPrint('Register periodic for large videos finding notifications');
  }

  static void unregisterPeriodicForLargeVideosFindingNotifications() {
    Workmanager().cancelByUniqueName(WorkTask.largeVideos);
    debugPrint('Unregister periodic for large videos finding notifications');
  }

  static void registerPeriodicForCleaningTipsFindingNotifications() {
    Workmanager().registerPeriodicTask(
      WorkTask.cleaningTips,
      WorkTask.cleaningTips,
      existingWorkPolicy: ExistingWorkPolicy.keep,
      frequency: const Duration(days: 2),
      initialDelay: const Duration(days: 1),
    );
    debugPrint('Register periodic for cleaning tips finding notifications');
  }

  static void unregisterPeriodicForCleaningTipsFindingNotifications() {
    Workmanager().cancelByUniqueName(WorkTask.cleaningTips);
    debugPrint('Unregister periodic for cleaning tips finding notifications');
  }

  static void registerPeriodicForQuickCleanNotifications() {
    Workmanager().registerPeriodicTask(
      WorkTask.quickClean,
      WorkTask.quickClean,
      existingWorkPolicy: ExistingWorkPolicy.replace,
      frequency: const Duration(days: 3),
      initialDelay: const Duration(days: 1),
    );
    debugPrint('Register periodic for quick clean notifications');
  }

  static void unregisterPeriodicForQuickCleanNotifications() {
    Workmanager().cancelByUniqueName(WorkTask.quickClean);
    debugPrint('Unregister periodic for quick clean notifications');
  }
}
