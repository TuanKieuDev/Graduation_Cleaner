import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:device_info/device_info.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationUsageTest extends StatefulWidget {
  const NotificationUsageTest({super.key});

  @override
  State<NotificationUsageTest> createState() => _NotificationUsageTestState();
}

class _NotificationUsageTestState extends State<NotificationUsageTest> {
  List<PackageInfo> listApps = [];

  Map<String, int> appsNotificationNumber = {};

  String filterType = "LAST_24_HOURS";

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
    _requestNotificationListenerPermission();
    _requestAppUsagePermission();
    getAllApp();
  }

  Future _requestAppUsagePermission() async {
    AppSettings.openUsageSettings();
  }

  Future _requestNotificationListenerPermission() async {
    AppSettings.openNotificationSettings();
  }

  Future _requestNotificationPermission() async {
    var status = await Permission.notification.status;
    if (status.isGranted) {
      countNotificationOfAllPackagesSince(UsagePeriod.day);
    } else if (status.isDenied) {
      if (await Permission.notification.request().isGranted) {
        countNotificationOfAllPackagesSince(UsagePeriod.day);
      }
    }
  }

  Future getAllApp() async {
    List<PackageInfo> result = await AppManager().getAllApplications();

    setState(() {
      listApps = result;
    });
  }

  Future countNotificationOfAllPackagesSince(UsagePeriod usagePeriod) async {
    AppManager().countNotificationOfAllPackagesByUsagePeriod(usagePeriod).then(
      (value) {
        setState(
          () {
            appsNotificationNumber = value;
          },
        );
      },
    );

    getNotificationTimeline(usagePeriod);
  }

  Future getNotificationTimeline(UsagePeriod usagePeriod) async {
    AppManager().getNotificationTimeline(usagePeriod).then(
      (value) {
        print("Notification Timeline: ");
        value.forEach((element) {
          print(
              "DateTime: ${element.dateTime} --- Quantity: ${element.notificationQuantity}");
        });
      },
    );
  }

  Widget renderItem(String packageName) {
    int? notificationQuantity = appsNotificationNumber[packageName];
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "PackageName: $packageName",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color:
                    notificationQuantity != null ? Colors.black : Colors.red),
          ),
          Text("Count: $notificationQuantity"),
        ],
      ),
    );
  }

  String? formatTime(int? mili) {
    if (mili == null) {
      return "";
    }
    int seconds = (mili / 1000).toInt();

    int hour = (seconds / 3600).toInt();
    int minute = ((seconds % 3600) / 60).toInt();
    int second = ((seconds % 3600) % 60).toInt();
    return "${hour}h ${minute}p $second";
  }

  String getReadableFileSize(int size) {
    if (size == 0) {
      return "0";
    }
    var units = ["B", "KB", "MB", "GB", "TB"];
    var digitGroups = log(size.toDouble()) ~/ log(1024.0);
    return "${(size / pow(1024.0, digitGroups.toDouble())).toStringAsFixed(2)} ${units[digitGroups]}";
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Text("Number of apps: ${listApps.length}"),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () => setState(() {
                        filterType = "LAST_7_DAYS";
                        countNotificationOfAllPackagesSince(UsagePeriod.week);
                      }),
                      child: Container(
                        child: Text(
                          "7 days",
                          style: TextStyle(
                              fontSize: 16,
                              backgroundColor: filterType == "LAST_7_DAYS"
                                  ? Colors.red
                                  : null),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() {
                        filterType = "LAST_24_HOURS";
                        countNotificationOfAllPackagesSince(UsagePeriod.day);
                      }),
                      child: Text(
                        "24 hours",
                        style: TextStyle(
                            fontSize: 16,
                            backgroundColor: filterType == "LAST_24_HOURS"
                                ? Colors.red
                                : null),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: listApps
                        .map((value) => renderItem(value.packageName))
                        .toList(),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
