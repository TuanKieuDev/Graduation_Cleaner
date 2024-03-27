import 'package:phone_cleaner/di/injector.dart';
import 'package:phone_cleaner/services/preference_services/shared_preferences_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppModules {
  static Future<void> inject() async {
    injector.registerSingletonAsync<SharedPreferences>(
        () async => SharedPreferences.getInstance());

    injector.registerLazySingleton<SharedPreferencesManager>(
        () => SharedPreferencesManager(injector.get<SharedPreferences>()));
  }
}
