import 'package:phone_cleaner/src/commons/models/app_checkbox_item_data.dart';
import 'package:phone_cleaner/src/commons/models/digital_unit.dart';
import 'package:phone_cleaner/src/features/apps/apps.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'apps_consumption_info.freezed.dart';

enum ConsumptionType {
  data("Data"),
  capacity("Capacity"),
  battery("Battery"),
  ;

  const ConsumptionType(this.description);

  final String description;

  @override
  String toString() => description.toString();
}

@freezed
class AppsConsumptionInfo with _$AppsConsumptionInfo {
  const AppsConsumptionInfo._();
  factory AppsConsumptionInfo({
    @Default([]) List<AppCheckboxItemData> consumptionData,
    required SortType type,
  }) = _AppsConsumptionInfo;
  DigitalUnit get totalSize => consumptionData.fold(
      0.kb, (previousValue, element) => previousValue + element.totalSize);
  DigitalUnit get totalDataUsed => consumptionData.fold(
      0.kb, (previousValue, element) => previousValue + element.dataUsed);
  bool get showBadge => totalSize > 0.bytes;
}
