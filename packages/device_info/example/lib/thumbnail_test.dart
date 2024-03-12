import 'dart:io';
import 'dart:typed_data';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ThumbnailMediaScreen extends StatefulWidget {
  const ThumbnailMediaScreen({super.key});

  @override
  State<ThumbnailMediaScreen> createState() => _ThumbnailMediaScreenState();
}

class Utils {
  late String pathImage;
  late Uint8List thumbnail;

  Utils({required this.pathImage, required this.thumbnail});
}

class _ThumbnailMediaScreenState extends State<ThumbnailMediaScreen> {
  final _fileInfo = FileInfoManager();

  List<String> _allImages = [];
  List<String> _allVideos = [];
  List<String> _allAudios = [];

  String type = "Image";

  String status = "Status: Scanning...";
  String result = "";
  bool isDetecting = false;

  List<Uint8List> arrayResult = [];

  int similarityLevel = 95;
  int minSize = 200;

  Future<List<String>> getAllImages() async {
    return (await FileManager().getAllImages()).map((e) => e.path).toList();
  }

  Future<List<String>> getAllVideos() async {
    return (await FileManager().getAllVideos()).map((e) => e.path).toList();
  }

  Future<List<String>> getAllAudios() async {
    return (await FileManager().getAllAudios()).map((e) => e.path).toList();
  }

  Future<void> detectImageThumbnail() async {}

  Future<void> detectVideoThumbnail() async {}

  Future<void> detectAudioThumbnail() async {}

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllImages().then((value) {
      setState(() {
        status = "Number of photos: ${value.length}";
        _allImages = value;
      });
      detectImageThumbnail();
    });

    getAllVideos().then((value) {
      setState(() {
        _allVideos = value;
      });
    });

    getAllAudios().then((value) {
      setState(() {
        _allAudios = value;
        print(": lissssss: ${value.length}");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Thumbnail Test'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
              child: Text("$status"),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => setState(() {
                    type = "Image";
                    detectImageThumbnail();
                  }),
                  child: Container(
                    child: Text(
                      "Image",
                      style: TextStyle(
                          fontSize: 16,
                          backgroundColor: type == "Image" ? Colors.red : null),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => setState(() {
                    type = "Video";
                    detectVideoThumbnail();
                  }),
                  child: Text(
                    "Video",
                    style: TextStyle(
                        fontSize: 16,
                        backgroundColor: type == "Video" ? Colors.red : null),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => setState(() {
                    type = "Audio";
                    detectAudioThumbnail();
                  }),
                  child: Text(
                    "Audio",
                    style: TextStyle(
                        fontSize: 16,
                        backgroundColor: type == "Audio" ? Colors.red : null),
                  ),
                ),
              ],
            ),
            Expanded(
              child: GridView.builder(
                itemCount: arrayResult.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  return SizedBox(
                    height: 300,
                    child: Image.memory(
                      arrayResult[index],
                      filterQuality: FilterQuality.low,
                      cacheHeight: 120,
                      height: 120,
                    ),
                  );
                },
              ),
            )
          ]),
        ),
      ),
    );
  }
}
