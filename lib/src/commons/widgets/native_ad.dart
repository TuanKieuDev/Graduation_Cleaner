import 'package:flutter/material.dart';
import 'package:monetization/monetization.dart';

enum NativeAdSize {
  auto,
  small,
  big,
}

class NativeAd extends StatelessWidget {
  const NativeAd({
    super.key,
    this.size = NativeAdSize.auto,
    this.padding = EdgeInsets.zero,
  });

  final NativeAdSize size;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) {
    return NativeAdOptimalSize(
      padding: padding,
      storageId: size.toStorageId(),
      minHeight: size == NativeAdSize.small ? 50 : 250,
      maxHeight: size == NativeAdSize.small ? 50 : 250,
    );
  }
}

extension on NativeAdSize {
  String toStorageId() {
    switch (this) {
      case NativeAdSize.small:
        return 'small_native_ad';
      case NativeAdSize.big:
        return 'big_native_ad';
      case NativeAdSize.auto:
        return 'big_native_ad';
    }
  }
}
