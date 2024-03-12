import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:ironsource_mediation/ironsource_mediation.dart';
import 'package:monetization/src/ad_loader_mixin.dart';
import 'package:monetization/src/ad_manager.dart';
import 'package:monetization/src/ironsource/ironsource_ad_helper.dart';

class IronSourceAdManager {
  late IronSourceInterstitialManager interstitialManager;
  late IronSourceBannerManager bannerManager;

  IronSourceAdManager() {
    IronSource.setFlutterVersion('3.7.7');
    if (kDebugMode) {
      IronSource.validateIntegration();
      IronSource.setAdaptersDebug(true);
    }
  }

  Future init() async {
    bannerManager = IronSourceBannerManager();
    interstitialManager = IronSourceInterstitialManager();
    await IronSource.init(
      appKey: IronSourceAdHelper.appKey,
      adUnits: [IronSourceAdUnit.Interstitial, IronSourceAdUnit.Banner],
    );
    interstitialManager.load();
    bannerManager.load();
  }
}

class IronSourceInterstitialManager
    with IronSourceInterstitialListener, AdLoaderMixin {
  bool _isReady = false;
  bool _isLoading = false;

  bool get isReady => _isReady;

  IronSourceInterstitialManager() {
    IronSource.setISListener(this);
  }

  @override
  Future<void> load() async {
    if (_isLoading) return Future.value();
    _isLoading = true;
    return IronSource.loadInterstitial();
  }

  Future showAd({String? placementName}) {
    if (!isReady) return Future.value();
    return IronSource.showInterstitial(placementName: placementName);
  }

  @override
  void onInterstitialAdClicked() {
    log('interstitial clicked');
  }

  @override
  void onInterstitialAdClosed() {
    onAdDismissed();
    load();
    log('interstitial closed');
  }

  @override
  void onInterstitialAdLoadFailed(IronSourceError error) {
    _isLoading = false;
    retryLoading();
    log('interstitial load failed with error code ${error.errorCode} and message ${error.message}');
  }

  @override
  void onInterstitialAdOpened() {
    log('interstitial open');
  }

  @override
  void onInterstitialAdReady() {
    _isReady = true;
    _isLoading = false;
    onAdLoadSucceeded();
    log('interstitial ready');
  }

  @override
  void onInterstitialAdShowFailed(IronSourceError error) {
    onAdShowFailed();
    log('interstitial show failed with error code ${error.errorCode} and message ${error.message}');
  }

  @override
  void onInterstitialAdShowSucceeded() {
    onAdShowed();
    log('interstitial show succeeded');
  }

  @override
  AdType get adType => AdType.interstitial;
}

class IronSourceBannerManager with IronSourceBannerListener, AdLoaderMixin {
  IronSourceBannerManager() {
    IronSource.setBNListener(this);
  }

  int _offset = 0;
  bool _visible = false;
  final bool _isReady = false;

  bool get isReady => _isReady;

  @override
  Future<void> load() async {
    await IronSource.destroyBanner();
    return IronSource.loadBanner(
      size: IronSourceBannerSize.BANNER,
      position: IronSourceBannerPosition.Bottom,
      verticalOffset: _offset,
    );
  }

  void showBanner(int offset) {
    _visible = true;

    if (_offset != offset) {
      _offset = offset;
      // offset = _offset;
      load();
    }

    IronSource.displayBanner();
  }

  void hideBanner() {
    _visible = false;
    IronSource.hideBanner();
  }

  @override
  void onBannerAdClicked() {
    log('banner clicked');
  }

  @override
  void onBannerAdLeftApplication() {
    log('banner left application');
  }

  @override
  void onBannerAdLoadFailed(IronSourceError error) {
    retryLoading();
    log('banner load failed with error code ${error.errorCode} and message ${error.message}');
  }

  @override
  void onBannerAdLoaded() {
    if (!_visible) {
      hideBanner();
    }
    onAdLoadSucceeded();
    log('banner loaded');
  }

  @override
  void onBannerAdScreenDismissed() {
    onAdDismissed();
    log('banner dismissed');
  }

  @override
  void onBannerAdScreenPresented() {
    onAdShowed();
    log('banner presented');
  }

  @override
  AdType get adType => AdType.banner;
}
