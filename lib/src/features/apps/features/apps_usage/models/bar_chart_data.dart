import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'bar_chart_data.freezed.dart';

@freezed
class BarChartData with _$BarChartData {
  const factory BarChartData({
    required int x,
    required double y,
    required Gradient gradient,
  }) = _BarChartData;
}
