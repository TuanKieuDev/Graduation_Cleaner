import 'package:phone_cleaner/router/router.dart';
import 'package:phone_cleaner/src/features/quick_boost/quick_boost.dart';
import 'package:phone_cleaner/src/features/quick_clean/quick_clean.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/services/logger/logger.dart';
import 'package:phone_cleaner/src/features/home/src/features/overall_system_information/controllers/overall_system_controller.dart';
import 'package:phone_cleaner/src/features/quick_clean/src/views/scanning_animation.dart';
import 'package:phone_cleaner/src/themes/cleaner_color.dart';
import 'package:phone_cleaner/src/themes/fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

const double _headerHeight = 330;
const double _resultOverviewHeight = 150;
const int _firstLottieDuration = 1500;

class QuickBoost extends ConsumerStatefulWidget {
  const QuickBoost({
    super.key,
  });

  @override
  ConsumerState<QuickBoost> createState() => _QuickBoostState();
}

class _QuickBoostState extends ConsumerState<QuickBoost>
    with TickerProviderStateMixin {
  bool _isBoosting = false;
  late final AnimationController _controller;

  void _boost() async {
    // _controller.forward();
    _controller
      ..duration = const Duration(milliseconds: _firstLottieDuration)
      ..forward();
    Future.delayed(const Duration(milliseconds: _firstLottieDuration), () {
      setState(() => _isBoosting = true);
    });
    ref.read(quickBoostControllerProvider.notifier).clean();
  }

  Function(AsyncValue? previous, AsyncValue next) logOnError() =>
      (previous, next) {
        if (previous?.hasError == true) {
          return;
        }

        if (next.hasError) {
          appLogger.error(
              'Quick Boost Page Error', next.error, next.stackTrace);
          GoRouter.of(context).pushNamed(
            AppRouter.error,
            extra: CleanerException(message: 'Some thing went wrong'),
          );
        }
      };

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(quickBoostControllerProvider, logOnError());
    ref.listen(overallSystemControllerProvider, logOnError());

    final generalInfo = ref.watch(overallSystemControllerProvider);
    final isRefreshing = ref.watch(
        quickBoostControllerProvider.select((value) => value.isRefreshing));
    if (generalInfo.hasError) {
      // TODO: Show log error
      return ErrorPage(
        errorDescription: generalInfo.error.toString(),
      );
    }
    if (generalInfo.isLoading && !generalInfo.isRefreshing) {
      return const ScanningAnimation();
    }

    if (_isBoosting) {
      return ProcessAndResultLottie(
        lottiePath: 'assets/lotties/boost2.json',
        loop: isRefreshing,
        child: const BoostResult(),
      );
    }

    final used = generalInfo.requireValue.usedMemory
        .to(DigitalUnitSymbol.gigabyte)
        .toString();

    final total = generalInfo.requireValue.totalMemory
        .to(DigitalUnitSymbol.gigabyte)
        .toString();

    final cleanerColor = CleanerColor.of(context)!;
    return Scaffold(
        backgroundColor: cleanerColor.primary1,
        body: SizedBox(
          width: double.maxFinite,
          height: double.maxFinite,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              const _Header(),
              Positioned(
                top: _headerHeight - _resultOverviewHeight / 2 + appBarHeight,
                height: _resultOverviewHeight,
                left: pageHorizontalPadding,
                right: pageHorizontalPadding,
                child: _BoostContent(
                  used: used,
                  total: total,
                ),
              ),
              Lottie.asset(
                'assets/lotties/boost.json',
                controller: _controller,
                height:
                    _headerHeight - _resultOverviewHeight / 2 + appBarHeight,
                fit: BoxFit.cover,
              ),
              Lottie.asset(
                'assets/lotties/star.json',
                controller: _controller,
                fit: BoxFit.cover,
              ),
              Positioned(
                bottom: 32,
                child: _BoostButton(onPressed: _boost),
              ),
              const SecondaryAppBar(
                title: "Boost",
              ),
            ],
          ),
        ));
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final backgroundColor = CleanerColor.of(context)!.neutral3;
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

class _BoostContent extends ConsumerWidget {
  const _BoostContent({
    Key? key,
    required this.used,
    required this.total,
  }) : super(key: key);

  final String used;
  final String total;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cleanerColor = CleanerColor.of(context)!;
    final usedSize = double.parse(used);
    final totalSize = double.parse(total);

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  text: "${usedSize.toStringAsFixed(1)}/$total ",
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
            painter: CircleProgress(usedSize / totalSize * 100),
            child: SizedBox(
              width: 100,
              height: 100,
              child: Center(
                child: Text(
                  "${(usedSize / totalSize * 100).toInt()}%",
                  style: bold24.copyWith(
                    color: cleanerColor.primary10,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _BoostButton extends ConsumerWidget {
  const _BoostButton({required this.onPressed});

  final Function() onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PrimaryButton(
      onPressed: onPressed,
      title: Row(
        children: const [
          CleanerIcon(
            icon: CleanerIcons.btnBoost,
          ),
          SizedBox(
            width: 9,
          ),
          Text("Quick boost"),
        ],
      ),
      borderRadius: BorderRadius.circular(16),
      textStyle: bold20,
      width: MediaQuery.of(context).size.width - 32,
    );
  }
}
