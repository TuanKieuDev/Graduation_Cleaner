import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/themes/themes.dart';

class UnnecessaryDataPartView extends ConsumerWidget {
  const UnnecessaryDataPartView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cleanerColor = CleanerColor.of(context)!;
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUnnecessaryDataTitle(cleanerColor),
          const SizedBox(height: 24),
          _buildUnnecessaryDataView(cleanerColor, constraints),
        ],
      );
    });
  }

  Widget _buildUnnecessaryDataTitle(CleanerColor cleanerColor) {
    return Text(
      'Unnecessary Data',
      style: semibold18.copyWith(color: cleanerColor.primary10),
    );
  }

  Widget _buildUnnecessaryDataView(
    CleanerColor cleanerColor,
    BoxConstraints constraints,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildChartView(cleanerColor, constraints),
        _buildDetailChartView(cleanerColor)
      ],
    );
  }

  Widget _buildDetailChartView(CleanerColor cleanerColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildDetailTitle(
          label: 'Hidden caches',
          color: cleanerColor.gradient4,
          size: 643.mb,
        ),
        const SizedBox(height: 8),
        _buildDetailTitle(
          label: 'Screenshots',
          color: cleanerColor.gradient2,
          size: 323.mb,
        ),
        const SizedBox(height: 8),
        _buildDetailTitle(
          label: 'Thumbnails',
          color: cleanerColor.gradient3,
          size: 665.mb,
        ),
        const SizedBox(height: 8),
        _buildDetailTitle(
          label: 'Empty folders',
          color: cleanerColor.gradient1,
          size: 542.mb,
        ),
      ],
    );
  }

  Widget _buildChartView(
      CleanerColor cleanerColor, BoxConstraints constraints) {
    return CustomPaint(
      painter: CircleFourBreak(
        hiddenCacheSize: 2223.bytes,
        screenshotSize: 3223.bytes,
        thumbnailSize: 5323.bytes,
        emptyFolderSize: 1233.bytes,
        hiddenCacheGradient: cleanerColor.gradient1,
        screenshotGradient: cleanerColor.gradient2,
        thumbnailGradient: cleanerColor.gradient3,
        emptyFolderGradient: cleanerColor.gradient4,
      ),
      child: SizedBox(
        width: constraints.maxWidth / 3,
        height: constraints.maxWidth / 3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              9129.mb.toStringOptimal(),
              style: bold18.copyWith(
                color: cleanerColor.primary10,
              ),
            ),
            Text(
              'Total',
              style: regular16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTitle({
    required String label,
    required Gradient color,
    required DigitalUnit size,
  }) {
    return Row(
      children: [
        GradientText(label, gradient: color),
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(
            horizontal: 8,
          ),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: color,
          ),
        ),
        SizedBox(
          width: 60,
          child: Align(
            alignment: Alignment.centerLeft,
            child: GradientText(
              size.toStringOptimal(),
              gradient: color,
            ),
          ),
        )
      ],
    );
  }
}
