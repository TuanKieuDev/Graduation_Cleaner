import 'package:app_settings/app_settings.dart';
import 'package:phone_cleaner/src/features/features.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'permission_controller.g.dart';

@riverpod
class PermissionController extends _$PermissionController {
  @override
  FutureOr<PermissionState> build() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;
    bool isFileGranted;

    final isUsageGranted = await AppSettings.checkUsagePermissions();
    if (sdkInt >= 30) {
      isFileGranted = await Permission.manageExternalStorage.isGranted;
    } else {
      isFileGranted = await Permission.storage.isGranted;
    }
    return PermissionState(
      isFileGranted: isFileGranted,
      isUsageGranted: isUsageGranted,
    );
  }

  Future<void> checkPermission() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;
    bool isFileGranted;

    final isUsageGranted = await AppSettings.checkUsagePermissions();
    if (sdkInt >= 30) {
      isFileGranted = await Permission.manageExternalStorage.isGranted;
    } else {
      isFileGranted = await Permission.storage.isGranted;
    }

    state = AsyncData(
      PermissionState(
        isFileGranted: isFileGranted,
        isUsageGranted: isUsageGranted,
      ),
    );
  }

  Future<void> requestStoragePermission() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    if (sdkInt >= 30) {
      await Permission.manageExternalStorage.request();
    } else {
      await Permission.storage.request();
    }
  }

  Future<void> requestUsagePermission() async {
    await AppSettings.openUsageSettings();
  }
}
