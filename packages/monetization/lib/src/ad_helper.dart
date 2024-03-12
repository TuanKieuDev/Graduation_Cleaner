import 'dart:io';

import 'package:flutter/foundation.dart';

class AdHelper {
  static const bool debugFlag = true;

  static const int maxFailedLoadAttempts = 3;
  static const Duration failedLoadTimeout = Duration(seconds: 1);

  static const Duration interAdsInterval = Duration(seconds: 25);
  static const Duration maxAppOpenCachedDuration = Duration(hours: 4);
  static const int nativeAdsCachedCapacity = 3;

  static List<String> get native {
    if (kDebugMode || debugFlag) {
      return ['ca-app-pub-3940256099942544/2247696110'];
    } else if (Platform.isAndroid) {
      return [
        'ca-app-pub-6336405384015455/2527009613',
        'ca-app-pub-6336405384015455/8709274585',
        'ca-app-pub-6336405384015455/4707833282',
      ];
    } else if (Platform.isIOS) {
      throw UnimplementedError();
    }

    throw UnsupportedError(
        'Platform ${Platform.operatingSystem} is not supported');
  }

  static String get banner {
    if (kDebugMode || debugFlag) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      throw UnimplementedError();
    }

    throw UnsupportedError(
        'Platform ${Platform.operatingSystem} is not supported');
  }

  static String get interstitial {
    if (kDebugMode || debugFlag) {
      return 'ca-app-pub-3940256099942544/1033173712';
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712';
    } else if (Platform.isIOS) {
      throw UnimplementedError();
    }

    throw UnsupportedError(
        'Platform ${Platform.operatingSystem} is not supported');
  }

  static String get reward {
    if (kDebugMode || debugFlag) {
      return 'ca-app-pub-3940256099942544/5224354917';
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917';
    } else if (Platform.isIOS) {
      throw UnimplementedError();
    }

    throw UnsupportedError(
        'Platform ${Platform.operatingSystem} is not supported');
  }

  static List<String> get appOpen {
    if (kDebugMode || debugFlag) {
      return ['ca-app-pub-3940256099942544/3419835294'];
    } else if (Platform.isAndroid) {
      return [
        'ca-app-pub-6336405384015455/8951110878',
        'ca-app-pub-6336405384015455/3914406617',
        'ca-app-pub-6336405384015455/6729144358',
      ];
    } else if (Platform.isIOS) {
      throw UnimplementedError();
    }

    throw UnsupportedError(
        'Platform ${Platform.operatingSystem} is not supported');
  }
}
