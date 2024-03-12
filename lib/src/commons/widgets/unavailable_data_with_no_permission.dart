import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../themes/themes.dart';
import '../commons.dart';

class UnavailableWidgetWithNoPermission extends StatelessWidget {
  const UnavailableWidgetWithNoPermission({
    super.key,
    required this.svgPath,
    required this.description,
    required this.onPressed,
  });

  final String svgPath;
  final String description;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    return Column(
      children: [
        const SizedBox(height: 56),
        SvgPicture.asset(svgPath),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 40),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: regular12.copyWith(
              color: cleanerColor.neutral5,
            ),
          ),
        ),
        PrimaryButton(
          onPressed: onPressed,
          title: const Text('Turn on'),
          borderRadius: BorderRadius.circular(16),
          width: 115,
        ),
      ],
    );
  }
}
