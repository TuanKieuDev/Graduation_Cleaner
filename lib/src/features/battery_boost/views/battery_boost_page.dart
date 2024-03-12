import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../../commons/commons.dart';
import '../../../themes/themes.dart';
import '../../home/src/views/setting_drawer.dart';
import '../controllers/battery_boost_controller.dart';

class BatteryBoost extends ConsumerStatefulWidget {
  const BatteryBoost({super.key});

  @override
  ConsumerState<BatteryBoost> createState() => _QuickBoostState();
}

class _QuickBoostState extends ConsumerState<BatteryBoost> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(batteryBoostControllerProvider.notifier);
    final batteryBoostState = ref.watch(batteryBoostControllerProvider);
    final batteryExtendable = notifier.getBatteryLifeExtend();
    final selectedApp = notifier.getAppSelected();
    void selectAll() {
      ref.read(batteryBoostControllerProvider.notifier).modifyTickedAllState();
    }

    void onChecked(int index) {
      setState(() {
        // final value = batteryBoostState.valueOrNull![index];
        // final newValue = !batteryBoostState.valueOrNull![index]!.checked;
        // batteryBoostState.valueOrNull![index] = AppCheckboxItemData(
        //     iconData: value!.iconData,
        //     name: value.name,
        //     totalSize: value.totalSize,
        //     checked: newValue);
      });
    }

    bool canShowButtonClean() {
      int i = 0;
      if (batteryBoostState.valueOrNull != null) {
        for (var item in batteryBoostState.valueOrNull!) {
          if (item!.checked) i++;
        }
      }

      return i > 0;
    }

    var contentHeight = MediaQuery.of(context).size.height - 250;
    return Scaffold(
      backgroundColor: Colors.white,
      endDrawer: const SettingDrawer(),
      body: Stack(alignment: AlignmentDirectional.bottomCenter, children: [
        SingleChildScrollView(
          child: Stack(children: [
            Image.asset(
              'assets/images/bg_clip.png',
            ),
            _MainContent(batteryExtendable: batteryExtendable),
            _DetailContent(
              contentHeight: contentHeight,
              batteryBoostState: batteryBoostState,
              selectedApp: selectedApp,
              showButton: canShowButtonClean(),
              onChecked: onChecked,
              selectAll: selectAll,
            ),
            Positioned(
              top: MediaQuery.of(context).viewPadding.top,
              right: 16,
              child: const _MenuDrawer(),
            ),
          ]),
        ),
        canShowButtonClean()
            ? Positioned(
                right: 16,
                bottom: 24,
                child: PrimaryButton(
                  onPressed: () {},
                  title: Row(
                    children: const [
                      CleanerIcon(
                        icon: CleanerIcons.battery,
                      ),
                      SizedBox(
                        width: 9,
                      ),
                      Text("Optimal"),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  textStyle: bold20,
                  height: 56,
                ),
              )
            : const SizedBox.shrink()
      ]),
    );
  }
}

class _MenuDrawer extends StatelessWidget {
  const _MenuDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: ElevatedButton(
        onPressed: () => Scaffold.of(context).openEndDrawer(),
        style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: Colors.white,
            elevation: 2,
            shadowColor: const Color.fromRGBO(66, 133, 244, 0.2),
            foregroundColor: const Color.fromRGBO(150, 202, 255, 0.3),
            padding: const EdgeInsets.all(0)),
        child: const CleanerIcon(
          icon: CleanerIcons.setting,
        ),
      ),
    );
  }
}

class _MainContent extends StatelessWidget {
  const _MainContent({
    Key? key,
    required this.batteryExtendable,
  }) : super(key: key);

  final int batteryExtendable;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SecondaryAppBar(title: "Boost"),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GradientText(
                  "$batteryExtendable%",
                  style: const TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.w700,
                  ),
                  gradient: const LinearGradient(colors: [
                    Color.fromRGBO(255, 152, 76, 1),
                    Color.fromRGBO(255, 119, 40, 1),
                  ]),
                ),
                const Text(
                  "Battery capacity",
                  style: TextStyle(
                      fontSize: 18, color: Color.fromRGBO(242, 148, 40, 1)),
                ),
                Text(
                  "Can be optimized",
                  style: regular16.copyWith(
                      color: CleanerColor.of(context)!.primary10),
                )
              ],
            ),
            const SizedBox(
              width: 35,
            ),
            SvgPicture.asset('assets/icons/big_battery_boost.svg'),
          ],
        ),
      ],
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({
    Key? key,
    required this.contentHeight,
    required this.batteryBoostState,
    required this.selectedApp,
    required this.showButton,
    required this.onChecked,
    required this.selectAll,
  }) : super(key: key);

  final double contentHeight;
  final AsyncValue<List<AppCheckboxItemData?>> batteryBoostState;
  final int selectedApp;
  final bool showButton;
  final Function(int index) onChecked;
  final Function() selectAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 250),
      padding: EdgeInsets.only(bottom: showButton ? 100 : 50),
      constraints: BoxConstraints(minHeight: contentHeight),
      color: Colors.white,
      child: (batteryBoostState.valueOrNull != null)
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  color: selectedApp == batteryBoostState.valueOrNull!.length
                      ? const Color.fromRGBO(211, 234, 255, 1)
                      : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          selectAll();
                        },
                        style: TextButton.styleFrom(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        child: Text(
                          "Select all",
                          style: semibold14.copyWith(
                              color: const Color.fromRGBO(53, 77, 110, 1)),
                        ),
                      ),
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: selectedApp > 0
                              ? Colors.green
                              : const Color.fromRGBO(219, 219, 219, 1),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            selectAll();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(0),
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                          ),
                          child: selectedApp > 0
                              ? (selectedApp ==
                                      batteryBoostState.valueOrNull!.length
                                  ? const CleanerIcon(
                                      icon: CleanerIcons.done,
                                      fit: BoxFit.scaleDown,
                                    )
                                  : const CleanerIcon(
                                      icon: CleanerIcons.remove,
                                      fit: BoxFit.scaleDown,
                                    ))
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ),
                ),
                for (int i = 0; i < batteryBoostState.valueOrNull!.length; i++)
                  AppCheckboxItem(
                    onTap: () => onChecked(i),
                    data: batteryBoostState.valueOrNull![i]!,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }
}
