import 'dart:developer';

import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/foundation.dart';

import 'ad_manager.dart';

class SkynetMonetization {
  static const _afDevKey = 'Mza5CYwx7pzKhdhcFcTHdm';
  static const _appId = '';

  static SkynetMonetization get instance => _instance;
  static final SkynetMonetization _instance = SkynetMonetization();

  late final AppsflyerSdk appsflyerSdk;

  Future init({
    bool listenToAndOpenAdOnAppStateChanges = true,
  }) async {
    AppsFlyerOptions appsFlyerOptions = AppsFlyerOptions(
      afDevKey: _afDevKey,
      appId: _appId,
      showDebug: kDebugMode,
      timeToWaitForATTUserAuthorization: 50, // for iOS 14.5
      disableAdvertisingIdentifier: false, // Optional field
      disableCollectASA: false,
    ); // Optional field

    appsflyerSdk = AppsflyerSdk(appsFlyerOptions);

    final appsFlyerSdkFuture = appsflyerSdk.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
      registerOnDeepLinkingCallback: true,
    );

    final adManagerFuture = AdManager.instance.initialize();
    if (listenToAndOpenAdOnAppStateChanges) {
      AdManager.instance.listenToAndOpenAdOnAppStateChanges();
    }

    await Future.wait([appsFlyerSdkFuture, adManagerFuture]);
    log('Skynet Monetization initialized');
  }
}
