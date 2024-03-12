import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:monetization/src/ad_interval.dart';
import 'package:monetization/src/admob/admob_ad_manager.dart';
import 'package:monetization/src/ironsource/ironsource_ad_manager.dart';
import 'package:monetization/src/native_ad_storage.dart';

enum AdType { appOpen, interstitial, rewarded, rewardedInterstitial, banner }

class AdManager {
  static final AdManager _instance = AdManager();

  static AdManager get instance => _instance;

  static const AdRequest request = AdRequest();

  final _adLoadedStreamController = StreamController<AdType>.broadcast();
  late Stream<AdType> adLoaded = _adLoadedStreamController.stream;

  final _adDismissedStreamController = StreamController<AdType>.broadcast();
  late Stream<AdType> adDismissedStream = _adDismissedStreamController.stream;

  final _adShowFailedStreamController = StreamController<AdType>();
  late Stream<AdType> onAdShowFailedStream =
      _adShowFailedStreamController.stream;

  final _adShowedStreamController = StreamController<AdType>.broadcast();
  late Stream<AdType> adShowedStream = _adShowedStreamController.stream;

  final AdInterval interstitialInterval = AdInterval();

  bool adRemoved = false;
  bool showOpenAdOnFirstOpen = true;

  final Map<String, NativeAdStorage> _nativeAdStorages = {};

  late AdmobAdManager _admobManager;
  late IronSourceAdManager _ironSourceAdManager;

  bool _initialized = false;
  bool get initialized => _initialized;

  Future<void> initialize() async {
    interstitialInterval.updateAdShowedTime();
    adDismissedStream.listen((adType) {
      if (adType == AdType.interstitial) {
        interstitialInterval.updateAdShowedTime();
      }
    });

    _admobManager = AdmobAdManager();
    var adMobInit = _admobManager.init();

    _ironSourceAdManager = IronSourceAdManager();
    var ironSourceInit = _ironSourceAdManager.init();

    // adopen streams
    _admobManager.appOpenAdManager.adLoadedStream
        .listen(_adLoadedStreamController.add);
    _admobManager.appOpenAdManager.adDismissedStream
        .listen(_adDismissedStreamController.add);
    _admobManager.appOpenAdManager.adFailedToShowFullScreenContentStream
        .listen(_adShowFailedStreamController.add);
    _admobManager.appOpenAdManager.adShowedFullScreenContentStream
        .listen(_adShowedStreamController.add);

    // interstitial streams
    _ironSourceAdManager.interstitialManager.adLoadedStream
        .listen(_adLoadedStreamController.add);
    _ironSourceAdManager.interstitialManager.adDismissedStream
        .listen(_adDismissedStreamController.add);
    _ironSourceAdManager
        .interstitialManager.adFailedToShowFullScreenContentStream
        .listen(_adShowFailedStreamController.add);
    _ironSourceAdManager.interstitialManager.adShowedFullScreenContentStream
        .listen(_adShowedStreamController.add);

    await Future.wait([adMobInit, ironSourceInit]);
    _initialized = true;
  }

  void preventAdFor(Duration duration) {
    adRemoved = true;
    Future.delayed(duration).then((value) {
      adRemoved = false;
    });
  }

  void openAdInspector(OnAdInspectorClosedListener listener) {
    MobileAds.instance.openAdInspector(
      (p0) => listener(AdInspectorError(
        code: p0?.code,
        domain: p0?.domain,
        message: p0?.message,
      )),
    );
  }

  void showAds(AdType adType, [String? placement]) {
    if (adRemoved) {
      log('$adType is requested but ad is removed');
      return;
    }

    switch (adType) {
      case AdType.appOpen:
        showAdOpen();
        break;
      case AdType.interstitial:
        showInterstitial(placement);
        break;
      default:
        throw UnsupportedError(
            "$adType is currently not supported or should not be called by this method");
    }
  }

  void showAdOpen() {
    _admobManager.appOpenAdManager.showAd();
  }

  void showInterstitial([String? placementName]) {
    if (!interstitialInterval.shouldShowAd()) {
      log('InterstitialAd is not shown due to time difference is too short!');
      return;
    }

    if (!_ironSourceAdManager.interstitialManager.isReady) {
      log('InterstitialAd is not ready!');
    }

    _ironSourceAdManager.interstitialManager
        .showAd(placementName: placementName);
  }

  void listenToAndOpenAdOnAppStateChanges() {
    _admobManager.appOpenAdManager.listenToAndOpenAdOnAppStateChanges();
  }

  void showBanner(int offset) {
    if (adRemoved) {
      hideBanner();
    }
    _ironSourceAdManager.bannerManager.showBanner(offset);
  }

  void hideBanner() {
    _ironSourceAdManager.bannerManager.hideBanner();
  }

  void requestNativeAd(String factoryId, ValueSetter<NativeAd> onAdLoaded,
      {Color textColor = Colors.white}) {
    if (adRemoved) {
      return;
    }

    log('native ad $factoryId requested');
    if (!_nativeAdStorages.containsKey(factoryId)) {
      log('$factoryId not found in the storage. Creating one...');
      createNativeAdWithId(factoryId, size: 1, textColor: textColor);
    } else if (_nativeAdStorages[factoryId]!.customOptions != null &&
        _nativeAdStorages[factoryId]!.customOptions!['textColor']! !=
            _toHexRGBFromColor(textColor)) {
      createNativeAdWithId(factoryId, size: 1, textColor: textColor);
    }

    _nativeAdStorages[factoryId]!.requestNativeAd(onAdLoaded);
  }

  void createNativeAdWithId(
    String factoryId, {
    int size = 1,
    Color textColor = Colors.white,
  }) {
    if (_nativeAdStorages.containsKey(factoryId)) {
      _nativeAdStorages[factoryId]!.updateSizeAndOptions(
          size, {'textColor': _toHexRGBFromColor(textColor)});
      return;
    }

    _nativeAdStorages[factoryId] = NativeAdStorage(
      factoryId: factoryId,
      maxSize: size,
      request: request,
      customOptions: {'textColor': _toHexRGBFromColor(textColor)},
    );
  }

  String _toHexRGBFromColor(Color color) {
    return '#${_toHexRBG(color.red)}${_toHexRBG(color.green)}${_toHexRBG(color.blue)}';
  }

  String _toHexRBG(int colorChannelValue) {
    return colorChannelValue.toRadixString(16).padLeft(2, '0');
  }
}

typedef OnAdInspectorClosedListener = void Function(AdInspectorError?);

/// Error information about why the ad inspector failed.
class AdInspectorError {
  /// Create an AdInspectorError with the given code, domain and message.
  AdInspectorError({
    this.code,
    this.domain,
    this.message,
  });

  /// Code to identifier the error.
  final String? code;

  /// The domain from which the error came.
  final String? domain;

  /// A message detailing the error.
  final String? message;
}
