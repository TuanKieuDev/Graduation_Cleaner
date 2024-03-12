import 'dart:async';

import 'package:phone_cleaner/main.dart';
import 'package:phone_cleaner/router/router.dart';
import 'package:phone_cleaner/services/notifications/notification_channel.dart';
import 'package:phone_cleaner/services/work_manager/work_task.dart';
import 'package:phone_cleaner/src/features/features.dart';
import 'package:phone_cleaner/src/features/file/features/filter/views/file_filter_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

class NotificationServices {
  factory NotificationServices() {
    return _notificationServices;
  }

  NotificationServices._internal();

  static final NotificationServices _notificationServices =
      NotificationServices._internal();

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future initialize() async {
    var androidInitialize =
        const AndroidInitializationSettings('mipmap/launcher_icon');
    var initializationSettings =
        InitializationSettings(android: androidInitialize);

    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await NotificationServices.flutterLocalNotificationsPlugin
            .getNotificationAppLaunchDetails();

    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      final payload =
          notificationAppLaunchDetails!.notificationResponse?.payload;
      goToPageBasedOnPayload(payload);
    }

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (notificationResponse) {
        goToPageBasedOnPayload(notificationResponse.payload, true);
      },
    );
  }

  static Future showJunkCleaningNotification({
    required String title,
    required String body,
    var payload,
  }) async {
    await showNotifications(
      title: title,
      body: body,
      channel: NotificationChannel.junkCleaningChannel,
      payload: payload,
    );
  }

  static Future showApplicationsNotification({
    required String title,
    required String body,
    var payload,
  }) async {
    await showNotifications(
      title: title,
      body: body,
      channel: NotificationChannel.applicationsChannel,
      payload: payload,
    );
  }

  static Future showPhotosNotification({
    required String title,
    required String body,
    var payload,
  }) async {
    await showNotifications(
      title: title,
      body: body,
      channel: NotificationChannel.photosChannel,
      payload: payload,
    );
  }

  static Future showOtherFilesNotification({
    required String title,
    required String body,
    var payload,
  }) async {
    await showNotifications(
      title: title,
      body: body,
      channel: NotificationChannel.otherFilesChannel,
      payload: payload,
    );
  }

  static Future showCommonNotification({
    required String title,
    required String body,
    var payload,
  }) async {
    await showNotifications(
      title: title,
      body: body,
      channel: NotificationChannel.commonChannel,
      payload: payload,
    );
  }

  static Future showBackgroundOperationsNotification({
    required String title,
    required String body,
    var payload,
  }) async {
    await showNotifications(
      title: title,
      body: body,
      channel: NotificationChannel.backgroundOperationsChannel,
      payload: payload,
    );
  }

  static Future showNotifications({
    required String title,
    required String body,
    var payload,
    required AndroidNotificationChannel channel,
  }) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: Importance.max,
      priority: Priority.high,
      groupKey: channel.groupId,
    );

    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    final uniqueId = DateTime.now().microsecond;
    await flutterLocalNotificationsPlugin.show(
      uniqueId,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );

    final activeNotifications = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.getActiveNotifications();
    if (activeNotifications!.isNotEmpty) {
      List<String> lines =
          activeNotifications.map((e) => e.title.toString()).toList();
      InboxStyleInformation inboxStyleInformation = InboxStyleInformation(lines,
          contentTitle: "${activeNotifications.length - 1} messages",
          summaryText: "${activeNotifications.length - 1} messages");
      AndroidNotificationDetails groupNotificationDetails =
          AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        styleInformation: inboxStyleInformation,
        setAsGroupSummary: true,
        groupKey: channel.groupId,
      );
      NotificationDetails groupNotificationDetailsPlatformSpefics =
          NotificationDetails(android: groupNotificationDetails);
      await flutterLocalNotificationsPlugin.show(
        0,
        '',
        '',
        groupNotificationDetailsPlatformSpefics,
        payload: payload,
      );
    }
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}

