import 'package:freezed_annotation/freezed_annotation.dart';

part 'permission_state.freezed.dart';

@freezed
class PermissionState with _$PermissionState {
  const PermissionState._();
  const factory PermissionState({
    bool? isFileGranted,
    bool? isUsageGranted,
  }) = _PermissionState;

  bool get isAllGranted => isFileGranted == true && isUsageGranted == true;
}
