import 'package:phone_cleaner/main.dart';
import 'package:phone_cleaner/services/logger/logger.dart';
import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/features/apps/controllers/list_app_controller.dart';
import 'package:phone_cleaner/src/features/features.dart';
import 'package:device_info/device_info.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'uninstall_app_controller.g.dart';

@riverpod
class UninstallAppController extends _$UninstallAppController {
  late AppManager appManager;
  @override
  FutureOr<UninstallAppState> build(
      UninstallAppArguments unInstallAppArguments) async {
    appLogger.debug('UninstallAppController.build');
    appManager = ref.read(appRepository);

    final appUninstall = unInstallAppArguments.appUninstall;
    final packageNames = appUninstall.map((e) => e.packageName).toList();

    List<String> deletedPackages = [];

    for (final packageName in packageNames) {
      final result = await appManager.uninstall(packageName);
      if (result) deletedPackages.add(packageName);
    }

    final removedApps = <AppCheckboxItemData>[];
    removedApps.addAll(appUninstall
        .where((element) => deletedPackages.contains(element.packageName))
        .toList());
    if (deletedPackages.isNotEmpty) {
      ref
          .read(listAppControllerProvider.notifier)
          .removeUninstalledApp(deletedPackages);
    }

    await ref.refresh(overallSystemControllerProvider.notifier).future;

    return UninstallAppState(
      saveValue: removedApps.fold(
          0.kb, (previousValue, element) => previousValue + element.totalSize),
      successResults: removedApps
          .map(
            (e) => CleanResultData(
              name: e.name,
              subtitle: e.totalSize.toStringOptimal(),
              icon: e.iconData,
            ),
          )
          .toList(),
    );
  }
}
