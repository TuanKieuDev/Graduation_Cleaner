import 'package:phone_cleaner/services/logger/logger.dart';
import 'package:flutter/material.dart';

class AppObservers extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    appLogger.info('Page: ${route.settings.name}');
    super.didPush(route, previousRoute);
  }
}
