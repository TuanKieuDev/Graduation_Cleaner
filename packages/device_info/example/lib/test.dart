import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info/device_info.dart';
import 'package:permission_handler/permission_handler.dart';

import 'similar_photo_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // ignore: unused_field

  String _platformVersion = 'Unknown';
  final _cleanerAppInfoPlugin = DeviceInfo();

  final String _notificationDelete = '';
  final String _freeUpMemory = '';
  String path1 = '/storage/emulated/0/DCIM/Camera/IMG20220715222707.jpg';
  List<String> _allImages = [];
  final QuickBoostInfoOptimization _killApp = const QuickBoostInfoOptimization(
      beforeRam: 0, afterRam: 0, ramOptimized: 0);

  //final ImagePicker _picker = ImagePicker();

  final _generalInfo = GeneralInfoManager();
  final _appInfo = AppInfoManager();
  final _folderInfo = FolderInfoManager();
  final _appInfoSize = AppInfoSizeManager();
  final _appInfoUsage = AppInfoUsageManager();

  final cleanerAppInfo = DeviceInfo();

  Uint8List? afterBitmap;
  String textInfo = "Null";
  // String pathImage =
  //     "/storage/emulated/0/Download/bg_optimized_optimized_optimized_optimized.jpg";

  String pathImage = "";

  int process = 0;
  int total = 20;

  int quality = 85;
  double scaleValue = 1;
  int sdkInt = 33;

  @override
  void initState() {
    super.initState();
    _requestStoragePermission();
    _requestAllStoragePermission();
  }

  Future _requestStoragePermission() async {
    var status = await Permission.photos.status;
    if (status.isGranted) {
      getAllImages();
    } else if (status.isDenied) {
      if (await Permission.photos.request().isGranted) {
        getAllImages();
      }
    }
  }

  Future _requestAllStoragePermission() async {
    var status = await Permission.manageExternalStorage.status;
    if (status.isGranted) {
      getAllImages();
    } else if (status.isDenied) {
      if (await Permission.manageExternalStorage.request().isGranted) {
        getAllImages();
      }
    }
  }

  Future<void> initPlatformState() async {
    String platformVersion;

    try {
      platformVersion = await _cleanerAppInfoPlugin.getPlatformVersion();
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> getAllImages() async {
    List<String> platformVersion;

    platformVersion =
        (await FileManager().getAllImages()).map((e) => e.path).toList();

    setState(() {
      _allImages = platformVersion;
      textInfo = "";
      for (var element in platformVersion) {
        textInfo += "$element\n";
      }
    });
  }

  Future<void> compress() async {
    if (pathImage == null) return;

    if (!await FileManager().isImageValid(pathImage)) {
      debugPrint("Image is invalid");
      return;
    }

    var photoOptimizationResult = await FileManager()
        .optimizeImagePreview(pathImage, "", quality, scaleValue);

    setState(() {
      textInfo =
          "\nBefore: ${photoOptimizationResult.beforeSize}   , After: ${photoOptimizationResult.afterSize}\n";
      afterBitmap = photoOptimizationResult.optimizedImage;
    });
  }

  Future<void> save() async {
    StreamController<OptimizationResult> streamController =
        StreamController<OptimizationResult>.broadcast();

    streamController.stream.listen(
      (data) {
        setState(() {
          process += 1;
        });
      },
      onDone: () {
        setState(() {
          process = 0;
          total = 10;
        });
      },
    );

    process = 0;
    total = 10;

    FileManager().optimizeImages(
        _allImages.sublist(0, total), quality, scaleValue, false);

    // setState(() {
    //   textInfo = "";
    //   if (data.originalPhotoWithNewPath != null) {
    //     textInfo += data.originalPhotoWithNewPath.toString();
    //     textInfo += "\n\n";
    //   }
    //   textInfo += data.optimizedPhoto.toString();
    //   textInfo += "\n\n";
    //   textInfo += "${"\nSaved space: ${data.savedSpaceInBytes}"} bytes\n";
    // });
  }

  // Future<void> deleteFile() async {
  //   bool result = await FileManager().deleteFile(pathImage!);

  //   if (result) {
  //     debugPrint("The file has been deleted");
  //   } else {
  //     debugPrint("The file has not been deleted");
  //   }
  // }

  // Future<void> pickImage() async {
  //   final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
  //   setState(() {
  //     afterBitmap = null;
  //     textInfo = "";
  //     pathImage = image?.path;
  //     pathImage = "/storage/emulated/0/Download/test777.jpg";
  //   });
  // }

  // Future<void> getOptimizableImage() async {
  //   final List<FolderOrFileInfo> result = (await FileManager().query(
  //     {
  //       SystemEntityType.optimizablePhoto: null,
  //       SystemEntityType.visibleCache: null,
  //     },
  //   ))[SystemEntityType.optimizablePhoto] as List<FolderOrFileInfo>;
  //   if (result == null) {
  //     return;
  //   }
  //   textInfo = "";
  //   debugPrint(result);
  //   setState(() {
  //     result.forEach((element) {
  //       textInfo += "${element.path}\n";
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (pathImage.isNotEmpty)
                      Image.file(
                        File(pathImage),
                        width: MediaQuery.of(context).size.width / 2 - 20,
                        height: MediaQuery.of(context).size.height / 3,
                        fit: BoxFit.contain,
                      ),
                    if (afterBitmap != null)
                      Image.memory(
                        afterBitmap!,
                        width: MediaQuery.of(context).size.width / 2 - 20,
                        height: MediaQuery.of(context).size.height / 3,
                        fit: BoxFit.contain,
                      )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: Text("Quality: $quality"),
                ),
                Slider(
                  value: quality.toDouble(),
                  max: 100,
                  divisions: 20,
                  label: quality.toString(),
                  onChanged: (double value) {
                    setState(() {
                      quality = value.toInt();
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: Text("Optimization Process: $process/$total"),
                ),
                Slider(
                  value: process.toDouble(),
                  max: total.toDouble(),
                  onChanged: (double value) {},
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll<Color>(
                            scaleValue == 1.5 ? Colors.green : Colors.grey),
                      ),
                      onPressed: () => setState(() {
                        scaleValue = 1.5;
                      }),
                      child: const Text(
                        "1.5x",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll<Color>(
                            scaleValue == 1.25 ? Colors.green : Colors.grey),
                      ),
                      onPressed: () => setState(() {
                        scaleValue = 1.25;
                      }),
                      child: const Text(
                        "1.25x",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll<Color>(
                            scaleValue == 1 ? Colors.green : Colors.grey),
                      ),
                      onPressed: () => setState(() {
                        scaleValue = 1;
                      }),
                      child: const Text(
                        "1x",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll<Color>(
                            scaleValue == 0.75 ? Colors.green : Colors.grey),
                      ),
                      onPressed: () => setState(() {
                        scaleValue = 0.75;
                      }),
                      child: const Text(
                        "0.75x",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => compress(),
                  child: const Text(
                    "Compress",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => save(),
                  child: const Text(
                    "Save",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                // ElevatedButton(
                //   onPressed: () => pickImage(),
                //   child: const Text(
                //     "Pick a photo",
                //     style: TextStyle(
                //       fontSize: 16,
                //     ),
                //   ),
                // ),
                // ElevatedButton(
                //   onPressed: () => deleteFile(),
                //   child: const Text(
                //     "Delete",
                //     style: TextStyle(
                //       fontSize: 16,
                //     ),
                //   ),
                // ),
                // ElevatedButton(
                //   onPressed: () => getOptimizableImage(),
                //   child: const Text(
                //     "getOptimizableImage",
                //     style: TextStyle(
                //       fontSize: 16,
                //     ),
                //   ),
                // ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SimilarPhotoScreen()));
                  },
                  child: const Text(
                    "Test Similar Photos",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
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
                Text(textInfo),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> getListImg(List<FileInfo> listImagePath) {
    List<Widget> listImages = [];
    for (var imagePath in listImagePath) {
      listImages.add(
        Container(
          padding: const EdgeInsets.all(8),
          child: Image.file(File(imagePath.path), fit: BoxFit.cover),
        ),
      );
    }
    return listImages;
  }
}
