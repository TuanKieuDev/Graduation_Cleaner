import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'battery_consumption_state.freezed.dart';

@freezed
class BatteryConsumptionState with _$BatteryConsumptionState {
  factory BatteryConsumptionState({
    @Default([]) List<AppCheckboxItemData> apps,
    required int timeRemaining,
  }) = _BatteryConsumptionState;
}
