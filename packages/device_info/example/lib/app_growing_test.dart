import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:cleaner_app_info_example/models/app_growing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info/device_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info/src/flutter_config/src/models/src/package_info/package_info.dart';

class AppGrowingTest extends StatefulWidget {
  const AppGrowingTest({super.key});

  @override
  State<AppGrowingTest> createState() => _AppGrowingTestState();
}

class _AppGrowingTestState extends State<AppGrowingTest> {
  List<PackageInfo> listApps = [];

  Map<String, AppGrowing> appsGrowingSize = {};

  String filterType = "LAST_7_DAYS";

  @override
  void initState() {
    super.initState();
    _requestAppUsagePermission();
    getAllApp();
    AppManager().runAppGrowingService();
  }

  Future _requestAppUsagePermission() async {
    AppSettings.openUsageSettings();
  }

  Future getAllApp() async {
    List<PackageInfo> result = await AppManager().getAllApplications();

    setState(() {
      listApps = result;
    });

    await getAppsGrowing(7);
    await getAppsGrowing(1);
  }

  Future getAppsGrowing(int inDays) async {
    // var timeRemaining =
    //     await  AppManager().getTimeRemainingForAppGrowingAnalysis();

    // if (timeRemaining > 0) {
    //   debugPrint("Time Remaining: $timeRemaining");
    // }

    for (var element in listApps) {
      AppManager().getAppSizeGrowingInByte(element.packageName, inDays,
          (value) {
        setState(() {
          if (value < 0) {
            debugPrint("PackageName: ${element.packageName}");
            debugPrint("Value: $value");
          }
          if (appsGrowingSize[element.packageName] == null) {
            if (inDays == 7) {
              appsGrowingSize[element.packageName] =
                  AppGrowing(element.packageName, 0, value);
            } else {
              appsGrowingSize[element.packageName] =
                  AppGrowing(element.packageName, value, 0);
            }
          } else {
            if (inDays == 7) {
              appsGrowingSize[element.packageName]?.growingInSevenDays = value;
            } else {
              appsGrowingSize[element.packageName]?.growingInOneDay = value;
            }
          }
        });
      }).then((value) {
        if (value < 0) {
          debugPrint("PackageName: ${element.packageName}");
          debugPrint("Value: $value");
        }
        if (appsGrowingSize[element.packageName] == null) {
          if (inDays == 7) {
            appsGrowingSize[element.packageName] =
                AppGrowing(element.packageName, 0, value);
          } else {
            appsGrowingSize[element.packageName] =
                AppGrowing(element.packageName, value, 0);
          }
        } else {
          if (inDays == 7) {
            appsGrowingSize[element.packageName]?.growingInSevenDays = value;
          } else {
            appsGrowingSize[element.packageName]?.growingInOneDay = value;
          }
        }
      });
    }
  }

  Widget renderItem(String packageName) {
    AppGrowing? appGrowing = appsGrowingSize[packageName];
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "PackageName: $packageName",
            style: TextStyle(
                fontWeight: (appGrowing == null ||
                        (appGrowing.growingInOneDay == 0 &&
                            appGrowing.growingInSevenDays == 0))
                    ? FontWeight.normal
                    : FontWeight.bold,
                color: (appGrowing == null ||
                        (appGrowing.growingInOneDay == 0 &&
                            appGrowing.growingInSevenDays == 0))
                    ? Colors.red
                    : Colors.black),
          ),
          Text(
              "In 24 hours: ${getReadableFileSize(appGrowing?.growingInOneDay)}"),
          Text(
              "In 7 days: ${getReadableFileSize(appGrowing?.growingInSevenDays)}")
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

  String getReadableFileSize(int? size) {
    if (size == null) return "null";
    if (size == 0) {
      return "0";
    }
    var units = ["B", "KB", "MB", "GB", "TB"];
    var digitGroups = log(size.abs().toDouble()) ~/ log(1024.0);
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
                        getAppsGrowing(7);
                        getAppsGrowing(1);
                      }),
                      child: Container(
                        child: const Text(
                          "Refresh",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: listApps
                          .map((value) => renderItem(value.packageName))
                          .toList(),
                    ),
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
