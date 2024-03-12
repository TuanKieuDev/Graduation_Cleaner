import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../../commons/commons.dart';
import '../../../../../themes/themes.dart';
import '../models/models.dart';

const barChartHeight = 200.0;

class BarChartUsage extends StatelessWidget {
  const BarChartUsage({
    Key? key,
    required this.barChartData,
    this.isDataDaily = false,
    this.isNotification = false,
  }) : super(key: key);

  final List<BarChartData> barChartData;
  final bool isDataDaily;
  final bool isNotification;

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    final maxValue = barChartData
        .reduce((current, next) => current.y > next.y ? current : next)
        .y;

    if (maxValue == 0) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        double interval = isNotification
            ? maxValue > 2
                ? ((maxValue % 2 == 0
                    ? (maxValue - 2) / 2
                    : (maxValue - 1) / 2))
                : 1
            : maxValue / 2.5;
        return SizedBox(
          width: constraints.maxWidth,
          height: barChartHeight,
          child: SfCartesianChart(
            margin: const EdgeInsets.all(0),
            plotAreaBorderWidth: 0,
            primaryXAxis: CategoryAxis(
              axisLine: AxisLine(color: cleanerColor.primary3),
              majorTickLines: const MajorTickLines(size: 0),
              majorGridLines: const MajorGridLines(width: 0),
              axisLabelFormatter: (axisLabelRenderArgs) => ChartAxisLabel(
                isDataDaily
                    ? axisLabelRenderArgs.text
                    : toCapitalize(
                        indexToWeekday(
                          int.parse(axisLabelRenderArgs.text),
                        ),
                      ),
                TextStyle(
                  fontSize: 12,
                  color: cleanerColor.primary10,
                ),
              ),
            ),
            primaryYAxis: NumericAxis(
              rangePadding: ChartRangePadding.none,
              minimum: 0,
              interval: interval,
              axisLabelFormatter: (axisLabelRenderArgs) {
                final timeValue = printDuration(
                  Duration(milliseconds: axisLabelRenderArgs.value.toInt()),
                  abbreviated: true,
                  spacer: ' ',
                  tersity: maxValue > 2 * Duration.millisecondsPerHour
                      ? DurationTersity.hour
                      : maxValue > 2 * Duration.millisecondsPerMinute
                          ? DurationTersity.minute
                          : DurationTersity.second,
                  upperTersity: maxValue > 2 * Duration.millisecondsPerHour
                      ? DurationTersity.hour
                      : maxValue > 2 * Duration.millisecondsPerMinute
                          ? DurationTersity.minute
                          : DurationTersity.second,
                );
                return ChartAxisLabel(
                  isNotification ? axisLabelRenderArgs.text : timeValue,
                  TextStyle(
                    fontSize: 12,
                    color: cleanerColor.primary10,
                  ),
                );
              },
              axisLine: const AxisLine(
                width: 0,
              ),
              majorTickLines: const MajorTickLines(size: 0),
              majorGridLines: MajorGridLines(
                color: cleanerColor.primary3,
              ),
            ),
            series: <ChartSeries>[
              ColumnSeries(
                width: isDataDaily ? 0.7 : 0.2,
                animationDelay: 300,
                animationDuration: 700,
                dataSource: barChartData,
                onCreateRenderer: (series) {
                  return _FlChartStyleColumnSeriesRenderer(series);
                },
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
                xValueMapper: (barChart, _) => (barChart as BarChartData).x,
                yValueMapper: (barChart, _) => (barChart as BarChartData).y,
              )
            ],
          ),
        );
      },
    );
  }
}

class _FlChartStyleColumnSeriesRenderer extends ColumnSeriesRenderer {
  _FlChartStyleColumnSeriesRenderer(this.series);
  final ChartSeries series;

  @override
  ChartSegment createSegment() {
    return _ColumnCustomPainter(dataSource: series.dataSource!);
  }
}

class _ColumnCustomPainter extends ColumnSegment {
  _ColumnCustomPainter({required this.dataSource});

  final List dataSource;

  @override
  int get currentSegmentIndex => super.currentSegmentIndex!;

  @override
  void onPaint(Canvas canvas) {
    fillPaint!.shader = (dataSource[currentSegmentIndex] as BarChartData)
        .gradient
        .createShader(segmentRect.outerRect);

    super.onPaint(canvas);
  }
}
