import 'dart:collection';
import 'dart:developer';
import 'dart:io';

import 'package:cleaner_app_info_example/apk_thumnails_test.dart';
import 'package:cleaner_app_info_example/last_app_usage_test.dart';
import 'package:cleaner_app_info_example/notification_count_test.dart';
import 'package:cleaner_app_info_example/app_growing_test.dart';
import 'package:cleaner_app_info_example/app_size_test.dart';
import 'package:cleaner_app_info_example/app_usage_test.dart';
import 'package:cleaner_app_info_example/battery_analysis_test.dart';
import 'package:cleaner_app_info_example/low_quality_photo_screen.dart';
import 'package:cleaner_app_info_example/notifications/notification.dart';
import 'package:cleaner_app_info_example/notifications/notifications_test_view.dart';
import 'package:cleaner_app_info_example/optimizable_images_test.dart';
import 'package:cleaner_app_info_example/similar_photo_screen.dart';
import 'package:cleaner_app_info_example/thumbnail_test.dart';
import 'package:cleaner_app_info_example/uninstall_detection_test.dart';
import 'package:cleaner_app_info_example/unncessary_data/app_unncessary_data_test_view.dart';
import 'package:cleaner_app_info_example/work_manager_service/work_manager_service_test_view.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:mime/mime.dart' as mime;
import 'package:permission_handler/permission_handler.dart';

import 'folder_test.dart';

