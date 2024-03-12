import 'dart:typed_data';

import 'package:device_info/device_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCleanerAppInfoPlatform
    with MockPlatformInterfaceMixin
    implements DeviceInfoPlatform {
  @override
  Future<String> getPlatformVersion() => Future.value('42');
  @override
  Future<String> getGeneralInfo() => Future.value("");
  @override
  Future<String> getListAppInfo() => Future.value("");
  @override
  Future<String> getDownloads() => Future.value("");
  @override
  Future<String> getThumbnails() => Future.value("");
  @override
  Future<String> getAPKFiles() => Future.value("");
  @override
  Future<String> getEmptyFolders() => Future.value("");
  @override
  Future<String> getAppData() => Future.value("");
  @override
  Future<String> getVisibleCaches() => Future.value("");
  @override
  Future<String> getHiddenCaches() => Future.value("");
  @override
  Future<String> deleteFile(String path) => Future.value("");
  @override
  Future<String> deleteListFiles(List<String> listPaths) => Future.value("");
  @override
  Future<String> killApp() => Future.value("");
  @override
  Future<String> getAllImages() => Future.value("");
  @override
  Future<String> getRunningApp() => Future.value("");
  @override
  Future<String> getAllAudios() => Future.value("");
  @override
  Future<String> getAllVideos() => Future.value("");
  @override
  Future<String> getAllMediaFiles() => Future.value("");
  @override
  Future<String> getAllFiles() => Future.value("");
  @override
  // @override
  // Future<String> getSimilar2Images(path1, path2) => Future.value("");
  @override
  Future<String> getOldImagesBetween1Month() => Future.value("");
  @override
  Future<String> getOldLargeFilesBetween6Month() => Future.value("");
  @override
  Future<String> getLargeVideos() => Future.value("");
  @override
  Future<String> getAllMediaFolders() => Future.value("");
  @override
  Future<String> getBadImages() => Future.value("");
  @override
  Future<String> getSensitiveImages() => Future.value("");

  @override
  Future<String> getIconPackage(String package) => Future.value("");
  @override
  Future<int> getUsageDataApps(String package) => Future.value(0);
  @override
  Future<String> timelineUsageStats(String package, int usageManager) =>
      Future.value("");
  @override
  Future<String> getAllSize() => Future.value("");
  @override
  Future<String> getUsageLast24Hours() => Future.value("");
  @override
  Future<String> getUsageLast7Days() => Future.value("");
  @override
  Future<String> getIconFolderApp(String name) => Future.value("");
  @override
  Future<String> optimizeInterface(String path, bool isChange, int quality) =>
      Future.value("");
  @override
  Future<String> getLargeFiles() => Future.value("");
  @override
  Future<String> getDuplicateFiles() => Future.value("");
  @override
  Future<String> checkPermissionUsage() => Future.value("");
  @override
  Future<String> checkPermissionAllStorage() => Future.value("");
  @override
  Future<String> checkPermissionStorage() => Future.value("");

  @override
  Future<List<Map<String, dynamic>>> getAllApplications() {
    // TODO: implement getAllApplications
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> getApplicationIconBitmap(String packageName) {
    // TODO: implement getApplicationIconBitmap
    throw UnimplementedError();
  }

  @override
  Future<String> getApplicationLabel(String packageName) {
    // TODO: implement getApplicationLabel
    throw UnimplementedError();
  }

  @override
  Future<T> invokeMethod<T>(String method, [arguments]) {
    // TODO: implement invokeMethod
    throw UnimplementedError();
  }

  @override
  Future<bool> checkIfImageValid(String path) {
    // TODO: implement checkIfImageValid
    throw UnimplementedError();
  }

  @override
  Future<List> getOptimizableImages() {
    // TODO: implement getOptimizableImages
    throw UnimplementedError();
  }

  @override
  Future<Map> getSimilarImages(
      double similarityLevel, int minSize, void Function(List p1) callback) {
    // TODO: implement getSimilarImages
    throw UnimplementedError();
  }

  @override
  Future<List> optimizeImagePreview(
      String path, String fileNameToSave, int quality, double resolutionScale) {
    // TODO: implement optimizeImagePreview
    throw UnimplementedError();
  }

  @override
  Future<int> optimizeImages(List paths, int quality, double resolutionScale,
      bool deleteOriginal, String packageName) {
    // TODO: implement optimizeImages
    throw UnimplementedError();
  }

  @override
  Future<bool> isImageValid(String path) {
    // TODO: implement isImageValid
    throw UnimplementedError();
  }
}

void main() {
  final DeviceInfoPlatform initialPlatform = DeviceInfoPlatform.instance;

  test('$MethodChannelDeviceInfo is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelDeviceInfo>());
  });

  test('getPlatformVersion', () async {
    DeviceInfo cleanerAppInfoPlugin = DeviceInfo();
    MockCleanerAppInfoPlatform fakePlatform = MockCleanerAppInfoPlatform();
    DeviceInfoPlatform.instance = fakePlatform;

    expect(await cleanerAppInfoPlugin.getPlatformVersion(), '42');
  });
}
