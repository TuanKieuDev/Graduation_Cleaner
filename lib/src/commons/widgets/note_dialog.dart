import 'package:flutter/material.dart';

import '../../themes/themes.dart';

class NoteDialog extends StatelessWidget {
  const NoteDialog({
    super.key,
    required this.title,
    required this.content,
  });

  final String title;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          12.0,
        ),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: semibold18.copyWith(color: cleanerColor.primary10),
          ),
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            iconSize: 20,
            padding: const EdgeInsets.all(0.0),
            constraints: const BoxConstraints(),
            icon: Icon(
              Icons.close_outlined,
              color: cleanerColor.primary7,
            ),
          ),
        ],
      ),
      titlePadding: const EdgeInsets.all(16),
      content: content,
      contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
    );
  }
}
