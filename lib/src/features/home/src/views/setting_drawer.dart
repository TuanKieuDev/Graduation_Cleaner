import 'package:phone_cleaner/router/router.dart';
import 'package:phone_cleaner/src/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../commons/commons.dart';

class SettingDrawer extends StatelessWidget {
  const SettingDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    var delayTime = nextPageTransitionDelayDuration;
    var cleanerColor = CleanerColor.of(context)!;
    return Drawer(
      backgroundColor: CleanerColor.of(context)!.neutral3,
      child: ListView(
          padding: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerRight,
                      icon: const Icon(
                        Icons.close,
                        color: Color.fromRGBO(66, 134, 244, 1),
                        size: 20,
                      ),
                      onPressed: () => Scaffold.of(context).closeEndDrawer(),
                    ),
                  ),
                  GradientText(
                    'Setting',
                    style: bold24,
                    gradient: cleanerColor.gradient1,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 7,
            ),
            SettingItem(
              icon: CleanerIcons.quickClean,
              title: "Quick clean",
              trailing: Icon(
                Icons.navigate_next,
                color: cleanerColor.primary7,
              ),
              onTap: () async {
                final goRouter = GoRouter.of(context);
                await Future.delayed(delayTime);
                goRouter.pushNamed(AppRouter.quickClean);
              },
            ),
            SettingItem(
              icon: CleanerIcons.notification,
              title: "Notification",
              trailing: Icon(
                Icons.navigate_next,
                color: cleanerColor.primary7,
              ),
              onTap: () async {
                final goRouter = GoRouter.of(context);
                await Future.delayed(nextPageTransitionDelayDuration);
                goRouter.pushNamed(AppRouter.notification);
              },
            ),
            SettingItem(
              icon: CleanerIcons.cloudService2,
              title: "Cloud Service",
              trailing: Icon(
                Icons.navigate_next,
                color: cleanerColor.primary7,
              ),
              onTap: () async {
                final goRouter = GoRouter.of(context);
                await Future.delayed(delayTime);
                goRouter.pushNamed(AppRouter.cloudService);
              },
            ),
            SettingItem(
              icon: CleanerIcons.privacy,
              title: "Privacy",
              trailing: Icon(
                Icons.navigate_next,
                color: cleanerColor.primary7,
              ),
              onTap: () async {
                final goRouter = GoRouter.of(context);
                await Future.delayed(delayTime);
                goRouter.pushNamed(AppRouter.privacy);
              },
            ),
            const _ThemeSettingItem(),
          ]),
    );
  }
}

class _ThemeSettingItem extends ConsumerWidget {
  const _ThemeSettingItem();

  @override
  Widget build(context, ref) {
    return SettingItem(
      icon: CleanerIcons.topic,
      title: "Theme",
      trailing: CustomSwitch(
        onChanged: (value) {
          ref
              .read(cleanerThemeNotifier.notifier)
              .setTheme(value ? ThemeMode.light : ThemeMode.dark);
        },
        value: ref.read(cleanerThemeNotifier) == ThemeMode.light,
      ),
      onTap: () {
        var themeMode = ref.read(cleanerThemeNotifier);
        ref.read(cleanerThemeNotifier.notifier).setTheme(
            themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
      },
    );
  }
}

class CustomSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  State createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch>
    with SingleTickerProviderStateMixin {
  late Animation _circleAnimation;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _circleAnimation = AlignmentTween(
            begin: widget.value ? Alignment.centerRight : Alignment.centerLeft,
            end: widget.value ? Alignment.centerLeft : Alignment.centerRight)
        .animate(CurvedAnimation(
            parent: _animationController, curve: Curves.easeOutQuad));
  }

  void _onChanged() {
    if (_animationController.isCompleted) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
    widget.onChanged(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return GestureDetector(
            onTap: _onChanged,
            child: Container(
              width: 100.0,
              height: 20.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: const Color.fromRGBO(190, 190, 190, 1),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "Dark",
                          style: semibold12.copyWith(
                            color: cleanerColor.textDisable,
                          ),
                        ),
                        Text(
                          "Light",
                          style: semibold12.copyWith(
                            color: cleanerColor.textDisable,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: _circleAnimation.value,
                    child: Container(
                      alignment: Alignment.center,
                      width: 56.0,
                      height: 20.0,
                      decoration: BoxDecoration(
                          gradient: cleanerColor.gradient1,
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 2,
                              offset: const Offset(-1, 1),
                              color: cleanerColor.textDisable,
                            )
                          ]),
                      child: Text(
                        _circleAnimation.value == Alignment.centerLeft
                            ? "Dark"
                            : "Light",
                        style: semibold12.copyWith(
                          color: cleanerColor.neutral3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ));
      },
    );
  }
}
