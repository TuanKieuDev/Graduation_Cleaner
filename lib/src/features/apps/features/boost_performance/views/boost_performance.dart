import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../commons/commons.dart';
import '../../../../../themes/themes.dart';
import '../../../../features.dart';

class BoostPerformance extends StatelessWidget {
  const BoostPerformance({super.key, required this.padding});

  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;

    Future<void> showInfoiDialog() async {
      return showDialog<void>(
          context: context,
          builder: (context) {
            return NoteDialog(
              title: 'About boost performance',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Press the screen to promptly halt processes without exiting the current view.",
                    style: regular14.copyWith(color: cleanerColor.neutral5),
                  )
                ],
              ),
            );
          });
    }

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Boost performance",
                style: bold20.copyWith(color: cleanerColor.primary10),
              ),
              TextButton(
                onPressed: () {
                  showInfoiDialog();
                },
                child: const Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Color.fromRGBO(51, 167, 82, 1),
                ),
              ),
            ],
          ),
          const _BoostContent(),
        ],
      ),
    );
  }
}

class _BoostContent extends ConsumerStatefulWidget {
  const _BoostContent();

  @override
  ConsumerState<_BoostContent> createState() => _BoostContentState();
}

class _BoostContentState extends ConsumerState<_BoostContent> {
  @override
  void dispose() {
    ref.invalidate(overallSystemControllerProvider);
    super.dispose();
  }

  bool isBoosting = false;
  bool isBoosted = false;
  QuickBoostInfoOptimization boostValue = const QuickBoostInfoOptimization(
      beforeRam: 0, afterRam: 0, ramOptimized: 0);

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    final usedMemoryOriginalByGB = ref
            .watch(overallSystemControllerProvider)
            .value
            ?.usedMemory
            .to(DigitalUnitSymbol.gigabyte) ??
        0.gb;
    final totalMemoryByGB = ref
            .watch(overallSystemControllerProvider)
            .value
            ?.totalMemory
            .to(DigitalUnitSymbol.gigabyte) ??
        1.gb;

    Future<QuickBoostInfoOptimization> boost() async {
      setState(() {
        isBoosting = true;
      });
      final result =
          await ref.read(quickBoostControllerProvider.notifier).clean();
      setState(() {
        boostValue = result;
        isBoosting = false;
        isBoosted = true;
      });
      return result;
    }

    var placeHolderValue = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              usedMemoryOriginalByGB.toStringOptimal(),
              style: bold20.copyWith(
                color: cleanerColor.primary10,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              "Used memory",
              style: regular12.copyWith(color: cleanerColor.primary10),
            ),
          ],
        ),
        CustomPaint(
          painter: CircleProgress(
              usedMemoryOriginalByGB.value / totalMemoryByGB.value * 100),
          child: SizedBox(
            width: 100,
            height: 100,
            child: Center(
              child: Text(
                "${(usedMemoryOriginalByGB.value / totalMemoryByGB.value * 100).toInt()}%",
                style: bold24.copyWith(
                  color: cleanerColor.primary10,
                ),
              ),
            ),
          ),
        )
      ],
    );
    Widget boostAction;
    if (isBoosted) {
      boostAction = SizedBox(
        height: 46,
        child: TweenAnimationBuilder(
            duration: const Duration(seconds: 1),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: GradientText(
                  "Your device has been boosted",
                  gradient: cleanerColor.gradient3,
                  style: regular14,
                ),
              );
            }),
      );
    } else {
      boostAction = PrimaryButton(
        enable: isBoosting ? false : true,
        onPressed: () {
          boost();
        },
        title: isBoosting
            ? Row(
                children: [
                  Container(
                      width: 30,
                      height: 30,
                      padding: const EdgeInsets.all(8),
                      child: const CircularProgressIndicator()),
                  const Text("Boosting..."),
                ],
              )
            : Row(
                children: const [
                  CleanerIcon(
                    icon: CleanerIcons.btnBoost,
                    size: 20,
                  ),
                  SizedBox(
                    width: 9,
                  ),
                  Text("Boost"),
                ],
              ),
        borderRadius: BorderRadius.circular(16),
        textStyle: semibold16,
        width: MediaQuery.of(context).size.width - 32,
        height: 46,
      );
    }

    return Column(
      children: [
        Container(
          width: double.maxFinite,
          height: 140,
          margin: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
              color: cleanerColor.neutral3,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(66, 133, 244, 0.25),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                )
              ]),
          child: boostValue.ramOptimized > 0
              ? TweenAnimationBuilder(
                  duration: const Duration(seconds: 1),
                  tween: Tween<double>(
                      begin: usedMemoryOriginalByGB.value.toDouble(),
                      end: usedMemoryOriginalByGB.value.toDouble() -
                          boostValue.ramOptimized.bytes
                              .to(DigitalUnitSymbol.gigabyte)
                              .value),
                  builder: (context, value, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              value.gb.toStringOptimal(),
                              style: bold20.copyWith(
                                color: cleanerColor.primary10,
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              "Used memory",
                              style: regular12.copyWith(
                                  color: cleanerColor.primary10),
                            ),
                          ],
                        ),
                        CustomPaint(
                          painter: CircleProgress(
                              value / totalMemoryByGB.value * 100),
                          child: SizedBox(
                            width: 100,
                            height: 100,
                            child: Center(
                              child: Text(
                                "${(value / totalMemoryByGB.value * 100).toInt()}%",
                                style: bold24.copyWith(
                                  color: cleanerColor.primary10,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    );
                  })
              : placeHolderValue,
        ),
        boostAction,
      ],
    );
  }
}
