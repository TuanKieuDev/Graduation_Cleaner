import 'package:freezed_annotation/freezed_annotation.dart';

part 'saving_tips_state.freezed.dart';

@freezed
class SavingTipsState with _$SavingTipsState {
  const SavingTipsState._();
  const factory SavingTipsState({
    @Default(false) bool isShowUnnecessaryDataTip,
    @Default(false) bool isShowUnUsedAppsTip,
    @Default(false) bool isShowPhotoTip,
    @Default(false) bool isShowLargeAppsTips,
  }) = _SavingTipsState;

  int get tipCounter =>
      (isShowUnnecessaryDataTip ? 1 : 0) +
      (isShowUnUsedAppsTip ? 1 : 0) +
      (isShowPhotoTip ? 1 : 0) +
      (isShowLargeAppsTips ? 1 : 0);
}
