import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../themes/themes.dart';
import '../commons.dart';

class UnavailableDataWidget extends StatelessWidget {
  const UnavailableDataWidget({
    super.key,
    required this.description,
    required this.svgPath,
  });

  final String description;
  final String svgPath;

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    return Column(
      children: [
        const SizedBox(height: 56),
        SvgPicture.asset(svgPath),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: regular12.copyWith(color: cleanerColor.neutral5),
          ),
        ),
        PrimaryButton(
          onPressed: () {
            Future.delayed(
              const Duration(milliseconds: 300),
              () => Scaffold.of(context).openEndDrawer(),
            );
          },
          title: const Text("Change filter"),
          borderRadius: BorderRadius.circular(16),
        ),
      ],
    );
  }
}
