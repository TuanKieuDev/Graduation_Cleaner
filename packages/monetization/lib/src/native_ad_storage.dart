import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'package:flutter/material.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';
import 'package:monetization/src/ad_unit_container.dart';

import 'ad_helper.dart';
import 'ad_manager.dart';

class NativeAdStorage {
  static const String smallNativeAd = 'optimal_size_native_ad_view_flat';
  static const String mediumNativeAd = 'optimal_size_native_ad_view';

  NativeAdStorage({
    required String factoryId,
    required this.maxSize,
    Map<String, Object>? customOptions,
    AdRequest request = const AdRequest(),
  })  : templateType = factoryId == smallNativeAd
            ? TemplateType.small
            : factoryId == mediumNativeAd
                ? TemplateType.medium
                : null,
        factoryId = factoryId != smallNativeAd && factoryId != mediumNativeAd
            ? factoryId
            : null {
    _request = request;
    _customOptions = customOptions;
    _createNativeAd();
  }

  NativeAdStorage.template({
    this.templateType,
    required this.maxSize,
    Map<String, Object>? customOptions,
    AdRequest request = const AdRequest(),
    Logger? logger,
  }) : factoryId = null {
    _request = request;
    _customOptions = customOptions;
    _createNativeAd();
  }

  Map<String, Object>? _customOptions;

  final String? factoryId;
  final TemplateType? templateType;
  late AdRequest _request;
  int maxSize;

  int _numNativeAdsLoadAttempts = 0;

  final Queue<NativeAd> _nativeAdQueue = Queue<NativeAd>();
  final AdUnitContainer _adUnitContainer = AdUnitContainer(AdHelper.native);

  Map<String, Object>? get customOptions => _customOptions;

  void updateSizeAndOptions(int size, value) {
    maxSize = size;
    if (value != _customOptions) {
      _customOptions = value;
      _nativeAdQueue.clear();
    }

    if (size > maxSize) {
      _createNativeAd();
    }
  }

  set customOptions(Map<String, Object>? value) {
    if (value == _customOptions) {
      return;
    }

    _customOptions = value;

    _nativeAdQueue.clear();
    _createNativeAd();
  }

  void changeSize(int size) {
    maxSize = size;
    if (_nativeAdQueue.length > maxSize) {
      _createNativeAd();
    }
  }

  void requestNativeAd(ValueSetter<NativeAd> onAdLoaded) {
    if (_nativeAdQueue.isNotEmpty) {
      var ad = _nativeAdQueue.removeFirst();
      onAdLoaded.call(ad);

      if (_nativeAdQueue.length < 3) _createNativeAd();
      return;
    }

    _createNativeAd(
      () => requestNativeAd(onAdLoaded),
    );
  }

  void _createNativeAd([VoidCallback? onAdLoaded]) {
    if (AdManager.instance.adRemoved) {
      log('NativeAd is requested but will not be loaded.');
    }
    NativeAd(
      adUnitId: _adUnitContainer.getId(),
      factoryId: factoryId,
      request: _request,
      customOptions: customOptions,
      nativeTemplateStyle: templateType == null
          ? null
          : NativeTemplateStyle(
              // Required: Choose a template.
              templateType: templateType!,
            ),
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          log('NativeAd loaded.');
          _nativeAdQueue.add(ad as NativeAd);
          onAdLoaded?.call();
          _numNativeAdsLoadAttempts = 0;
          if (_nativeAdQueue.length < maxSize) {
            Future.delayed(
              AdHelper.failedLoadTimeout * _numNativeAdsLoadAttempts,
              () => _createNativeAd(),
            );
          }
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          log('NativeAd failed to load: ${error.message}');

          final hasNext = _adUnitContainer.changeToAnother();
          if (hasNext) {
            _createNativeAd(onAdLoaded);
            return;
          }

          _numNativeAdsLoadAttempts++;
          if (_numNativeAdsLoadAttempts < AdHelper.maxFailedLoadAttempts) {
            Future.delayed(
              AdHelper.failedLoadTimeout,
              () => _createNativeAd(onAdLoaded),
            );
          }
        },
        onAdOpened: (Ad ad) => log('NativeAd opened.'),
        onAdClosed: (Ad ad) => log('NativeAd closed.'),
        onAdImpression: (Ad ad) => log('NativeAd impression.'),
        onAdClicked: (Ad ad) => log('NativeAd clicked.'),
      ),
    ).load();
    // _nativeAd!.load();
  }
}
