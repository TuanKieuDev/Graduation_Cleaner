import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../../router/router.dart';

class TabDrawer extends StatelessWidget {
  const TabDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    return Drawer(
      backgroundColor: CleanerColor.of(context)!.neutral3,
      child: ListView(children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerRight,
                  icon: Icon(
                    Icons.close,
                    color: cleanerColor.primary7,
                    size: 20,
                  ),
                  onPressed: () => Scaffold.of(context).closeDrawer(),
                ),
              ),
              GradientText(
                'Cleaner',
                style: bold24,
                gradient: cleanerColor.gradient1,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  children: [
                    SvgPicture.asset('assets/icons/ic_premium.svg'),
                    const SizedBox(
                      width: 9,
                    ),
                    Text(
                      "Premium",
                      style: semibold18.copyWith(
                        color: const Color.fromRGBO(248, 168, 37, 1),
                      ),
                    )
                  ],
                ),
              ),
              Text(
                "Cleaner optimizes your phone with enhanced features and no ads",
                style: regular14,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Material(
                  color: const Color.fromRGBO(249, 168, 37, 1),
                  borderRadius: BorderRadius.circular(8.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8.0),
                    onTap: () async {
                      final goRouter = GoRouter.of(context);
                      await Future.delayed(nextPageTransitionDelayDuration);
                      goRouter.pushNamed(AppRouter.upgrade);
                    },
                    child: Stack(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          width: double.maxFinite,
                          height: 32,
                          color: Colors.transparent,
                          child: Text(
                            "Upgrade",
                            style: semibold16.copyWith(
                                color: cleanerColor.neutral3),
                          ),
                        ),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                              color: Color.fromRGBO(251, 192, 45, 1),
                              borderRadius: BorderRadius.horizontal(
                                  left: Radius.circular(8))),
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: SvgPicture.asset('assets/icons/upgrade.svg'),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Divider(height: 10, thickness: 1),
        Column(
          children: [
            SettingItem(
              icon: CleanerIcons.cloudService,
              title: "Cloud Service",
              trailing: Icon(
                Icons.navigate_next,
                color: cleanerColor.primary7,
              ),
              onTap: () async {
                final goRouter = GoRouter.of(context);
                await Future.delayed(nextPageTransitionDelayDuration);
                goRouter.pushNamed(AppRouter.cloudService);
              },
            ),
            SettingItem(
              icon: CleanerIcons.information,
              title: "System Information",
              trailing: Icon(
                Icons.navigate_next,
                color: cleanerColor.primary7,
              ),
              onTap: () async {
                final goRouter = GoRouter.of(context);
                await Future.delayed(nextPageTransitionDelayDuration);
                goRouter.pushNamed(AppRouter.systemInformation);
              },
            ),
            SettingItem(
              icon: CleanerIcons.tip,
              title: "Security tips",
              trailing: Icon(
                Icons.navigate_next,
                color: cleanerColor.primary7,
              ),
              onTap: () async {
                final goRouter = GoRouter.of(context);
                await Future.delayed(nextPageTransitionDelayDuration);
                goRouter.pushNamed(AppRouter.securityTips);
              },
            ),
            SettingItem(
              icon: CleanerIcons.feedback,
              title: "Help and feedback",
              trailing: const Icon(
                Icons.navigate_next,
                color: Color.fromRGBO(66, 149, 255, 1),
              ),
              onTap: () async {
                final goRouter = GoRouter.of(context);
                await Future.delayed(nextPageTransitionDelayDuration);
                goRouter.pushNamed(AppRouter.helpAndFeedback);
              },
            ),
            SettingItem(
              icon: CleanerIcons.aboutApp,
              title: "About the app",
              trailing: Icon(
                Icons.navigate_next,
                color: cleanerColor.primary7,
              ),
              onTap: () async {
                final goRouter = GoRouter.of(context);
                await Future.delayed(nextPageTransitionDelayDuration);
                goRouter.pushNamed(AppRouter.aboutApp);
              },
            ),
          ],
        ),
      ]),
    );
  }
}
