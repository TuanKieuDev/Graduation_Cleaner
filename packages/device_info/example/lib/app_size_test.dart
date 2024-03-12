import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info/device_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info/src/flutter_config/src/models/src/package_info/package_info.dart';

class AppSizeTest extends StatefulWidget {
  const AppSizeTest({super.key});

  @override
  State<AppSizeTest> createState() => _AppSizeTestState();
}

class _AppSizeTestState extends State<AppSizeTest> {
  List<PackageInfo> listApps = [];

  Map<String, AppInfoSize> appsSizeInfo = {};

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

    getAppsSize();
  }

  Future getAppsSize() async {
    listApps.forEach((element) {
      AppManager().getAppSize(element.packageName, (value) {
        setState(() {
          appsSizeInfo[element.packageName] = value;
        });
      }).then((value) {
        setState(() {
          appsSizeInfo[element.packageName] = value;
        });
      });
    });
  }

  Widget renderItem(AppInfoSize appInfoSize) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "PackageName: ${appInfoSize.packageName}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text("App Size: ${getReadableFileSize(appInfoSize.appSize)}"),
          Text("Data Size: ${getReadableFileSize(appInfoSize.dataSize)}"),
          Text("Cache Size: ${getReadableFileSize(appInfoSize.cacheSize)}"),
          Text(
              "Total: ${getReadableFileSize(appInfoSize.appSize + appInfoSize.cacheSize + appInfoSize.dataSize)}")
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
                    children: appsSizeInfo.values
                        .toList()
                        .map((value) => renderItem(value))
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
