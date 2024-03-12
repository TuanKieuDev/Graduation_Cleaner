import 'package:flutter/material.dart';

import '../../themes/themes.dart';

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    Key? key,
    required this.title,
    required this.onPressed,
  }) : super(key: key);

  final String title;
  final Function() onPressed;
  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    return LayoutBuilder(
      builder: (context, constraints) {
        return TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            fixedSize: Size.fromWidth(constraints.maxWidth),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(width: 1, color: cleanerColor.primary7)),
          ),
          child: Text(
            title,
            style: semibold16.copyWith(
              color: cleanerColor.primary7,
            ),
          ),
        );
      },
    );
  }
}
