import 'package:phone_cleaner/router/router.dart';
import 'package:phone_cleaner/src/commons/pages/oval_container.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../themes/themes.dart';
import '../commons.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({
    super.key,
    this.errorCode = ErrorCode.internalError,
    this.errorDescription,
  });

  ErrorPage.fromCleanerException(CleanerException cleanerException, {super.key})
      : errorCode = cleanerException.errorCode,
        errorDescription =
            cleanerException.message?.toString() ?? 'Unexpected error';

  final ErrorCode errorCode;
  final String? errorDescription;

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    return Scaffold(
        body: SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned.fill(
            child: Container(
              height: 400,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(255, 191, 189, 1),
                    Color.fromRGBO(255, 227, 226, 0.5)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          const Positioned(
            top: 90,
            left: 20,
            child: CleanerIcon(icon: CleanerIcons.cloud1),
          ),
          const Positioned(
            top: 120,
            left: 50,
            child: CleanerIcon(icon: CleanerIcons.cloud2),
          ),
          const Positioned(
            top: 120,
            right: -20,
            child: CleanerIcon(icon: CleanerIcons.cloud3),
          ),
          Positioned(
            top: 310,
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              painter: OvalContainer(),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                width: double.infinity,
                // height: constraints.maxHeight - 310,
                child: _ErrorDescription(
                  cleanerColor: cleanerColor,
                  errorCode: errorCode,
                  errorDescription: errorDescription,
                ),
              ),
            ),
          ),
          const _MainIcon(),
        ],
      ),
    ));
  }
}

class _MainIcon extends StatelessWidget {
  const _MainIcon({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 150,
      child: SizedBox(
        width: 300,
        height: 300,
        child: Stack(
          alignment: Alignment.center,
          children: const [
            CleanerIcon(icon: CleanerIcons.robot),
          ],
        ),
      ),
    );
  }
}

class _ErrorDescription extends StatelessWidget {
  const _ErrorDescription({
    Key? key,
    required this.cleanerColor,
    required this.errorDescription,
    required this.errorCode,
  }) : super(key: key);

  final CleanerColor cleanerColor;
  final ErrorCode errorCode;
  final String? errorDescription;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GradientText(
          "Our hand fell off".toUpperCase(),
          gradient: cleanerColor.gradient4,
          style: bold24,
        ),
        const Padding(padding: EdgeInsets.all(5)),
        Text(
          "${errorCode.code} - ${errorCode.description}",
          style: regular12.copyWith(
              fontStyle: FontStyle.italic,
              color: CleanerColor.of(context)!.neutral1.withAlpha(100)),
        ),
        Text(
          errorDescription ?? "That was unexpected 🤖",
          textAlign: TextAlign.center,
          style: regular16.copyWith(
            color: cleanerColor.neutral5,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child: PrimaryButton(
              height: 40,
              gradientColor: cleanerColor.gradient4,
              title: Text(
                "Return",
                style: semibold16,
              ),
              borderRadius: BorderRadius.circular(16),
              onPressed: () {
                var router = GoRouter.of(context);
                if (router.canPop()) {
                  router.pop();
                } else {
                  router.goNamed(AppRouter.home);
                }
              }),
        )
      ],
    );
  }
}
