import 'package:device_info/device_info.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../main.dart';

part 'list_app_controller.g.dart';

@riverpod
class ListAppController extends _$ListAppController {
  late AppManager _appManager;

  @override
  FutureOr<List<PackageInfo>> build() {
    _appManager = ref.watch(appRepository);

    return _appManager.getAllApplications();
  }

  Future<void> removeUninstalledApp(List<String> uninstallApps) async {
    update(
      (state) => state
        ..removeWhere(
          (element) => uninstallApps.contains(element.packageName),
        ),
    );
  }
}
