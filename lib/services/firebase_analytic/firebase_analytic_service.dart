import 'package:phone_cleaner/services/logger/logger.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class FirebaseAnalyticService extends NavigatorObserver {
  final FirebaseAnalytics analytics;

  FirebaseAnalyticService(this.analytics);

  FirebaseAnalyticsObserver getAnalyticsObserver() =>
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    analytics.setCurrentScreen(
      screenName: route.settings.name,
    );
    appLogger.error('didPush: ${route.settings.name}');
  }
}


// adb shell setprop debug.firebase.analytics.app com.example.phone_cleaner