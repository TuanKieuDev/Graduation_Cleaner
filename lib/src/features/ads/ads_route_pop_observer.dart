import 'package:phone_cleaner/router/router.dart';
import 'package:flutter/material.dart';
import 'package:monetization/monetization.dart';

class AdsRoutePopObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    switch (route.settings.name) {
      case AppRouter.appDetail:
      case AppRouter.photoOptimizer:
        AdManager.instance
            .showAds(AdType.interstitial, '${route.settings.name}_pushed');
    }
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    switch (route.settings.name) {
      // case AppRouter.quickClean:
      // case AppRouter.boost:
      // case AppRouter.fileFilter:
      case AppRouter.media:
      case AppRouter.apps:
      case AppRouter.listApp:
      case AppRouter.appDetail:
      case AppRouter.savingTips:
      case AppRouter.securityTips:
      case AppRouter.photoOptimizer:
        AdManager.instance
            .showAds(AdType.interstitial, '${route.settings.name}_popped');
    }
    super.didPop(route, previousRoute);
  }
}
