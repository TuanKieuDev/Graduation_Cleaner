import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'uninstall_app_state.freezed.dart';

@freezed
class UninstallAppState with _$UninstallAppState {
  const factory UninstallAppState({
    required DigitalUnit saveValue,
    @Default([]) List<CleanResultData> successResults,
  }) = _UninstallAppState;
}
