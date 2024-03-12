import 'dart:io';
import 'dart:typed_data';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ApkThumbnailScreen extends StatefulWidget {
  const ApkThumbnailScreen({super.key});

  @override
  State<ApkThumbnailScreen> createState() => _ApkThumbnailScreenState();
}

class _ApkThumbnailScreenState extends State<ApkThumbnailScreen> {
  final _fileInfo = FileInfoManager();

  List<String> apks = [];

  String status = "Status: Scanning...";
  String result = "";

  List<Uint8List> arrayResult = [];

  getApkPaths() async {
    apks = (await FileManager().fileQuery(
      {
        SystemEntityType.apkFile: null,
      },
    ))[SystemEntityType.apkFile]!
        .map((e) => e.path)
        .toList();

    detectApkThumbnails();
  }

  Future<void> detectApkThumbnails() async {
    setState(() {
      arrayResult = [];
    });

    List<Uint8List> listValue = [];
    for (int i = 0; i < apks.length; i++) {
      listValue.add(await AppManager().getApkFileIcon(apks[i]));
    }

    setState(() {
      arrayResult = listValue;
    });
  }

  Widget renderImage(Uint8List icon) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Image.memory(
        icon,
        cacheWidth: 150,
        fit: BoxFit.contain,
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getApkPaths();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Apk Thumbnail'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: ListView(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
              child: Text("$status"),
            ),
            Column(
              children: arrayResult.map<Widget>((icon) {
                return Column(
                  children: [
                    const Divider(
                      height: 20,
                      thickness: 5,
                      color: Colors.red,
                    ),
                    Wrap(
                      children: [renderImage(icon)],
                    )
                  ],
                );
              }).toList(),
            )
          ]),
        ),
      ),
    );
  }
}
