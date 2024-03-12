import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/themes/themes.dart';
import 'package:flutter/material.dart';

import 'oval_container.dart';

@Deprecated('Unimplemented page.')
class ToBeUpdatedPage extends StatelessWidget {
  const ToBeUpdatedPage({
    super.key,
    required this.pageName,
    this.feature,
    this.featureDescription,
  });

  final String pageName;
  final Widget? feature;
  final String? featureDescription;

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;

    final feature = this.feature ??
        Text(
          featureDescription ??
              "This feature is being developed!\nStay tuned ❤",
          textAlign: TextAlign.center,
          style: regular16.copyWith(
            color: cleanerColor.neutral5,
          ),
        );

    return Scaffold(
      backgroundColor: cleanerColor.primary2,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
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
                const _MainIcon(),
                CustomPaint(
                  painter: OvalContainer(),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    width: constraints.maxWidth,
                    height: constraints.maxHeight - 310,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GradientText(
                          "To be updated",
                          gradient: cleanerColor.gradient1,
                          style: bold24,
                        ),
                        feature,
                        Padding(
                          padding: const EdgeInsets.only(top: 24.0),
                          child: PrimaryButton(
                              height: 40,
                              title: Text(
                                "Back",
                                style: semibold16,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              onPressed: () {
                                Navigator.pop(context);
                              }),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MainIcon extends StatelessWidget {
  const _MainIcon({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100,
      child: SizedBox(
        width: 300,
        height: 300,
        child: Stack(
          alignment: Alignment.center,
          children: const [
            Positioned(
              top: 130,
              child: CleanerIcon(icon: CleanerIcons.rocketGas),
            ),
            Positioned(
              top: 0,
              child: CleanerIcon(icon: CleanerIcons.rocketStraight),
            ),
          ],
        ),
      ),
    );
  }
}
