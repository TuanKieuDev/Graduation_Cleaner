import 'package:freezed_annotation/freezed_annotation.dart';

part 'quick_boost_info_optimization.freezed.dart';
part 'quick_boost_info_optimization.g.dart';

@freezed
class QuickBoostInfoOptimization with _$QuickBoostInfoOptimization {
  const QuickBoostInfoOptimization._();

  const factory QuickBoostInfoOptimization({
    required int beforeRam,
    required int afterRam,
    required int ramOptimized,
  }) = _QuickBoostInfoOptimization;

  factory QuickBoostInfoOptimization.fromJson(Map<String, dynamic> json) =>
      _$QuickBoostInfoOptimizationFromJson(json);
}
