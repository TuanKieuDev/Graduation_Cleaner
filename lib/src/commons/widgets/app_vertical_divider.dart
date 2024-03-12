import 'package:phone_cleaner/src/themes/themes.dart';
import 'package:flutter/material.dart';

class AppVerticalDivider extends StatelessWidget {
  const AppVerticalDivider({
    Key? key,
    this.verticalPadding = 16,
  }) : super(key: key);
  final double verticalPadding;
  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Container(
        height: 1,
        color: cleanerColor.primary1,
      ),
    );
  }
}
