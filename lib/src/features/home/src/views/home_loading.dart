import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../share_styles/share_styles_file.dart';
import '../../../../commons/commons.dart';
import '../../../../themes/cleaner_color.dart';

class HomeLoading extends StatelessWidget {
  const HomeLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OpacityTweener(
              duration: const Duration(seconds: 1),
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 4,
                height: MediaQuery.of(context).size.width / 4,
                child: SvgPicture.asset('assets/icons/main_icon.svg'),
              ),
            ),
            GradientText(
              "Cleaner",
              gradient: cleanerColor.gradient1,
              style: bold18,
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 120.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  backgroundColor: cleanerColor.primary1,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
