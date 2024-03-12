import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'device_info_platform_interface.dart';

/// An implementation of [DeviceInfoPlatform] that uses method channels.
class MethodChannelDeviceInfo extends DeviceInfoPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  MethodChannel methodChannel = const MethodChannel('device_info');

  @override
  Future<String> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version ?? "";
  }

  @override
  Future<T> invokeMethod<T>(String method, [dynamic arguments]) async =>
      (await methodChannel.invokeMethod<T>(method, arguments))!;

  @override
  Future<List<dynamic>> getAllApplications() =>
      invokeMethod("getAllApplications");

  // @override
  // Future<String> getAllApplications() => invokeMethod("getAllApplications");

  @override
  Future<String> getApplicationLabel(String packageName) async =>
      await invokeMethod<String>(
          "getApplicationLabel", {"packageName": packageName});

  @override
  Future<Uint8List> getApplicationIconBitmap(String packageName) async =>
      await invokeMethod<Uint8List>(
          "getApplicationIconBitmap", {"packageName": packageName});

  /* Home Info */

  @override
  Future<String> getGeneralInfo() async {
    final version = await methodChannel.invokeMethod<String>('getGeneralInfo');
    return version ?? "";
  }

  /* Media Info */

  @override
  Future<String> getListAppInfo() async {
    final version = await methodChannel.invokeMethod<String>('getListAppInfo');
    return version ?? "";
  }

  /* Quick Clean Info */

  @override
  Future<String> getDownloads() async {
    final version = await methodChannel.invokeMethod<String>('getDownloads');
    return version ?? "";
  }

  @override
  Future<String> getThumbnails() async {
    final version = await methodChannel.invokeMethod<String>('getThumbnails');
    return version ?? "";
  }

  @override
  Future<String> getAppData() async {
    final version = await methodChannel.invokeMethod<String>('getAppData');
    return version ?? "";
  }

  @override
  Future<String> getAPKFiles() async {
    final version = await methodChannel.invokeMethod<String>('getAPKFiles');
    return version ?? "";
  }

  @override
  Future<String> getEmptyFolders() async {
    final version = await methodChannel.invokeMethod<String>('getEmptyFolders');
    return version ?? "";
  }

  @override
  Future<String> getVisibleCaches() async {
    final version =
        await methodChannel.invokeMethod<String>('getVisibleCaches');
    return version ?? "";
  }

  @override
  Future<String> getHiddenCaches() async {
    final version = await methodChannel.invokeMethod<String>('getHiddenCaches');
    return version ?? "";
  }

  @override
  Future<String> deleteFile(String path) async {
    final version =
        await methodChannel.invokeMethod<String>('deleteFile', {"path": path});
    return version ?? "";
  }

  @override
  Future<String> deleteListFiles(List<String> listPaths) async {
    final version = await methodChannel
        .invokeMethod<String>('deleteListFiles', {"listPaths": listPaths});
    return version ?? "";
  }

  /* Quick boost Function */

  @override
  Future<String> killApp() async {
    final version = await methodChannel.invokeMethod<String>('killApp');
    return version ?? "";
  }

  @override
  Future<String> getRunningApp() async {
    final version = await methodChannel.invokeMethod<String>('getRunningApp');
    return version ?? "";
  }

  /* File Clearing Info */

  @override
  Future<String> getAllImages() async {
    final version = await methodChannel.invokeMethod<String>('getAllImages');
    return version ?? "";
  }

  @override
  Future<String> getAllAudios() async {
    final version = await methodChannel.invokeMethod<String>('getAllAudios');
    return version ?? "";
  }

  @override
  Future<String> getAllVideos() async {
    final version = await methodChannel.invokeMethod<String>('getAllVideos');
    return version ?? "";
  }

  @override
  Future<String> getAllMediaFiles() async {
    final version =
        await methodChannel.invokeMethod<String>('getAllMediaFiles');
    return version ?? "";
  }

  @override
  Future<String> getDuplicateFiles() async {
    final version =
        await methodChannel.invokeMethod<String>('getDuplicateFiles');
    return version ?? "";
  }

  @override
  Future<String> getAllFiles() async {
    final version = await methodChannel.invokeMethod<String>('getAllFiles');
    return version ?? "";
  }

  @override
  Future<String> getLargeVideos() async {
    final version = await methodChannel.invokeMethod<String>('getLargeVideos');
    return version ?? "";
  }

  /* File Clearing Function */

  @override
  Future<Map> getSimilarImages(
      double similarityLevel, int minSize, void Function(List) callback) async {
    methodChannel.setMethodCallHandler((call) {
      switch (call.method) {
        case "getSimilarImagesResult":
          final List result = call.arguments;
          callback(result);
      }
      var t;
      return t;
    });
    final version = await methodChannel.invokeMethod<Map>('getSimilarImages',
        {"similarityLevel": similarityLevel, "minSize": minSize});
    return version ?? Map();
  }

  // @override
  // Future<String> getSimilar2Images(String path1, String path2) async {
  //   final version = await methodChannel.invokeMethod<String>(
  //       'getSimilar2Images', {"path1": path1, "path2": path2});
  //   return version ?? "";
  // }

  @override
  Future<String> getOldImagesBetween1Month() async {
    final version =
        await methodChannel.invokeMethod<String>('getOldImagesBetween1Month');
    return version ?? "";
  }

  @override
  Future<String> getOldLargeFilesBetween6Month() async {
    final version = await methodChannel
        .invokeMethod<String>('getOldLargeFilesBetween6Month');
    return version ?? "";
  }

  @override
  Future<String> getAllMediaFolders() async {
    final version =
        await methodChannel.invokeMethod<String>('getAllMediaFolders');
    return version ?? "";
  }

  @override
  Future<String> getBadImages() async {
    final version = await methodChannel.invokeMethod<String>('getBadImages');
    return version ?? "";
  }

  @override
  Future<String> getSensitiveImages() async {
    final version =
        await methodChannel.invokeMethod<String>('getSensitiveImages');
    return version ?? "";
  }

  @override
  Future<bool> isImageValid(String path) async {
    final result =
        await methodChannel.invokeMethod<bool>('isImageValid', {"path": path});
    return result ?? false;
  }

  @override
  Future<List> getOptimizableImages() async {
    final result =
        await methodChannel.invokeMethod<List>('getOptimizableImages');
    return result ?? [];
  }

  @override
  Future<List> optimizeImagePreview(String path, String fileNameToSave,
      int quality, double resolutionScale) async {
    final version =
        await methodChannel.invokeMethod<List>('optimizeImagePreview', {
      "path": path,
      "fileNameToSave": fileNameToSave,
      "quality": quality,
      "resolutionScale": resolutionScale,
    });
    return version ?? [];
  }

  @override
  Future<int> optimizeImages(List paths, int quality, double resolutionScale,
      bool deleteOriginal, String packageName) async {
    final version = await methodChannel.invokeMethod<int>('optimizeImages', {
      "paths": paths,
      "quality": quality,
      "resolutionScale": resolutionScale,
      "deleteOriginal": deleteOriginal,
      "packageName": packageName,
    });
    return version ?? 0;
  }

  @override
  Future<String> getIconPackage(String package) async {
    final version = await methodChannel
        .invokeMethod<String>('getIconPackage', {"package": package});
    return version ?? "";
  }

  @override
  Future<int> getUsageDataApps(String package) async {
    final version = await methodChannel
        .invokeMethod<int>('getUsageDataApps', {"package": package});
    return version ?? 0;
  }

  @override
  Future<String> timelineUsageStats(String package, int usageManager) async {
    final version = await methodChannel.invokeMethod<String>(
        'timelineUsageStats',
        {"package": package, "usageManager": usageManager});
    return version ?? "";
  }

  @override
  Future<String> getAllSize() async {
    final version = await methodChannel.invokeMethod<String>('getAllSize');
    return version ?? "";
  }

  @override
  Future<String> getUsageLast24Hours() async {
    final version =
        await methodChannel.invokeMethod<String>('getUsageLast24Hours');
    return version ?? "";
  }

  @override
  Future<String> getUsageLast7Days() async {
    final version =
        await methodChannel.invokeMethod<String>('getUsageLast7Days');
    return version ?? "";
  }

  @override
  Future<String> getIconFolderApp(String name) async {
    final version = await methodChannel
        .invokeMethod<String>('getIconFolderApp', {"name": name});
    return version ?? "";
  }

  @override
  Future<String> optimizeInterface(
      String path, bool isChange, int quality) async {
    final version = await methodChannel.invokeMethod<String>(
        'optimizeInterface',
        {"path": path, "isChange": isChange, "quality": quality});
    return version ?? "";
  }

  @override
  Future<String> getLargeFiles() async {
    final version = await methodChannel.invokeMethod<String>('getLargeFiles');
    return version ?? "";
  }

  @override
  Future<String> checkPermissionUsage() async {
    final version =
        await methodChannel.invokeMethod<String>('checkPermissionUsage');
    return version ?? "";
  }

  @override
  Future<String> checkPermissionAllStorage() async {
    final version =
        await methodChannel.invokeMethod<String>('checkPermissionAllStorage');
    return version ?? "";
  }

  @override
  Future<String> checkPermissionStorage() async {
    final version =
        await methodChannel.invokeMethod<String>('checkPermissionStorage');
    return version ?? "";
  }
}
