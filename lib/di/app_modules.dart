import 'package:phone_cleaner/di/injector.dart';
import 'package:phone_cleaner/services/firebase_analytic/firebase_analytic_service.dart';
import 'package:phone_cleaner/services/preference_services/shared_preferences_manager.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppModules {
  static Future<void> inject() async {
    injector.registerLazySingleton<FirebaseAnalytics>(
        () => FirebaseAnalytics.instance);

    injector.registerLazySingleton<FirebaseAnalyticService>(
        () => FirebaseAnalyticService(injector.get<FirebaseAnalytics>()));

    injector.registerSingletonAsync<SharedPreferences>(
        () async => SharedPreferences.getInstance());

    injector.registerLazySingleton<SharedPreferencesManager>(
        () => SharedPreferencesManager(injector.get<SharedPreferences>()));
  }
}