void goToPageBasedOnPayload(String? payload, [bool isAppOpened = false]) async {
  if (payload == null) return;
  if (isAppOpened) {
    if (navigatorKey.currentContext?.canPop() == true) {
      navigatorKey.currentContext?.pop(AppRouter.home);
    }
  }

  switch (payload) {
    case WorkTask.cleanJunk:
      GoRouter.of(navigatorKey.currentContext!).pushNamed(
        AppRouter.boost,
      );
      break;
    case WorkTask.lowStorage:
      GoRouter.of(navigatorKey.currentContext!).pushNamed(
        AppRouter.savingTips,
      );
      break;
    case WorkTask.unusedApps:
      GoRouter.of(navigatorKey.currentContext!).pushNamed(
        AppRouter.listApp,
        extra: const AppFilterArguments(
          appFilterParameter: unusedAppsParams,
        ),
      );
      break;

    case WorkTask.batteryDrainers:
      //TODO: Implement the logic to go to the battery drainers page
      break;

    case WorkTask.dataConsumers:
      GoRouter.of(navigatorKey.currentContext!).pushNamed(
        AppRouter.listApp,
        extra: const AppFilterArguments(
          appFilterParameter: growingAppsParams,
        ),
      );
      break;
    case WorkTask.largeApps:
      GoRouter.of(navigatorKey.currentContext!).pushNamed(
        AppRouter.listApp,
        extra: const AppFilterArguments(
          appFilterParameter: largeAppsParams,
        ),
      );
      break;
    case WorkTask.systemApps:
      GoRouter.of(navigatorKey.currentContext!).pushNamed(
        AppRouter.listApp,
        extra: const AppFilterArguments(
          appFilterParameter: systeamAppUnusedParams,
        ),
      );
      break;
    case WorkTask.leastUsedApp:
      GoRouter.of(navigatorKey.currentContext!).pushNamed(
        AppRouter.listApp,
        extra: const AppFilterArguments(
          appFilterParameter: unusedAppsParams,
        ),
      );
      break;
    case WorkTask.biggestApp:
      GoRouter.of(navigatorKey.currentContext!).pushNamed(
        AppRouter.listApp,
        extra: const AppFilterArguments(
          appFilterParameter: unusedAppsParams,
        ),
      );
      break;
    case WorkTask.latestInstalledApp:
      // TODO: Implement the logic to go to the latest installed app page
      break;
    case WorkTask.optimizePhotos:
      GoRouter.of(navigatorKey.currentContext!).pushNamed(
        AppRouter.fileFilter,
        extra: const FileFilterArguments(
          fileFilterParameter: optimizedPhotosFilterParam,
        ),
      );
      break;
    case WorkTask.similarPhotos:
      GoRouter.of(navigatorKey.currentContext!).pushNamed(
        AppRouter.fileFilter,
        extra: const FileFilterArguments(
          fileFilterParameter: similarPhotosFilterParam,
        ),
      );
      break;
    case WorkTask.lowQualityPhotos:
      GoRouter.of(navigatorKey.currentContext!).pushNamed(
        AppRouter.fileFilter,
        extra: const FileFilterArguments(
          fileFilterParameter: similarPhotosFilterParam,
        ),
      );
      break;
    case WorkTask.screenshots:
      GoRouter.of(navigatorKey.currentContext!).pushNamed(
        AppRouter.fileFilter,
        extra: const FileFilterArguments(
          fileFilterParameter: screenshotsFilterParam,
        ),
      );
      break;
    case WorkTask.oldPhotos:
      GoRouter.of(navigatorKey.currentContext!).pushNamed(
        AppRouter.fileFilter,
        extra: const FileFilterArguments(
          fileFilterParameter: oldPhotosFilterParam,
        ),
      );
      break;
    case WorkTask.downloadedDocument:
      // TODO: Implement the logic to go to the downloaded document page
      break;
    case WorkTask.largeFiles:
      GoRouter.of(navigatorKey.currentContext!).pushNamed(
        AppRouter.fileFilter,
        extra: const FileFilterArguments(
          fileFilterParameter: largeFilesFilterParam,
        ),
      );
      break;
    case WorkTask.largeVideos:
      GoRouter.of(navigatorKey.currentContext!).pushNamed(
        AppRouter.fileFilter,
        extra: const FileFilterArguments(
          fileFilterParameter: largeVideosFilterParam,
        ),
      );
      break;
    case WorkTask.cleaningTips:
      GoRouter.of(navigatorKey.currentContext!).pushNamed(
        AppRouter.savingTips,
      );
      break;
    case WorkTask.quickClean:
      GoRouter.of(navigatorKey.currentContext!).pushNamed(
        AppRouter.quickClean,
      );
      break;
    case WorkTask.batteryAnalysis:
      GoRouter.of(navigatorKey.currentContext!).pushNamed(
        AppRouter.battery,
      );
      break;
    case WorkTask.photoAnalysis:
      GoRouter.of(navigatorKey.currentContext!).pushNamed(
        AppRouter.media,
      );
      break;
  }
}
