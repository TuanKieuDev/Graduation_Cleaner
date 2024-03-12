import 'package:phone_cleaner/main.dart';
import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/features/features.dart';
import 'package:device_info/device_info.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'overall_system_controller.g.dart';

@riverpod
class OverallSystemController extends _$OverallSystemController {
  late GeneralInfoManager infoManager;
  DigitalUnit? cacheUsedMemory;
  @override
  FutureOr<OverallDeviceStorageInfo> build() {
    infoManager = ref.read(generalInfoRepository);

    return _fetchData();
  }

  Future<OverallDeviceStorageInfo> _fetchData() async {
    final generalInfo = await infoManager.getGeneralInfo();
    cacheUsedMemory ??= generalInfo.usedMemory.bytes;
    DigitalUnit usedMemory = generalInfo.usedMemory.bytes;
    if (cacheUsedMemory != null) {
      if (cacheUsedMemory! < usedMemory) {
        usedMemory = cacheUsedMemory!;
      } else {
        cacheUsedMemory = usedMemory;
      }
    }
    return OverallDeviceStorageInfo(
      usedSpace: generalInfo.usedSpace.bytes,
      totalSpace: generalInfo.totalSpace.bytes,
      usedMemory: usedMemory,
      totalMemory: generalInfo.totalMemory.bytes,
      // TODO: extendableBatteryPercentage is not measured
      extendableBatteryPercentage: 80,
    );
  }
}
