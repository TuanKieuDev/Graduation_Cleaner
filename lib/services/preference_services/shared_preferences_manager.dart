import 'package:shared_preferences/shared_preferences.dart';

import 'package:phone_cleaner/services/preference_services/preference_keys.dart';

class SharedPreferencesManager {
  final SharedPreferences sharedPreferences;

  SharedPreferencesManager(this.sharedPreferences);

  Future<void> saveIgnoredApps(List<String> ignoreApps) async =>
      sharedPreferences.setStringList(
          PreferenceKeys.ignoreApps.name, ignoreApps);

  Future<List<String>?>? getIgnoreApps() async =>
      sharedPreferences.getStringList(PreferenceKeys.ignoreApps.name);

  Future<void> saveFirstLaunch(bool firstLaunch) async =>
      sharedPreferences.setBool(PreferenceKeys.firstLaunch.name, firstLaunch);

  Future<bool?>? getFirstLaunch() async =>
      sharedPreferences.getBool(PreferenceKeys.firstLaunch.name);

  Future<void> saveLastRefreshTime(int lastRefreshTime) async =>
      sharedPreferences.setInt(
          PreferenceKeys.lastRefreshTime.name, lastRefreshTime);

  Future<int?>? getLastRefreshTime() async =>
      sharedPreferences.getInt(PreferenceKeys.lastRefreshTime.name);
}
