import 'package:duration/duration.dart';
import 'package:flutter/material.dart';

import '../../themes/themes.dart';

class TimeRemaining extends StatelessWidget {
  const TimeRemaining({
    super.key,
    required this.timeRemaining,
  });

  final int timeRemaining;

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        gradient: cleanerColor.gradient1,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: cleanerColor.neutral3,
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Text(
            printDuration(Duration(milliseconds: timeRemaining)),
            style: semibold14.copyWith(color: cleanerColor.neutral3),
          ),
        ],
      ),
    );
  }
}
