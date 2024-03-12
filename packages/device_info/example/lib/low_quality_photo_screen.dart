import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class LowQualityPhotoScreen extends StatefulWidget {
  const LowQualityPhotoScreen({super.key});

  @override
  State<LowQualityPhotoScreen> createState() => _LowQualityPhotoScreenState();
}

class _LowQualityPhotoScreenState extends State<LowQualityPhotoScreen> {
  final _fileInfo = FileInfoManager();

  List<String> _allImages = [];

  String status = "Status: Scanning...";
  String result = "";
  bool isDetecting = false;

  List<String> arrayResult = [];

  int similarityLevel = 95;
  int minSize = 200;

  Future<void> getAllImages() async {
    List<String> platformVersion;

    platformVersion =
        (await FileManager().getAllImages()).map((e) => e.path).toList();
    setState(() {
      _allImages = platformVersion;
    });
  }

  void requestStoragePermission() async {
    if (!Platform.isAndroid) {
      return;
    }
    //var androidInfo = await DeviceInfoPlugin().androidInfo;
    //var sdkInt = androidInfo.version.sdkInt;
    var sdkInt = 33;

    Permission permission;
    if (sdkInt < 33) {
      permission = Permission.storage;
    } else {
      permission = Permission.photos;
    }
    if (await permission.status.isGranted) {
      getAllImages().then((value) {
        setState(() {
          status = "Number of photos: ${_allImages.length}";
        });
      });
    } else if (await permission.status.isDenied) {
      var result = await permission.request();
      if (result.isGranted) {
        getAllImages().then((value) {
          setState(() {
            status = "Number of photos: ${_allImages.length}";
          });
        });
      }
    }
  }

  Future<void> detectLowQualityPhotos() async {
    if (isDetecting) return;

    setState(() {
      isDetecting = true;
      arrayResult = [];
    });

    var listValue = await FileManager().getLowImages();

    setState(() {
      isDetecting = false;
      arrayResult = listValue.map((e) => e.path).toList();
    });
  }

  Widget renderImage(String path) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Image.file(
        File(path),
        cacheWidth: 150,
        fit: BoxFit.contain,
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllImages().then((value) {
      setState(() {
        status = "Number of photos: ${_allImages.length}";
      });
    });
    detectLowQualityPhotos();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Similar Photo'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: ListView(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
              child: Text("$status"),
            ),
            ElevatedButton(
              onPressed: () => detectLowQualityPhotos(),
              child: Text(isDetecting ? "Detecting" : "Detect"),
            ),
            Text(result),
            Column(
              children: arrayResult.map<Widget>((path) {
                return Column(
                  children: [
                    const Divider(
                      height: 20,
                      thickness: 5,
                      color: Colors.red,
                    ),
                    Wrap(
                      children: [renderImage(path)],
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
