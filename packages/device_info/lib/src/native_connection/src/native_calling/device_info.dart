import 'device_info_platform_interface.dart';

class DeviceInfo {
  /* This is Example */

  Future<String> getPlatformVersion() {
    return DeviceInfoPlatform.instance.getPlatformVersion();
  }

  /* Home Info */

  Future<String> getGeneralInfo() {
    return DeviceInfoPlatform.instance.getGeneralInfo();
  }

  /* Media Info */

  Future<String> getListAppInfo() {
    return DeviceInfoPlatform.instance.getListAppInfo();
  }

  /* Quick Clean Info */

  Future<String> getDownloads() {
    return DeviceInfoPlatform.instance.getDownloads();
  }

  Future<String> getThumbnails() {
    return DeviceInfoPlatform.instance.getThumbnails();
  }

  Future<String> getAPKFiles() {
    return DeviceInfoPlatform.instance.getAPKFiles();
  }

  Future<String> getEmptyFolders() {
    return DeviceInfoPlatform.instance.getEmptyFolders();
  }

  Future<String> getVisibleCaches() {
    return DeviceInfoPlatform.instance.getVisibleCaches();
  }

  Future<String> getAppData() {
    return DeviceInfoPlatform.instance.getAppData();
  }

  Future<String> getHiddenCaches() {
    return DeviceInfoPlatform.instance.getHiddenCaches();
  }

  Future<String> deleteFile(String path) {
    return DeviceInfoPlatform.instance.deleteFile(path);
  }

  Future<String> deleteListFiles(List<String> listPaths) {
    return DeviceInfoPlatform.instance.deleteListFiles(listPaths);
  }

  Future<String> killApp() {
    return DeviceInfoPlatform.instance.killApp();
  }

  Future<String> getRunningApp() {
    return DeviceInfoPlatform.instance.getRunningApp();
  }

  Future<String> getAllImages() {
    return DeviceInfoPlatform.instance.getAllImages();
  }

  Future<String> getAllAudios() {
    return DeviceInfoPlatform.instance.getAllAudios();
  }

  Future<String> getAllVideos() {
    return DeviceInfoPlatform.instance.getAllVideos();
  }

  Future<String> getAllMediaFiles() {
    return DeviceInfoPlatform.instance.getAllMediaFiles();
  }

  Future<String> getDuplicateFiles() {
    return DeviceInfoPlatform.instance.getDuplicateFiles();
  }

  Future<String> getAllFiles() {
    return DeviceInfoPlatform.instance.getAllFiles();
  }

  Future<Map> getSimilarImages(
      double similarityLevel, int minSize, void Function(List) callback) {
    return DeviceInfoPlatform.instance
        .getSimilarImages(similarityLevel, minSize, callback);
  }

  // Future<String> getSimilar2Images(String path1, String path2) {
  //   return CleanerAppInfoPlatform.instance.getSimilar2Images(path1, path2);
  // }

  Future<String> getOldImagesBetween1Month() {
    return DeviceInfoPlatform.instance.getOldImagesBetween1Month();
  }

  Future<String> getOldLargeFilesBetween6Month() {
    return DeviceInfoPlatform.instance.getOldLargeFilesBetween6Month();
  }

  Future<String> getLargeVideos() {
    return DeviceInfoPlatform.instance.getLargeVideos();
  }

  Future<String> getAllMediaFolders() {
    return DeviceInfoPlatform.instance.getAllMediaFolders();
  }

  Future<String> getBadImages() {
    return DeviceInfoPlatform.instance.getBadImages();
  }

  Future<String> getSensitiveImages() {
    return DeviceInfoPlatform.instance.getSensitiveImages();
  }

  Future<bool> isImageValid(String path) async {
    return DeviceInfoPlatform.instance.isImageValid(path);
  }

  Future<List> getOptimizableImages() async {
    return DeviceInfoPlatform.instance.getOptimizableImages();
  }

  Future<List> optimizeImagePreview(
      String path, String fileNameToSave, int quality, double resolutionScale) {
    return DeviceInfoPlatform.instance
        .optimizeImagePreview(path, fileNameToSave, quality, resolutionScale);
  }

  Future<int> optimizeImages(List paths, int quality, double resolutionScale,
      bool deleteOriginal, String packageName) {
    return DeviceInfoPlatform.instance.optimizeImages(
        paths, quality, resolutionScale, deleteOriginal, packageName);
  }

  Future<String> getIconPackage(String package) {
    return DeviceInfoPlatform.instance.getIconPackage(package);
  }

  Future<int> getUsageDataApps(String package) {
    return DeviceInfoPlatform.instance.getUsageDataApps(package);
  }

  Future<String> timelineUsageStats(String package, int usageManager) {
    return DeviceInfoPlatform.instance
        .timelineUsageStats(package, usageManager);
  }

  Future<String> getAllSize() {
    return DeviceInfoPlatform.instance.getAllSize();
  }

  Future<String> getUsageLast24Hours() {
    return DeviceInfoPlatform.instance.getUsageLast24Hours();
  }

  Future<String> getUsageLast7Days() {
    return DeviceInfoPlatform.instance.getUsageLast7Days();
  }

  Future<String> getIconFolderApp(String name) {
    return DeviceInfoPlatform.instance.getIconFolderApp(name);
  }

  Future<String> optimizeInterface(String path, bool isChange, int quality) {
    return DeviceInfoPlatform.instance
        .optimizeInterface(path, isChange, quality);
  }

  Future<String> getLargeFiles() {
    return DeviceInfoPlatform.instance.getLargeFiles();
  }

  Future<String> checkPermissionUsage() {
    return DeviceInfoPlatform.instance.checkPermissionUsage();
  }

  Future<String> checkPermissionAllStorage() {
    return DeviceInfoPlatform.instance.checkPermissionAllStorage();
  }

  Future<String> checkPermissionStorage() {
    return DeviceInfoPlatform.instance.checkPermissionStorage();
  }
}
