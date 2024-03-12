import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info/device_info.dart';
import 'package:permission_handler/permission_handler.dart';

class AppSizeTestView extends StatefulWidget {
  const AppSizeTestView({super.key});

  @override
  State<AppSizeTestView> createState() => _AppSizeTestViewState();
}

class _AppSizeTestViewState extends State<AppSizeTestView> {
  List<PackageInfo> listApps = [];
  int index = 0;

  Uint8List? afterBitmap;
  String textInfor = "Null";
  String appSizeDetail = "";
  String? pathImage;

  int quality = 85;
  double scaleValue = 1;
  int sdkInt = 33;

  @override
  void initState() {
    super.initState();
    _requestAllStoragePermission();
  }

  Future _requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (status.isGranted) {
    } else if (status.isDenied) {
      if (await Permission.storage.request().isGranted) {}
    }
  }

  Future getAllApp() async {
    List<PackageInfo> result = await AppManager().getAllApplications();
    setState(() {
      listApps = result;
      textInfor = "";
      for (var element in result) {
        textInfor += "${element.packageName}\n";
      }
    });
  }

  Future getAppSize(int index) async {
    if (index >= listApps.length) {
      return;
    }
    var result =
        await AppManager().getAppSize(listApps[index].packageName, (result) {
      // callback for android api < 26
      setState(() {
        appSizeDetail =
            "PackageName: ${result.packageName}\nApp Size: ${getReadableFileSize(result.appSize)}\nData Size: ${getReadableFileSize(result.dataSize)}\nCache Size: ${getReadableFileSize(result.cacheSize)}\nTotal: ${getReadableFileSize(result.appSize + result.cacheSize + result.dataSize)}}";
      });
    });

    setState(() {
      appSizeDetail =
          "PackageName: ${result.packageName}\nApp Size: ${getReadableFileSize(result.appSize)}\nData Size: ${getReadableFileSize(result.dataSize)}\nCache Size: ${getReadableFileSize(result.cacheSize)}\nTotal: ${getReadableFileSize(result.appSize + result.cacheSize + result.dataSize)}}";
    });
  }

  String getReadableFileSize(int size) {
    if (size == 0) {
      return "0";
    }
    var units = ["B", "KB", "MB", "GB", "TB"];
    var digitGroups = log(size.toDouble()) ~/ log(1024.0);
    return "${(size / pow(1024.0, digitGroups.toDouble())).toStringAsFixed(2)} ${units[digitGroups]}";
  }

  Future _requestAllStoragePermission() async {
    var status = await Permission.manageExternalStorage.status;
    if (status.isGranted) {
    } else if (status.isDenied) {
      if (await Permission.manageExternalStorage.request().isGranted) {}
    }
  }

  Future<void> initPlatformState() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(textInfor),
              Text(appSizeDetail),
              if (listApps.isNotEmpty)
                Slider(
                  value: index.toDouble(),
                  max: listApps.length.toDouble(),
                  divisions: listApps.length.toInt(),
                  label: index.toString(),
                  onChanged: (double value) {
                    setState(() {
                      index = value.toInt();
                    });
                  },
                ),
              ElevatedButton(
                onPressed: () => {_requestStoragePermission()},
                child: const Text(
                  "Request",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => {getAllApp()},
                child: const Text(
                  "Get PackageNames",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => {getAppSize(index)},
                child: const Text(
                  "Get App Size",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
