import 'dart:math';
import 'dart:developer' as dev;

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:device_info/device_info.dart';

class AppUsageTest extends StatefulWidget {
  const AppUsageTest({super.key});

  @override
  State<AppUsageTest> createState() => _AppUsageTestState();
}

class _AppUsageTestState extends State<AppUsageTest> {
  List<PackageInfo> listApps = [];

  Map<String, AppInfoUsage> appsUsageInfo = {};
  Map<String, String> appDataUsage = {};

  String filterType = "LAST_7_DAYS";

  @override
  void initState() {
    super.initState();
    _requestAppUsagePermission();
    getAllApp();
  }

  Future _requestAppUsagePermission() async {
    AppSettings.openUsageSettings();
  }

  Future getAllApp() async {
    List<PackageInfo> result = await AppManager().getAllApplications();

    setState(() {
      listApps = result;
    });

    await AppManager().refreshAllEvents(listApps);

    getAppsDataUsage();
  }

  void getAppsDataUsage() async {
    for (var element in listApps) {
      int value = await AppManager().getUsageDataApps(element.packageName);
      setState(() {
        appDataUsage[element.packageName] = getReadableFileSize(value);
        if (value != 0) {
          debugPrint(
              "PackageName: ${element.packageName} -- Value: ${getReadableFileSize(value)}");
        }
        setState(
          () {
            appDataUsage[element.packageName] = getReadableFileSize(value);
          },
        );
      });
    }
  }

  Future getAppsUsageInfo() async {
    var endTime = DateTime.now().millisecondsSinceEpoch;
    int startTime;
    if (filterType == "LAST_24_HOURS") {
      startTime = endTime - 1 * 24 * 3600 * 1000;
      getTimeline(UsagePeriod.day);
    } else {
      startTime = endTime - 7 * 24 * 3600 * 1000;
      getTimeline(UsagePeriod.week);
    }

    for (var item in listApps) {
      AppManager().getAppUsageInfo(item.packageName, startTime, endTime).then(
        (value) {
          setState(
            () {
              appsUsageInfo[item.packageName] = value;
            },
          );
        },
      );
    }
  }

  Future getTimeline(UsagePeriod usagePeriod) async {
    await AppManager().getTimelineOfApp(usagePeriod).then(
      (value) {
        for (var element in value) {
          dev.log(
              "Date: ${element.dateTime} -- Time: ${convertTimeToString(element.appUsageTime)}\n");
        }
      },
    );
  }

  String convertTimeToString(int timeInMilliseconds) {
    int minutes = (timeInMilliseconds / 1000) ~/ 60;
    int seconds = ((timeInMilliseconds / 1000) % 60).toInt();
    if (minutes < 60) {
      return "${minutes}p ${seconds}s";
    }
    int hours = ((timeInMilliseconds / 1000) / 60) ~/ 60;
    minutes = (((timeInMilliseconds / 1000) / 60) % 60).toInt();
    return "${hours}h ${minutes}p ${seconds}s";
  }

  Widget renderItem(String packageName) {
    AppInfoUsage? appInfoUsage = appsUsageInfo[packageName];
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
                color: appsUsageInfo != null ? Colors.black : Colors.red),
          ),
          Text(
              "Total Time Used : ${appsUsageInfo != null ? formatTime(appInfoUsage?.totalTimeSpent) : 0}"),
          Text(
              "Times Opened : ${appsUsageInfo != null ? appInfoUsage?.totalOpened : 0}"),
          Text("Data used : ${appDataUsage[packageName]}")
        ],
      ),
    );
  }

  String? formatTime(int? mili) {
    if (mili == null) {
      return "";
    }
    int seconds = mili ~/ 1000;

    int hour = seconds ~/ 3600;
    int minute = (seconds % 3600) ~/ 60;
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
                        getAppsUsageInfo();
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
                        getAppsUsageInfo();
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
