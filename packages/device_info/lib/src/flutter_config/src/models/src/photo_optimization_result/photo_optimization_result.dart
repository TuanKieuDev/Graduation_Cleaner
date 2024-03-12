import 'dart:typed_data';

class PhotoOptimizationResult {
  late int beforeSize;
  late int afterSize;
  late Uint8List optimizedImage;

  PhotoOptimizationResult({
    required this.beforeSize,
    required this.afterSize,
    required this.optimizedImage,
  });
}
