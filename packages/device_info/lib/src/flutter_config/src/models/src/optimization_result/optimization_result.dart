import 'package:device_info/device_info.dart';

class OptimizationResult {
  late FileInfo? originalPhotoWithNewPath;
  late FileInfo optimizedPhoto;
  late int savedSpaceInBytes;

  OptimizationResult({
    required this.originalPhotoWithNewPath,
    required this.optimizedPhoto,
    required this.savedSpaceInBytes,
  });
}
