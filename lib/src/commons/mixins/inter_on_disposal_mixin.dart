import 'package:phone_cleaner/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:monetization/monetization.dart';

mixin InterOnDisposalMixin<T extends StatefulWidget> on State<T> {
  // static const firstTimeInterval = Duration(seconds: 3);
  // static const secondTimeInterval = Duration(seconds: 10);

  // late StreamSubscription<AdType> adDismissFullscreenSubscription;
  // late StreamSubscription<AdType> adShownSubscription;
  // late bool isFirstTime;
  // bool hasShownAd = false;
/*
  @override
  void initState() {
    super.initState();
    isFirstTime = true;
    adShownSubscription =
        AdManager.instance.onAdShowedFullScreenContentStream.listen((event) {
      hasShownAd = true;
    });

    adDismissFullscreenSubscription =
        AdManager.instance.onAdDismissedFullScreenContentStream.listen(
      (event) {
        if (event == AdType.appOpen) {
          _showAdRepeatedly(
              isFirstTime ? firstTimeInterval : secondTimeInterval);
        }
      },
    );
    _showAdRepeatedly(isFirstTime ? firstTimeInterval : secondTimeInterval);
  }

  void _showAdRepeatedly(Duration interval) async {
    await Future.delayed(interval);
    if (!mounted) return;
    AdManager.instance.showAds(AdType.interstitial);
    isFirstTime = false;
  }
*/
  @override
  void dispose() {
    // adDismissFullscreenSubscription?.cancel();
    // adShownSubscription.cancel();

    // if (hasShownAd) {
    //   return;
    // }

    AdManager.instance.showAds(AdType.interstitial,
        '${GoRouter.of(navigatorKey.currentContext!).location}_loading_finished');
    super.dispose();
  }
}
