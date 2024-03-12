import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'device_info_method_channel.dart';

abstract class DeviceInfoPlatform extends PlatformInterface {
  /// Constructs a CleanerAppInfoPlatform.
  DeviceInfoPlatform() : super(token: _token);

  static final Object _token = Object();

  static DeviceInfoPlatform _instance = MethodChannelDeviceInfo();

  /// The default instance of [DeviceInfoPlatform] to use.
  ///
  /// Defaults to [MethodChannelDeviceInfo].
  static DeviceInfoPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DeviceInfoPlatform] when
  /// they register themselves.
  static set instance(DeviceInfoPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<T> invokeMethod<T>(String method, [dynamic arguments]);

  Future<List<dynamic>> getAllApplications() =>
      invokeMethod("getAllApplications");

  // Future<String> getAllApplications() => invokeMethod("getAllApplications");

  Future<String> getApplicationLabel(String packageName);

  Future<Uint8List> getApplicationIconBitmap(String packageName);

  /* This is Example */

  Future<String> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /* Home Info */

  Future<String> getGeneralInfo() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /* Media Info */

  Future<String> getListAppInfo() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /* Quick Clean Info */

  Future<String> getDownloads() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String> getThumbnails() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String> getAPKFiles() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String> getEmptyFolders() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String> getVisibleCaches() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String> getAppData() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String> getHiddenCaches() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String> deleteFile(String path) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String> deleteListFiles(List<String> listPaths) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String> killApp() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String> getAllImages() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String> getRunningApp() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String> getAllAudios() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String> getAllVideos() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String> getAllMediaFiles() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String> getDuplicateFiles() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String> getAllFiles() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String> getLargeVideos() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<Map> getSimilarImages(
      double similarityLevel, int minSize, void Function(List) callback) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  // Future<String> getSimilar2Images(String path1, String path2) {
  //   throw UnimplementedError('platformVersion() has not been implemented.');
  // }

  Future<String> getOldImagesBetween1Month() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String> getOldLargeFilesBetween6Month() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String> getAllMediaFolders() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String> getBadImages() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String> getSensitiveImages() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool> isImageValid(String path) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<List> getOptimizableImages() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<List> optimizeImagePreview(
      String path, String fileNameToSave, int quality, double resolutionScale) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<int> optimizeImages(List paths, int quality, double resolutionScale,
      bool deleteOriginal, String packageName) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String> getIconPackage(String package) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<int> getUsageDataApps(String package) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String> timelineUsageStats(String package, int usageManager) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String> getAllSize() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String> getUsageLast7Days() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String> getUsageLast24Hours() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String> getIconFolderApp(String name) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String> optimizeInterface(String path, bool isChange, int quality) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String> getLargeFiles() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String> checkPermissionUsage() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String> checkPermissionAllStorage() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String> checkPermissionStorage() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
