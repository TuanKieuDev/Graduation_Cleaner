import 'package:phone_cleaner/src/commons/models/digital_unit.dart';
import 'package:device_info/device_info.dart';

class FakeGeneralInfoRepository implements GeneralInfoManager {
  @override
  DeviceInfo get cleanerAppInfo => DeviceInfo();

  @override
  Future<GeneralInfo> getGeneralInfo() async {
    return GeneralInfo(
      usedMemory: 0.4.gb.to(DigitalUnitSymbol.byte).value.toInt(),
      freeMemory: 3.6.gb.to(DigitalUnitSymbol.byte).value.toInt(),
      totalMemory: 4.gb.to(DigitalUnitSymbol.byte).value.toInt(),
      usedSpace: 100.gb.to(DigitalUnitSymbol.byte).value.toInt(),
      totalSpace: 256.gb.to(DigitalUnitSymbol.byte).value.toInt(),
      battery: 80,
    );
  }
}
