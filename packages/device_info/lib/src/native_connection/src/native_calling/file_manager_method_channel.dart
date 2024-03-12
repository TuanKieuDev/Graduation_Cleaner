import 'package:device_info/src/native_connection/src/native_calling/app_manager_platform_interface.dart';
import 'package:device_info/src/native_connection/src/native_calling/file_manager_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// An implementation of [AppManagerPlatform] that uses method channels.
class FileManagerAndroid extends FileManagerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  MethodChannel methodChannel = const MethodChannel('file_manager');

  @override
  Future<String> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version ?? "";
  }

  // @override
  // Future<List<dynamic>> getAPKs() async {
  //   return await methodChannel.invokeMethod("getAPKs");
  // }

  @override
  Future<void> runPhotoAnalysisProcess() async {
    await methodChannel.invokeMethod("runPhotoAnalysisProcess");
  }

  @override
  Future<List<Map<dynamic, dynamic>>> getAllVideos() async {
    return await methodChannel
            .invokeListMethod<Map<dynamic, dynamic>>("getAllVideos") ??
        [];
  }

  @override
  Future<List<Map<dynamic, dynamic>>> getAllAudios() async {
    return await methodChannel
            .invokeListMethod<Map<dynamic, dynamic>>("getAllAudios") ??
        [];
  }

  @override
  Future<List<String>> getAllFiles(
      [String? selection, List<dynamic>? selectionArgs]) async {
    return await methodChannel.invokeListMethod<String>("getAllFiles",
            {"selection": selection, "selectionArgs": selectionArgs}) ??
        [];
  }

  @override
  Future<List<Map<dynamic, dynamic>>> getImages(
      [String? selection, List<dynamic>? selectionArgs]) async {
    return await methodChannel.invokeListMethod<Map<dynamic, dynamic>>(
            "getImages",
            {"selection": selection, "selectionArgs": selectionArgs}) ??
        [];
  }

  @override
  Future<List<String>> getAllImagesOlderThan(int epochTime) async {
    return await methodChannel.invokeListMethod<String>(
            "getAllImagesOlderThan", {"epochTime": epochTime / 1000}) ??
        [];
  }

  @override
  Future<List<Map<dynamic, dynamic>>> getAllMediaFiles() async {
    return await methodChannel
            .invokeListMethod<Map<dynamic, dynamic>>("getAllMediaFiles") ??
        [];
  }

  @override
  Future<List<Map<dynamic, dynamic>>> getLowImages() async {
    return await methodChannel
            .invokeListMethod<Map<dynamic, dynamic>>("getLowImages") ??
        [];
  }

  @override
  Future<bool> isApkInstalled(String path) {
    return Future.value(true);
  }

  @override
  Future<Map> optimizeImagePreview(
      String path, int quality, double resolutionScale) async {
    return await methodChannel.invokeMethod("optimizeImagePreview", {
          "path": path,
          "quality": quality,
          "resolutionScale": resolutionScale
        }) ??
        [];
  }

  @override
  Future<Map> optimizeImage(String path, int quality, double resolutionScale,
      bool deleteOriginal) async {
    return await methodChannel.invokeMapMethod("optimizeImage", {
          "path": path,
          "quality": quality,
          "resolutionScale": resolutionScale,
          "deleteOriginal": deleteOriginal
        }) ??
        {};
  }

  @override
  Future<List<dynamic>> getSimilarImages() async {
    return await methodChannel.invokeListMethod("getSimilarImages") ?? [];
  }

  @override
  Future<bool> isImageValid(String path) async {
    return await methodChannel.invokeMethod("isImageValid", {"path": path});
  }

  @override
  Future<bool> isOptimizableImage(String path) async {
    return await methodChannel
        .invokeMethod("isOptimizableImage", {"path": path});
  }

  @override
  Future<String> getExternalPath() async {
    return await methodChannel.invokeMethod('getExternalPath');
  }

  @override
  Future<List<Map<dynamic, dynamic>>> getApkFiles() async {
    return await methodChannel
            .invokeListMethod<Map<dynamic, dynamic>>("getApkFiles") ??
        [];
  }

  @override
  Future<List<Map<dynamic, dynamic>>> getDownloadedFiles() async {
    return await methodChannel
            .invokeListMethod<Map<dynamic, dynamic>>("getDownloadedFiles") ??
        [];
  }

  @override
  Future<Uint8List?> loadPhotoOrVideoThumbnail(
      int mediaId, int mediaType, int thumbnailSize) async {
    return await methodChannel.invokeMethod<Uint8List>(
      'loadPhotoOrVideoThumbnail',
      {
        "mediaId": mediaId,
        "mediaType": mediaType,
        "thumbnailSize": thumbnailSize
      },
    );
  }

  @override
  Future<Uint8List?> loadAudioThumbnail(String path) async {
    return await methodChannel.invokeMethod<Uint8List>(
      'loadAudioThumbnail',
      {
        "path": path,
      },
    );
  }
}
