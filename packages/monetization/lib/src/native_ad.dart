import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:monetization/monetization.dart';

class NativeAdOptimalSize extends StatefulWidget {
  const NativeAdOptimalSize({
    this.storageId = NativeAdStorage.mediumNativeAd,
    Key? key,
    this.textColor = Colors.white,
    this.padding = EdgeInsets.zero,
    double? minWidth, // minimum recommended width
    double? minHeight, // minimum recommended height
    double? maxWidth,
    double? maxHeight,
  })  : minWidth = minWidth ?? 320,
        minHeight = minHeight ??
            (storageId == NativeAdStorage.smallNativeAd ? 90 : 200),
        maxWidth = maxWidth ?? 400,
        maxHeight = maxHeight ??
            (storageId == NativeAdStorage.smallNativeAd ? 90 : 280),
        super(key: key);

  final String storageId;
  final Color textColor;
  final double minWidth;
  final double minHeight;
  final double maxWidth;
  final double maxHeight;
  final EdgeInsets padding;

  @override
  State<NativeAdOptimalSize> createState() => _NativeAdOptimalSizeState();
}

class _NativeAdOptimalSizeState extends State<NativeAdOptimalSize> {
  NativeAd? _nativeAd;

  @override
  void initState() {
    super.initState();
    _createNativeAd();
  }

  void _createNativeAd() {
    AdManager.instance.requestNativeAd(widget.storageId, (value) {
      setState(() {
        _nativeAd = value;
        log('native ad loaded');
      });
    }, textColor: widget.textColor);
  }

  @override
  void dispose() {
    super.dispose();
    _nativeAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AdManager.instance.adRemoved) {
      return const SizedBox.shrink();
    }

    if (_nativeAd == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: widget.padding,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: widget.minWidth,
          minHeight: widget.minHeight,
          maxWidth: widget.maxWidth,
          maxHeight: widget.maxHeight,
        ),
        child: AdWidget(
          ad: _nativeAd!,
        ),
      ),
    );
  }
}
