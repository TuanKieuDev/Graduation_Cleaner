import 'package:cleaner_app_info_example/notifications/notification.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

class WorkManagerServiceTestView extends StatefulWidget {
  const WorkManagerServiceTestView({super.key});

  @override
  State<WorkManagerServiceTestView> createState() =>
      _WorkManagerServiceTestViewState();
}

final workManager = Workmanager();
const simpleTask = "simpleTask";
const simpleTask1 = "simpleTask1";

Future<void> showNotification() async {
  final list = await AppManager().getAllApplications();

  NotificationService.showBigtextNotification(
    title: 'Notification',
    body: 'Số người yêu cũ của Tuần Kiều${list.length}',
    channel: channel,
  );
}

Future<void> showNotification1() async {
  NotificationService.showTextOfChannelNotification(
    title: 'Notification',
    body: 'Trung dejp trai',
    channel: channel,
  );
}

void callbackDispatcher() {
  workManager.executeTask((task, inputData) async {
    NotificationService.initialize(flutterLocalNotificationsPlugin);
    switch (task) {
      case simpleTask:
        await showNotification();
        break;
      case simpleTask1:
        await showNotification1();
        break;
    }
    return Future.value(true);
  });
}

void setUpWorkManager() {
  workManager.initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
}

class _WorkManagerServiceTestViewState
    extends State<WorkManagerServiceTestView> {
  var count = 0;
  @override
  void initState() {
    setUpWorkManager();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Count: $count'),
            ElevatedButton(
              child: const Text('Click'),
              onPressed: () async {
                var uniqueId = DateTime.now().second.toString();
                await workManager.registerOneOffTask(
                  uniqueId,
                  simpleTask,
                );
                setState(() {
                  count++;
                });
              },
            ),
            ElevatedButton(
              child: const Text('Click2'),
              onPressed: () async {
                var uniqueId = DateTime.now().second.toString();
                await workManager.registerOneOffTask(
                  uniqueId,
                  simpleTask1,
                );
                setState(() {
                  count++;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
