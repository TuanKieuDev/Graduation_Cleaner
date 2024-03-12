import 'package:phone_cleaner/main.dart';
import 'package:phone_cleaner/services/logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:monetization/monetization.dart';

mixin InterstitialAdStateMixin<T extends StatefulWidget> on State<T> {
  static const interval = Duration(seconds: 1);

  @override
  void dispose() {
    super.dispose();
    appLogger.debug("interstitial");

    AdManager.instance.showAds(
      AdType.interstitial,
      '${GoRouter.of(navigatorKey.currentContext!).location}_loading_finished',
    );
  }
}
