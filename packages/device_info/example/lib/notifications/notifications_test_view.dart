import 'package:cleaner_app_info_example/notifications/notification.dart';
import 'package:flutter/material.dart';

class NotificationTestView extends StatefulWidget {
  const NotificationTestView({super.key});

  @override
  State<NotificationTestView> createState() => _NotificationTestViewState();
}

class _NotificationTestViewState extends State<NotificationTestView> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            child: const Text('Click'),
            onPressed: () {
              NotificationService.showBigtextNotification(
                title: 'Test11',
                body: 'Test111',
                // flutterLocalNotificationsPlugin:
                //     flutterLocalNotificationsPlugin,
                channel: channel,
              );
            },
          ),
          ElevatedButton(
            child: const Text('Click2'),
            onPressed: () {
              NotificationService.showTextOfChannelNotification(
                title: 'Test2',
                body: 'Test22222',
                channel: channel2,
              );
            },
          ),
          ElevatedButton(
            child: const Text('Click3'),
            onPressed: () {
              NotificationService.showScheduleNotification(
                title: 'Test3',
                body: 'Test3333',
                channel: channel2,
              );
            },
          ),
        ],
      ),
    );
  }
}
