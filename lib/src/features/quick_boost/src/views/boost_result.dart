import 'package:phone_cleaner/router/router.dart';
import 'package:phone_cleaner/services/logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../commons/commons.dart';
import '../../../../themes/themes.dart';
import '../../../features.dart';

const double _headerHeight = 330;
const double _resultOverviewHeight = 150;

class BoostResult extends ConsumerStatefulWidget {
  const BoostResult({super.key});

  @override
  ConsumerState<BoostResult> createState() => _BoostResultState();
}

class _BoostResultState extends ConsumerState<BoostResult> {
  bool _showLottie = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() {
        _showLottie = true;
      });
    });
  }

  @override
  void dispose() {
    ref.invalidate(overallSystemControllerProvider);
    super.dispose();
  }

  Function(AsyncValue? previous, AsyncValue next) logOnError(GoRouter router) =>
      (previous, next) {
        if (previous?.hasError == true) {
          return;
        }
        if (next.hasError) {
          appLogger.error(
              'Quick Boost Result Error', next.error, next.stackTrace);
          router.pushNamed(
            AppRouter.error,
            extra: CleanerException(message: 'Some thing went wrong'),
          );
        }
      };

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    final router = GoRouter.of(context);
    ref.listen(quickBoostControllerProvider, logOnError(router));

    final boostData = ref.watch(quickBoostControllerProvider);
    final overallData = ref.watch(overallSystemControllerProvider);

    if (boostData.isLoading || overallData.isLoading) {
      return const SizedBox.shrink();
    }

    if (boostData.isLoading || overallData.isLoading) {
      return const ErrorPage();
    }

    final boostValue = boostData.valueOrNull;
    final overallValue = overallData.requireValue;
    final savedValue = boostValue!.savedSpace ?? 0.bytes;

    return Scaffold(
      backgroundColor: cleanerColor.primary1,
      body: SizedBox(
        width: double.maxFinite,
        height: double.maxFinite,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            _Header(
              backgroundColor: cleanerColor.neutral3,
            ),
            Positioned(
                top: _headerHeight - _resultOverviewHeight / 2 + appBarHeight,
                height: _resultOverviewHeight,
                left: pageHorizontalPadding,
                right: pageHorizontalPadding,
                child: _BoostResult(
                    original: overallValue.usedMemory,
                    optimized: savedValue,
                    total: overallValue.totalMemory)),
            Positioned(
              top: _headerHeight -
                  _resultOverviewHeight / 2 +
                  appBarHeight / 2 +
                  _resultOverviewHeight +
                  32,
              child: Column(
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Saved memory ',
                      style: const TextStyle(
                          color: Color.fromRGBO(51, 167, 82, 1)),
                      children: <TextSpan>[
                        TextSpan(
                          text: savedValue.toOptimal().toString(),
                          style: bold24,
                        ),
                        TextSpan(
                          text: " ${savedValue.toOptimal().symbol}",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_showLottie)
              Lottie.asset(
                'assets/lotties/boost3.json',
                height:
                    _headerHeight - _resultOverviewHeight / 2 + appBarHeight,
                fit: BoxFit.cover,
                repeat: false,
              ),
            const SecondaryAppBar(
              title: "Result",
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.backgroundColor,
  });

  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _HeaderDecoration(
          height: _headerHeight + appBarHeight,
        ),
        Expanded(
          child: Container(
            color: backgroundColor,
            width: double.maxFinite,
            height: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: 24,
              horizontal: pageHorizontalPadding,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderDecoration extends StatelessWidget {
  const _HeaderDecoration({
    required this.height,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      height: height,
      child: SvgPicture.asset(
        'assets/images/clean_finished_particles.svg',
        fit: BoxFit.cover,
      ),
    );
  }
}

class _BoostResult extends ConsumerWidget {
  const _BoostResult({
    Key? key,
    required this.original,
    required this.optimized,
    required this.total,
  }) : super(key: key);

  final DigitalUnit original;
  final DigitalUnit optimized;
  final DigitalUnit total;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cleanerColor = CleanerColor.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
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
      child: TweenAnimationBuilder(
          duration: const Duration(seconds: 1),
          tween: Tween<double>(
              begin: original.to(DigitalUnitSymbol.gigabyte).value.toDouble(),
              end: original.to(DigitalUnitSymbol.gigabyte).value.toDouble() -
                  optimized.to(DigitalUnitSymbol.gigabyte).value.toDouble()),
          builder: (BuildContext context, double used, Widget? child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      text: TextSpan(
                        text:
                            "${used.toStringAsFixed(1)}/${total.to(DigitalUnitSymbol.gigabyte)} ",
                        style: bold20.copyWith(
                          color: cleanerColor.primary10,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: DigitalUnitSymbol.gigabyte.symbol.toString(),
                            style: regular12,
                          ),
                        ],
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
                  painter: CircleProgress(used / total.toOptimal().value * 100),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: Center(
                      child: Text(
                        "${(used / total.toOptimal().value * 100).toInt()}%",
                        style: bold24.copyWith(
                          color: cleanerColor.primary10,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            );
          }),
    );
  }
}
