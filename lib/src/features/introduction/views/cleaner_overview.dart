import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:delayed_tween_animation_builder/delayed_tween_animation_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../router/router.dart';
import '../../../themes/themes.dart';
import '../../features.dart';

class CleanerOverview extends StatelessWidget {
  const CleanerOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        backgroundColor: cleanerColor.neutral3,
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            const Background(
              secondaryBackground: true,
            ),
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  GradientText(
                    "Cleaner",
                    gradient: cleanerColor.gradient1,
                    style: bold24,
                  ),
                  const Expanded(child: _CleanerOverview()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CleanerOverview extends ConsumerWidget {
  const _CleanerOverview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overallData = ref.watch(overallSystemControllerProvider);

    if (overallData.hasError) {
      return ErrorPage(
        errorDescription: overallData.error.toString(),
      );
    }
    if (overallData.isLoading) {
      return Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 2,
          height: MediaQuery.of(context).size.width / 2,
          child: const CircularProgressIndicator(),
        ),
      );
    }
    final usedSpace =
        overallData.value!.usedSpace.to(DigitalUnitSymbol.gigabyte);
    final totalSpace =
        overallData.value!.totalSpace.to(DigitalUnitSymbol.gigabyte);
    final cleanerColor = CleanerColor.of(context)!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Content(
          usedSpace: usedSpace,
          totalSpace: totalSpace,
          cleanerColor: cleanerColor,
        ),
        const SizedBox(
          height: 32,
        ),
        Text(
          "We will guide you in the first clean",
          style: regular16.copyWith(
            color: cleanerColor.neutral5,
          ),
        ),
        const SizedBox(
          height: 40,
        ),
        PrimaryButton(
          onPressed: () {
            GoRouter.of(context).pushNamed(AppRouter.accessRights);
          },
          title: Text(
            "Start now",
            style: semibold16,
          ),
          borderRadius: BorderRadius.circular(16),
        )
      ],
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.usedSpace,
    required this.totalSpace,
    required this.cleanerColor,
  });

  final DigitalUnit usedSpace;
  final DigitalUnit totalSpace;
  final CleanerColor cleanerColor;

  @override
  Widget build(BuildContext context) {
    final countUp = DelayedTweenAnimationBuilder(
        delay: const Duration(milliseconds: 200),
        duration: const Duration(seconds: 3),
        curve: Curves.easeOutSine,
        tween: Tween<double>(begin: 0, end: usedSpace.value.toDouble()),
        builder: (BuildContext context, double usedSpace, Widget? child) {
          return CustomPaint(
            painter: CircleProgress((usedSpace / totalSpace.value) * 100),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              width: MediaQuery.of(context).size.width / 2,
              height: MediaQuery.of(context).size.width / 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Used space",
                      style: regular14.copyWith(color: cleanerColor.neutral5)),
                  Text(
                    "${usedSpace.toStringAsFixed(0)}/$totalSpace",
                    style: bold20.copyWith(color: cleanerColor.primary10),
                  ),
                  Text(
                    "${DigitalUnitSymbol.gigabyte}",
                    style: regular14.copyWith(color: cleanerColor.primary10),
                  )
                ],
              ),
            ),
          );
        });
    return OpacityTweener(
      duration: const Duration(seconds: 1),
      curve: Curves.easeOutQuad,
      child: countUp,
    );
  }
}
