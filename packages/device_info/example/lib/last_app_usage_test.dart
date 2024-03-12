import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:device_info/device_info.dart';

class LastAppUsageTest extends StatefulWidget {
  const LastAppUsageTest({super.key});

  @override
  State<LastAppUsageTest> createState() => _LastAppUsageTestState();
}

class _LastAppUsageTestState extends State<LastAppUsageTest> {
  List<PackageInfo> listApps = [];

  Map<String, DateTime> lastAppsUsageTime = {};

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

    getLastAppsUsageTime();
  }

  Future getLastAppsUsageTime() async {
    AppManager().getLastAppsUsageTime(listApps).then(
      (value) {
        setState(
          () {
            lastAppsUsageTime = value;
          },
        );
      },
    );
  }

  Widget renderItem(String packageName) {
    DateTime? dateTime = lastAppsUsageTime[packageName];
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
                    (dateTime != null && dateTime.millisecondsSinceEpoch == 0)
                        ? Colors.red
                        : Colors.black),
          ),
          Text(
              "LastTime: ${(dateTime != null && dateTime.millisecondsSinceEpoch == 0) ? 0 : dateTime.toString()}"),
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
