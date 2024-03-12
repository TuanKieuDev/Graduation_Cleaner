import 'package:phone_cleaner/router/router.dart';
import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class IntroductionPage extends StatelessWidget {
  const IntroductionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: cleanerColor.neutral3,
        body: Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/introduction_logo.svg',
              ),
              const SizedBox(
                height: 50,
              ),
              GradientText(
                'Cleaner',
                gradient: cleanerColor.gradient1,
                style: bold24,
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                'Clean, boost, save battery for your phone',
                style: TextStyle(
                  color: cleanerColor.neutral5,
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              PrimaryButton(
                onPressed: () {
                  GoRouter.of(context).goNamed(AppRouter.cleanerOverview);
                },
                width: 160,
                height: 46,
                borderRadius: BorderRadius.circular(20),
                title: Text(
                  "Get started",
                  style: semibold16,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
