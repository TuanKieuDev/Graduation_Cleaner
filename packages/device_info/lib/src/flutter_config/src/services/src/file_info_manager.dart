import 'dart:convert';

import 'package:device_info/device_info.dart';

class FileInfoManager {
  final cleanerAppInfo = DeviceInfo();

  Future<List<FileInfo>> getDownloads() async {
    String values = await cleanerAppInfo.getDownloads();

    List<FileInfo> fileInfo = (jsonDecode(values) as List)
        .map((data) => FileInfo.fromJson(data))
        .toList();

    return fileInfo;
  }

  Future<List<FileInfo>> getAPKFiles() async {
    String values = await cleanerAppInfo.getAPKFiles();

    List<FileInfo> apkFile = (jsonDecode(values) as List)
        .map((data) => FileInfo.fromJson(data))
        .toList();

    return apkFile;
  }

  Future<String> deleteFile(String path) async {
    String values = await cleanerAppInfo.deleteFile(path);

    return values;
  }

  Future<String> deleteListFiles(List<String> listPaths) async {
    String values = await cleanerAppInfo.deleteListFiles(listPaths);

    return values;
  }

  Future<List<FileInfo>> getAllImages() async {
    String values = await cleanerAppInfo.getAllImages();

    List<FileInfo> allImages = (jsonDecode(values) as List)
        .map((data) => FileInfo.fromJson(data))
        .toList();

    return allImages;
  }

  Future<List<FileInfo>> getAllAudios() async {
    String values = await cleanerAppInfo.getAllAudios();

    List<FileInfo> allAudios = (jsonDecode(values) as List)
        .map((data) => FileInfo.fromJson(data))
        .toList();

    return allAudios;
  }

  Future<List<FileInfo>> getAllVideos() async {
    String values = await cleanerAppInfo.getAllVideos();

    List<FileInfo> allVideos = (jsonDecode(values) as List)
        .map((data) => FileInfo.fromJson(data))
        .toList();

    return allVideos;
  }

  Future<List<FileInfo>> getAllMediaFiles() async {
    String values = await cleanerAppInfo.getAllMediaFiles();

    List<FileInfo> allMediaFiles = (jsonDecode(values) as List)
        .map((data) => FileInfo.fromJson(data))
        .toList();

    return allMediaFiles;
  }

  Future<List<FileInfo>> getDuplicateFiles() async {
    String values = await cleanerAppInfo.getDuplicateFiles();

    List<FileInfo> allDuplicateFiles = (jsonDecode(values) as List)
        .map((data) => FileInfo.fromJson(data))
        .toList();

    return allDuplicateFiles;
  }

  Future<List<FileInfo>> getAllFiles() async {
    String values = await cleanerAppInfo.getAllFiles();

    List<FileInfo> allFiles = (jsonDecode(values) as List)
        .map((data) => FileInfo.fromJson(data))
        .toList();

    return allFiles;
  }

  Future<List<FileInfo>> getLargeVideos() async {
    String values = await cleanerAppInfo.getLargeVideos();

    List<FileInfo> largeVideos = (jsonDecode(values) as List)
        .map((data) => FileInfo.fromJson(data))
        .toList();

    return largeVideos;
  }

  Future<List<FileInfo>> getAllOtherFiles() async {
    String values1 = await cleanerAppInfo.getAllFiles();
    List<FileInfo> allFiles = (jsonDecode(values1) as List)
        .map((data) => FileInfo.fromJson(data))
        .toList();
    String values2 = await cleanerAppInfo.getAllMediaFiles();
    List<FileInfo> allMediaFiles = (jsonDecode(values2) as List)
        .map((data) => FileInfo.fromJson(data))
        .toList();

    List<FileInfo> difference =
        allFiles.toSet().difference(allMediaFiles.toSet()).toList();

    return difference;
  }

  Future<List<FileInfo>> getOldImages() async {
    String values1 = await cleanerAppInfo.getOldImagesBetween1Month();

    List<FileInfo> oldImagesBetween1Month = (jsonDecode(values1) as List)
        .map((data) => FileInfo.fromJson(data))
        .toList();

    return oldImagesBetween1Month;
  }

  Future<List<FileInfo>> getOldLargeFiles() async {
    String values1 = await cleanerAppInfo.getOldLargeFilesBetween6Month();

    List<FileInfo> getOldLargeFilesBetween6Month = (jsonDecode(values1) as List)
        .map((data) => FileInfo.fromJson(data))
        .where((element) => element.size >= 100000000)
        .toList();

    return getOldLargeFilesBetween6Month;
  }

  Future<List<FileInfo>> getOptimizeImages() async {
    String values2 = await cleanerAppInfo.getAllImages();

    List<FileInfo> allImages = (jsonDecode(values2) as List)
        .map((data) => FileInfo.fromJson(data))
        .where((element) =>
            element.path.contains("Camera") ||
            element.path.contains("Pictures"))
        .toList();

    return allImages;
  }

  Future<Map> getSimilarImages(
      double similarityLevel, int minSize, void Function(List) callback) async {
    Map values = await cleanerAppInfo.getSimilarImages(
        similarityLevel, minSize, callback);

    return values;
  }

  Future<List<FileInfo>> getBadImages() async {
    String values = await cleanerAppInfo.getBadImages();

    List<FileInfo> badImages = (jsonDecode(values) as List)
        .map((data) => FileInfo.fromJson(data))
        .toList();

    return badImages;
  }

  Future<List<FileInfo>> getSensitiveImages() async {
    String values = await cleanerAppInfo.getSensitiveImages();

    List<FileInfo> sensitiveImages = (jsonDecode(values) as List)
        .map((data) => FileInfo.fromJson(data))
        .toList();

    return sensitiveImages;
  }

  Future<bool> isImageValid(String path) async {
    return await cleanerAppInfo.isImageValid(path);
  }

  Future<List> getOptimizableImages() async {
    return await cleanerAppInfo.getOptimizableImages();
  }

  Future<List> optimizeImagePreview(String path, String fileNameToSave,
      int quality, double resolutionScale) async {
    List values = await cleanerAppInfo.optimizeImagePreview(
        path, fileNameToSave, quality, resolutionScale);

    return values;
  }

  Future<int> optimizeImages(List paths, int quality, double resolutionScale,
      bool deleteOriginal, String packageName) async {
    int values = await cleanerAppInfo.optimizeImages(
        paths, quality, resolutionScale, deleteOriginal, packageName);

    return values;
  }

  Future<String> optimizeInterface(
      String path, bool isChange, int quality) async {
    String values =
        await cleanerAppInfo.optimizeInterface(path, isChange, quality);

    return values;
  }

  Future<List<FileInfo>> getLargeFiles() async {
    String values = await cleanerAppInfo.getLargeFiles();

    List<FileInfo> largeFiles = (jsonDecode(values) as List)
        .map((data) => FileInfo.fromJson(data))
        .toList();

    return largeFiles;
  }
}
