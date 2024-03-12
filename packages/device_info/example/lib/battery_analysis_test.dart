import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:device_info/device_info.dart';
import 'package:permission_handler/permission_handler.dart';

class BatteryAnalysisTest extends StatefulWidget {
  const BatteryAnalysisTest({super.key});

  @override
  State<BatteryAnalysisTest> createState() => _BatteryAnalysisTestState();
}

class _BatteryAnalysisTestState extends State<BatteryAnalysisTest> {
  List<PackageInfo> listApps = [];

  List<RowDataForTest> rowsData = [];

  Map<String, double> appsBatteryUsage = {};

  UsagePeriod filterType = UsagePeriod.week;
  bool isShowData = false;

  double oldBatteryPct = -5;
  int previousReceiverCallTime = -5;
  int timesReceive = -5;

  @override
  void initState() {
    super.initState();
    _requestAppUsagePermission();
    _requestNotificationPermission();
    getAllApp();
  }

  Future _requestAppUsagePermission() async {
    AppSettings.openUsageSettings();
  }

  Future _requestNotificationPermission() async {
    var status = await Permission.notification.status;
    if (status.isGranted) {
      AppManager().runBatteryAnalysisService();
    } else if (status.isDenied) {
      if (await Permission.notification.request().isGranted) {
        AppManager().runBatteryAnalysisService();
      }
    }
  }

  Future getAllApp() async {
    List<PackageInfo> result = await AppManager().getAllApplications();

    setState(() {
      listApps = result;
    });

    getAppsBatteryUsagePct();
  }

  Future getAppsBatteryUsagePct() async {
    AppManager().getAppsBatteryUsagePercentage(filterType).then(
      (result) {
        setState(() {
          appsBatteryUsage = result;
          print(appsBatteryUsage);
        });
      },
    );
  }

  Future getBatteryUsageRowsData() async {
    AppManager().getBatteryAnalysisAllRowsForTest().then((value) {
      setState(() {
        rowsData = value;
      });
    });
  }

  Widget renderItem(String packageName) {
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
              color: appsBatteryUsage[packageName] != null
                  ? Colors.black
                  : Colors.red,
            ),
          ),
          Text("Battery Usage Percent: ${appsBatteryUsage[packageName] ?? 0}")
        ],
      ),
    );
  }

  Widget renderRowData(RowDataForTest rowData) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Battery Level: ${rowData.batteryLevel}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
              "Time: ${DateTime.fromMillisecondsSinceEpoch(rowData.timeStamp).toString()}"),
          Text("Is Charging: ${rowData.isCharging}")
        ],
      ),
    );
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
                        filterType = UsagePeriod.week;
                        isShowData = false;
                        getAppsBatteryUsagePct();
                      }),
                      child: Container(
                        child: Text(
                          "7 days",
                          style: TextStyle(
                              fontSize: 16,
                              backgroundColor:
                                  filterType == UsagePeriod.week && !isShowData
                                      ? Colors.red
                                      : null),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() {
                        filterType = UsagePeriod.day;
                        isShowData = false;
                        getAppsBatteryUsagePct();
                      }),
                      child: Text(
                        "24 hours",
                        style: TextStyle(
                            fontSize: 16,
                            backgroundColor:
                                filterType == UsagePeriod.day && !isShowData
                                    ? Colors.red
                                    : null),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() {
                        isShowData = true;
                        getBatteryUsageRowsData();
                      }),
                      child: Text(
                        "Show Data",
                        style: TextStyle(
                            fontSize: 16,
                            backgroundColor: isShowData ? Colors.red : null),
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
                    children: isShowData
                        ? rowsData.map((e) => renderRowData(e)).toList()
                        : listApps
                            .map(
                              (value) => renderItem(value.packageName),
                            )
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
