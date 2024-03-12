import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../themes/themes.dart';

class CleanerDialog extends StatelessWidget {
  const CleanerDialog({
    super.key,
    required this.lottiePath,
    required this.title,
    required this.content,
    required this.actions,
  });

  final String lottiePath;
  final String title;
  final String content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          12.0,
        ),
      ),
      icon: Container(
        width: MediaQuery.of(context).size.width - 60,
        height: 100,
        decoration: BoxDecoration(
          color: cleanerColor.neutral2,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Lottie.asset(lottiePath),
      ),
      iconPadding: const EdgeInsets.all(0),
      title: Text(
        title,
        style: semibold14.copyWith(color: cleanerColor.primary10),
        textAlign: TextAlign.center,
      ),
      titlePadding: const EdgeInsets.symmetric(vertical: 8),
      content: Text(
        content,
        style: regular12.copyWith(color: cleanerColor.neutral5),
        textAlign: TextAlign.center,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      actions: actions,
      actionsPadding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
    );
  }
}
