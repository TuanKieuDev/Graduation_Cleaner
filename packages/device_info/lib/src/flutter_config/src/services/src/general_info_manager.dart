import 'dart:convert';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';

class GeneralInfoManager {
  final cleanerAppInfo = DeviceInfo();

  Future<GeneralInfo> getGeneralInfo() async {
    debugPrint('inside');
    Map<String, dynamic> value =
        json.decode(await cleanerAppInfo.getGeneralInfo());

    return Future.value(GeneralInfo.fromJson(value));
  }
}
