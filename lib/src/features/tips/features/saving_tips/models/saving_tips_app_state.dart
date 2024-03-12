import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'saving_tips_app_state.freezed.dart';

@freezed
class SavingTipsAppState with _$SavingTipsAppState {
  const SavingTipsAppState._();
  const factory SavingTipsAppState({
    @Default([]) List<AppCheckboxItemData> apps,
  }) = _SavingTipsAppState;

  int get appCheckedCount => apps.where((element) => element.checked).length;

  bool get canUnInstall => appCheckedCount > 0;

  DigitalUnit get appCheckedTotalSize =>
      apps.where((element) => element.checked).fold<DigitalUnit>(
        0.kb,
        (previousValue, element) {
          return previousValue + element.totalSize;
        },
      );

  DigitalUnit get appCanOptimizeTotalSize => apps.fold(
      0.kb, (previousValue, element) => previousValue + element.totalSize);
}
