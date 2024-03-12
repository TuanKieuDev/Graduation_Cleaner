import 'package:flutter/material.dart';
import 'package:device_info/device_info.dart';

class UninstallDetectionTest extends StatefulWidget {
  const UninstallDetectionTest({super.key});

  @override
  State<UninstallDetectionTest> createState() => _UninstallDetectionTestState();
}

class _UninstallDetectionTestState extends State<UninstallDetectionTest> {
  @override
  void initState() {
    registerPackageRemovedReceiver();
  }

  registerPackageRemovedReceiver() {
    AppManager().registerPackageRemovedReceiver(onReceive: (removedPackage) {
      print("Removed Package: $removedPackage");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: const Padding(
          padding: EdgeInsets.all(10),
        ),
      ),
    );
  }
}
