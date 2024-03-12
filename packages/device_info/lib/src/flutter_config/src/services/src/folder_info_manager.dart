import 'dart:convert';

import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';

class FolderInfoManager {
  final cleanerAppInfo = DeviceInfo();

  Future<List<FolderInfo>> getThumbnails() async {
    String values = await cleanerAppInfo.getThumbnails();

    List<FolderInfo> folderInfo = (jsonDecode(values) as List)
        .map((data) => FolderInfo.fromJson(data))
        .toList();

    // debugPrint("This is test : $fileInfo");

    return folderInfo;
  }

  Future<List<FolderInfo>> getEmptyFolders() async {
    String values = await cleanerAppInfo.getEmptyFolders();

    List<FolderInfo> folderInfo = (jsonDecode(values) as List)
        .map((data) => FolderInfo.fromJson(data))
        .toList();

    // debugPrint("This is test : $fileInfo");

    return folderInfo;
  }

  Future<List<FolderInfo>> getVisibleCaches() async {
    String values = await cleanerAppInfo.getVisibleCaches();

    List<FolderInfo> visibleCache = (jsonDecode(values) as List)
        .map((data) => FolderInfo.fromJson(data))
        .toList();

    return visibleCache;
  }

  Future<List<FolderInfo>> getAppData() async {
    String values = await cleanerAppInfo.getAppData();

    List<FolderInfo> appData = (jsonDecode(values) as List)
        .map((data) => FolderInfo.fromJson(data))
        .toList();

    return appData;
  }

  Future<List<FolderInfo>> getAllMediaFolders() async {
    String values = await cleanerAppInfo.getAllMediaFolders();

    List<FolderInfo> allMediaFolders = (jsonDecode(values) as List)
        .map((data) => FolderInfo.fromJson(data))
        .toList();

    return allMediaFolders;
  }

  Future<Uint8List> getIconFolderApp(String name) async {
    String values = await cleanerAppInfo.getIconFolderApp(name);

    return base64Decode(values);
  }
}