void localNotificationInit() {
  NotificationService.initialize(flutterLocalNotificationsPlugin);
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // use for show local notification
  localNotificationInit();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: Test()),
    ),
  );
}

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  Widget? content;
  final fileManager = FileManager();

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    requestPermissions();

    //FileManager().runPhotoAnalysisProcess();
  }

  void requestPermissions() async {
    await requestStoragePermission();
    await requestAllFilePermission();
  }

  Future requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (status.isGranted) {
    } else if (status.isDenied) {
      if (await Permission.storage.request().isGranted) {
      } else {}
    }
  }

  Future requestAllFilePermission() async {
    var status = await Permission.manageExternalStorage.status;
    if (status.isGranted) {
    } else if (status.isDenied) {
      if (await Permission.manageExternalStorage.request().isGranted) {}
    }
  }

  void _setContent<T>(Future<List<T>> future, [split = false]) {
    setState(() => content = FolderManagerTest(
          future: future,
          split: split,
        ));
  }

  Future<List<String>> _getAllFilesNonRecursive() async {
    var clock = Stopwatch()..start();
    FileSystemEntity dir = Directory("/storage/emulated/0");
    var entities = Queue<FileSystemEntity>();
    var futures = Queue<Future>();

    var result = <String>[];

    while (entities.isNotEmpty || futures.isNotEmpty) {
      if (entities.isEmpty) {
        await futures.removeFirst();
        continue;
      }
      dir = entities.removeFirst();
      if (dir is Directory) {
        try {
          final dirFuture = dir.list().toList().then((subDir) {
            entities.addAll(subDir);
            var statFuture = dir.stat().then((value) {
              result.add(FolderInfo(
                      name: p.basename(dir.path),
                      itemCount: subDir.length,
                      size: value.size,
                      path: dir.path,
                      lastModified: value.modified)
                  .toString());
            });
            futures.add(statFuture);
          }).onError((error, stackTrace) {
            result.add(FolderInfo(
                    name: p.basename(dir.path),
                    itemCount: 0,
                    size: 0,
                    path: dir.path,
                    lastModified: DateTime.now())
                .toString());
          });
          futures.add(dirFuture);
          // ignore: empty_catches
        } on Exception {}
      } else if (dir is File) {
        var length = dir.length();
        var lastModified = dir.lastModified();

        var future = Future.wait([length, lastModified]).then((value) =>
            result.add(FileInfo(
                    mediaId: 0,
                    mediaType: 0,
                    mimeType: mime.lookupMimeType(dir.path),
                    name: p.basename(dir.path),
                    path: dir.path,
                    size: value[0] as int,
                    extension: p.extension(dir.path),
                    lastModified: (value[1] as DateTime))
                .toString()));

        futures.add(future);
        // result.add(FileInfo(
        //         mimeType: mime.lookupMimeType(dir.path),
        //         name: p.basename(dir.path),
        //         path: dir.path,
        //         size: dir.lengthSync(),
        //         extension: p.extension(dir.path),
        //         lastModifiedInMillis:
        //             dir.lastModifiedSync().millisecondsSinceEpoch)
        //     .toString());
      }
    }

    clock.stop();
    log(clock.elapsedMilliseconds.toString());

    return result;
  }

  Future<List<String>> _getAllFiles() async {
    Stopwatch stopwatch = Stopwatch()..start();
    var dir = Directory("/storage/emulated/0");
    // var audios = await FileManager.getVideos();
    var result = await dir
        .list(recursive: true, followLinks: true)
        .handleError((e) => debugPrint(e.message))
        // .where((event) => event is File)
        // .cast<File>()
        // .where((event) => mime.lookupMimeType(event.path)?.startsWith("video") ?? false)
        .map((event) {
      if (event is File) {
        return FileInfo(
                mediaId: 0,
                mediaType: 0,
                mimeType: mime.lookupMimeType(event.path),
                name: p.basename(event.path),
                path: event.path,
                size: event.lengthSync(),
                extension: p.extension(event.path),
                lastModified: event.lastModifiedSync())
            .toString();
      }

      if (event is Directory) {
        try {
          // int itemCount = await event.list().length;

          return FolderInfo(
                  name: p.basename(event.path),
                  itemCount: event.listSync().length,
                  size: event.statSync().size,
                  path: event.path,
                  lastModified: DateTime.now())
              .toString();
        } on Exception {
          return FolderInfo(
                  name: "permission error",
                  itemCount: -1,
                  size: -1,
                  path: event.path,
                  lastModified: DateTime.now())
              .toString();
        }
      }
      return "";
    }).toList();

    stopwatch.stop();

    // debugPrint(result.toSet().difference(audios.toSet()).join(", \n"));
    debugPrint('elapsed: ${stopwatch.elapsedMilliseconds}');
    return result;
  }

  Future<List<String>> getAllApplications() async {
    Stopwatch stopwatch = Stopwatch()..start();

    var appManager = AppManager();
    final allApplications = await appManager.getAllApplications();
    final futures = <Future>[];
    for (var i = 0; i < allApplications.length; i++) {
      final future = appManager.getLabel(allApplications[i].packageName).then(
          (value) => allApplications[i] =
              allApplications[i].copyWith(description: value));
      futures.add(future);
      futures.add(appManager.getIcon(allApplications[i].packageName));
    }

    await Future.wait(futures);
    stopwatch.stop();
    print(stopwatch.elapsedMilliseconds);
    return allApplications.map((e) => e.toString()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: GridView.extent(
                maxCrossAxisExtent: 120,
                children: [
                  TextButton(
                    onPressed: () => _setContent(_getAllFiles(), true),
                    child: const Text("getAllFilesFlutter"),
                  ),
                  TextButton(
                    onPressed: () =>
                        _setContent(_getAllFilesNonRecursive(), true),
                    child: const Text("getAllFilesFlutterNonRecursive"), //
                  ),
                  TextButton(
                    onPressed: () => _setContent(getAllApplications(), true),
                    child: const Text("getAllApplications"), //
                  ),
                ],
              ),
            ),
            const Text("Test của Cường ở dưới"),
            Expanded(
              child: GridView.extent(
                maxCrossAxisExtent: 100,
                children: [
                  TextButton(
                    onPressed: () =>
                        setState(() => content = const AppUsageTest()),
                    child: const Text("app_usage"), //
                  ),
                  TextButton(
                    onPressed: () =>
                        setState(() => content = const AppSizeTest()),
                    child: const Text("app_size"),
                  ),
                  TextButton(
                    onPressed: () =>
                        setState(() => content = const SimilarPhotoScreen()),
                    child: const Text("similar_photo"),
                  ),
                  TextButton(
                    onPressed: () =>
                        setState(() => content = const LowQualityPhotoScreen()),
                    child: const Text("low_quality_photo"),
                  ),
                  TextButton(
                    onPressed: () =>
                        setState(() => content = const AppGrowingTest()),
                    child: const Text("app_growing"),
                  ),
                  TextButton(
                    onPressed: () =>
                        setState(() => content = const BatteryAnalysisTest()),
                    child: const Text("battery_analysis"),
                  ),
                  TextButton(
                    onPressed: () =>
                        setState(() => content = const NotificationUsageTest()),
                    child: const Text("notification_number"),
                  ),
                  TextButton(
                    onPressed: () =>
                        setState(() => content = const LastAppUsageTest()),
                    child: const Text("last_app_usage"),
                  ),
                  TextButton(
                    onPressed: () => setState(
                        () => content = const UninstallDetectionTest()),
                    child: const Text("uninstall_detection"),
                  ),
                  TextButton(
                    onPressed: () =>
                        setState(() => content = const ApkThumbnailScreen()),
                    child: const Text("apk_thumbnail"),
                  ),
                  TextButton(
                    onPressed: () =>
                        setState(() => content = const ThumbnailMediaScreen()),
                    child: const Text("thumbnail_test"),
                  ),
                  TextButton(
                    onPressed: () => setState(
                        () => content = const OptimizableImageScreen()),
                    child: const Text("optimizable_photos"),
                  ),
                ],
              ),
            ),
            const Text("Test của Trung ở dưới"),
            Expanded(
              child: GridView.extent(
                maxCrossAxisExtent: 120,
                children: [
                  TextButton(
                    onPressed: () =>
                        setState(() => content = const NotificationTestView()),
                    child: const Text("Show Notification"),
                  ),
                  TextButton(
                    onPressed: () => setState(
                        () => content = const WorkManagerServiceTestView()),
                    child: const Text("Show WorkManager"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (content) =>
                              const AppUnncessaryDataTestView(),
                        ),
                      );
                    },
                    child: const Text("Show Unnecessary Data"),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (content != null)
          Container(
            color: Colors.white,
            child: content,
          ),
        if (content != null)
          FloatingActionButton.small(
              onPressed: () => setState(() {
                    content = null;
                  })),
      ],
    );
  }
}
