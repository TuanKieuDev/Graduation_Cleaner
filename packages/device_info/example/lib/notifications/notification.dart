import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// use for show local notification
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'channel_1',
  "Channel 1",
  description: 'This channel is used important notification',
  groupId: 'cclean_notification_group',
);

const AndroidNotificationChannel channel2 = AndroidNotificationChannel(
  'channel_2',
  "Channel 2",
  description: 'This channel is used important notification',
  groupId: 'cclean_notification_group',
);

class NotificationService {
  static Future initialize(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidInitialize =
        const AndroidInitializationSettings('mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: androidInitialize);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future showBigtextNotification({
    required String title,
    required String body,
    var payLoad,
    required AndroidNotificationChannel channel,
  }) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: Importance.max,
      priority: Priority.high,
      channelShowBadge: false,
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
          0, '', '', groupNotificationDetailsPlatformSpefics);
    }
  }

  static Future showTextOfChannelNotification({
    required String title,
    required String body,
    var payLoad,
    required AndroidNotificationChannel channel,
  }) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: Importance.max,
      priority: Priority.high,
      channelShowBadge: false,
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
          0, '', '', groupNotificationDetailsPlatformSpefics);
    }
  }

  static Future showScheduleNotification({
    required String title,
    required String body,
    var payLoad,
    required AndroidNotificationChannel channel,
  }) async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.local);

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
    await flutterLocalNotificationsPlugin.zonedSchedule(
      uniqueId,
      title,
      body,
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
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
          0, '', '', groupNotificationDetailsPlatformSpefics);
    }
  }
}
