import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class OptimizableImageScreen extends StatefulWidget {
  const OptimizableImageScreen({super.key});

  @override
  State<OptimizableImageScreen> createState() => _OptimizableImageScreenState();
}

class _OptimizableImageScreenState extends State<OptimizableImageScreen> {
  getOptimizableImages() {
    final stopwatch = Stopwatch();
    print("TAG: Test-- query start");
    stopwatch.start();

    FileManager().fileQuery({
      SystemEntityType.optimizablePhoto: null,
    }).then((result) {
      stopwatch.stop();
      print("TAG: Test-- query end");
      print(
          "TAG: Test-- time: ${Duration(microseconds: stopwatch.elapsedMicroseconds)}");
      print(
          "TAG: Test-- array length: ${result[SystemEntityType.optimizablePhoto]?.length}");
    });
  }

  @override
  void initState() {
    super.initState();
    getOptimizableImages();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Test Optimizable Photo'),
        ),
      ),
    );
  }
}
