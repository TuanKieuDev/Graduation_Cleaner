import 'dart:developer';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:monetization/src/ad_interval.dart';
import 'package:monetization/src/ad_loader_mixin.dart';
import 'package:monetization/src/ad_unit_container.dart';

import '../../monetization.dart';
import '../ad_helper.dart';

class AdmobAdManager {
  late AdmobInterstitialAdManager interstitialManager;
  late AdmobAppOpenAdManager appOpenAdManager;

  Future init({VoidCallback? onAppOpenAdFirstLoaded}) async {
    // ignore: unused_local_variable
    appOpenAdManager = AdmobAppOpenAdManager();
    var status = await MobileAds.instance.initialize();

    // ! DO NOT DELETE, USED FOR TESTING
    //
    // status.adapterStatuses.forEach((key, value) {
    //   debugPrint('Adapter status for $key: ${value.description}');
    // });
    // MobileAds.instance.updateRequestConfiguration(RequestConfiguration(
    //     testDeviceIds: ['C621DDA4BCFDEC643EA651703B91649F']));

    appOpenAdManager.load();
  }
}

class AdmobInterstitialAdManager with AdInterval, AdLoaderMixin {
  InterstitialAd? _interstitialAd;

  @override
  load() {
    const request = AdRequest();
    InterstitialAd.load(
        adUnitId: AdHelper.interstitial,
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            onAdLoadSucceeded();
            _interstitialAd!.setImmersiveMode(true);
            log('$ad loaded');
          },
          onAdFailedToLoad: (LoadAdError error) {
            _interstitialAd = null;
            retryLoading();
            log('InterstitialAd failed to load: $error.');
          },
        ));
  }

  void show() {
    if (_interstitialAd == null) {
      log('Attempt to show interstitial before loaded.');
      return;
    }

    if (!shouldShowAd()) {
      log('InterstitialAd is not shown due to time difference is too short!');
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        updateAdShowedTime();
        onAdShowed();
        log('ad onAdShowedFullScreenContent.');
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        onAdDismissed();
        load();
        log('$ad onAdDismissedFullScreenContent.');
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        onAdShowFailed();
        load();
        log('$ad onAdFailedToShowFullScreenContent: $error');
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  @override
  AdType get adType => AdType.interstitial;
}

class AdmobAppOpenAdManager with AdInterval, AdLoaderMixin {
  List<AdmobAdOpenLoader> loaders = [];

  AdUnitContainer adUnitContainer = AdUnitContainer(AdHelper.appOpen);

  AppOpenAd? get _appOpenAd => loaders
      .firstWhereOrNull((element) => element.appOpenAd != null)
      ?.appOpenAd;

  AdmobAppOpenAdManager() {
    for (var i = 0; i < AdHelper.appOpen.length; i++) {
      final admobAdOpenLoader = AdmobAdOpenLoader(AdHelper.appOpen[i]);
      admobAdOpenLoader.adLoadedStream.listen((_) => onAdLoadSucceeded());
      admobAdOpenLoader.adDismissedStream.listen((_) => onAdDismissed());
      admobAdOpenLoader.adFailedToShowFullScreenContentStream
          .listen((_) => onAdShowFailed());
      admobAdOpenLoader.adShowedFullScreenContentStream
          .listen((_) => onAdShowed());
      loaders.add(admobAdOpenLoader);
    }
  }

  @override
  void load() {
    for (var loader in loaders) {
      loader.load();
    }
  }

  void showAd() {
    final loader =
        loaders.firstWhereOrNull((element) => element.appOpenAd != null);
    final appOpenAd = loader?._appOpenAd;
    if (appOpenAd == null) {
      log('Tried to show ad before available.');
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        updateAdShowedTime();
        onAdShowed();
        log('$ad onAdShowedFullScreenContent');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        onAdShowFailed();
        ad.dispose();
        loader?.load();
      },
      onAdDismissedFullScreenContent: (ad) {
        onAdDismissed();

        ad.dispose();
        loader?.load();

        log('$ad onAdDismissedFullScreenContent');
      },
    );
    _appOpenAd!.show();
  }

  void listenToAndOpenAdOnAppStateChanges() {
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream.forEach(_onAppStateChanged);
  }

  void _onAppStateChanged(AppState appState) {
    // Try to show an app open ad if the app is being resumed and
    // we're not already showing an app open ad.
    if (appState == AppState.foreground) {
      AdManager.instance.showAds(AdType.appOpen, 'app_resumed');
    }
  }

  @override
  AdType get adType => AdType.appOpen;
}

class AdmobAdOpenLoader with AdLoaderMixin {
  AdmobAdOpenLoader(this.id);

  final String id;
  AppOpenAd? _appOpenAd;
  DateTime? _appOpenLoadTime;

  AppOpenAd? get appOpenAd {
    if (_appOpenLoadTime == null) return null;
    if (DateTime.now()
        .subtract(AdHelper.maxAppOpenCachedDuration)
        .isAfter(_appOpenLoadTime!)) {
      log('Maximum cache duration exceeded. Loading another ad.');
      _appOpenAd!.dispose();
      _appOpenAd = null;
      load();
    }

    return _appOpenAd;
  }

  @override
  void load() {
    _appOpenAd = null;
    const request = AdRequest();
    AppOpenAd.load(
      adUnitId: id,
      orientation: AppOpenAd.orientationPortrait,
      request: request,
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _appOpenLoadTime = DateTime.now();
          onAdLoadSucceeded();
          log('AppOpenAd $id loaded');
        },
        onAdFailedToLoad: (error) {
          retryLoading();
          log('AppOpenAd $id failed to load: $error');
        },
      ),
    );
  }

  @override
  AdType get adType => AdType.appOpen;
}
