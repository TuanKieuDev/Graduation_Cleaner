import 'package:phone_cleaner/di/injector.dart';
import 'package:phone_cleaner/services/logger/logger.dart';
import 'package:phone_cleaner/services/preference_services/shared_preferences_manager.dart';
import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/features/apps/controllers/list_app_controller.dart';
import 'package:phone_cleaner/src/features/features.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'refresh_data_controller.g.dart';

@riverpod
class RefreshDataController extends _$RefreshDataController {
  late SharedPreferencesManager _sharedPreferencesManager;

  @override
  Future<void> build() async {}

  Future<void> refreshData() async {
    _sharedPreferencesManager = injector.get<SharedPreferencesManager>();

    final isShouldRefreshData = await shouldRefreshData();

    if (isShouldRefreshData) {
      appLogger.info('Refresh data success');

      _sharedPreferencesManager
          .saveLastRefreshTime(DateTime.now().microsecondsSinceEpoch);

      await Future.wait([
        ref.refresh(listAppControllerProvider.future),
        ref.refresh(fileControllerProvider.future),
      ]);
    }
  }

  Future<bool> shouldRefreshData() async {
    final lastRefreshTime =
        await _sharedPreferencesManager.getLastRefreshTime();
    if (lastRefreshTime == null) {
      _sharedPreferencesManager
          .saveLastRefreshTime(DateTime.now().microsecondsSinceEpoch);
      return false;
    }
    appLogger.debug(
        'Last refresh time: ${DateTime.fromMicrosecondsSinceEpoch(lastRefreshTime)}');
    final isShouldRefreshData =
        DateTime.fromMicrosecondsSinceEpoch(lastRefreshTime)
            .isMoreThanMinutesFromNow(10);
    return isShouldRefreshData;
  }
}
