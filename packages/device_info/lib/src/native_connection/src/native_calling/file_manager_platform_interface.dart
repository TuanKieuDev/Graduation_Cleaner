import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'device_info_method_channel.dart';
import 'file_manager_method_channel.dart';

abstract class FileManagerPlatform extends PlatformInterface {
  /// Constructs a CleanerAppInfoPlatform.
  FileManagerPlatform() : super(token: _token);

  static final Object _token = Object();

  static FileManagerPlatform _instance = FileManagerAndroid();

  /// The default instance of [AppManagerPlatform] to use.
  ///
  /// Defaults to [MethodChannelDeviceInfo].
  static FileManagerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AppManagerPlatform] when
  /// they register themselves.
  static set instance(FileManagerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String> getPlatformVersion() {
    return Future.value('1.0.0');
  }

  Future<String> getExternalPath();

  Future<void> runPhotoAnalysisProcess();

  Future<bool> isApkInstalled(String path);

  Future<List<Map<dynamic, dynamic>>> getLowImages();

  Future<bool> isImageValid(String path);

  Future<bool> isOptimizableImage(String path);

  Future<Map> optimizeImagePreview(
      String path, int quality, double resolutionScale);

  Future<Map> optimizeImage(
      String path, int quality, double resolutionScale, bool deleteOriginal);

  Future<List<dynamic>> getSimilarImages();

  Future<List<Map<dynamic, dynamic>>> getImages(
      [String? selection, List<dynamic>? selectionArgs]);

  Future<List<Map<dynamic, dynamic>>> getAllAudios();

  Future<List<Map<dynamic, dynamic>>> getAllVideos();

  Future<List<Map<dynamic, dynamic>>> getAllMediaFiles();

  Future<List<Map<dynamic, dynamic>>> getApkFiles();

  Future<List<Map<dynamic, dynamic>>> getDownloadedFiles();

  Future<Uint8List?> loadPhotoOrVideoThumbnail(
      int mediaId, int mediaType, int thumbnailSize);

  Future<Uint8List?> loadAudioThumbnail(String path);
}
