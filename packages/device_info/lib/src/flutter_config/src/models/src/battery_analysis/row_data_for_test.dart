import 'package:freezed_annotation/freezed_annotation.dart';

part 'row_data_for_test.freezed.dart';
part 'row_data_for_test.g.dart';

@freezed
class RowDataForTest with _$RowDataForTest {
  const RowDataForTest._();

  const factory RowDataForTest({
    required int timeStamp,
    required double batteryLevel,
    required bool isCharging,
  }) = _RowDataForTest;

  factory RowDataForTest.fromJson(Map<String, dynamic> json) =>
      _$RowDataForTestFromJson(json);
}
