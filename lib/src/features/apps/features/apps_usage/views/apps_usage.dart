import 'package:phone_cleaner/src/features/apps/apps.dart';
import 'package:phone_cleaner/src/features/apps/features/apps_usage/views/bar_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../commons/commons.dart';
import '../../../../../themes/themes.dart';

class AppsUsage extends ConsumerStatefulWidget {
  const AppsUsage({super.key, required this.padding});

  final EdgeInsets padding;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AppsUsageState();
}

class _AppsUsageState extends ConsumerState<AppsUsage> {
  bool isDataDaily = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final appsUsageController = ref.watch(appsUsageControllerProvider);

    if (appsUsageController.hasError) {
      return const SizedBox.shrink();
    }

    final data = appsUsageController.requireValue;

    final appsUsageDataWeekly = data.last;

    final appsUsageDataDaily = data.first;

    var appsUsageData = isDataDaily ? appsUsageDataWeekly : appsUsageDataDaily;

    final cleanerColor = CleanerColor.of(context)!;

    Future<void> showInfoiDialog() async {
      return showDialog<void>(
          context: context,
          builder: (context) {
            Widget contentSection({
              required String title,
              required String description,
            }) =>
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            semibold14.copyWith(color: cleanerColor.primary10),
                      ),
                      Text(
                        description,
                        style: regular14.copyWith(color: cleanerColor.neutral5),
                      ),
                    ],
                  ),
                );

            return NoteDialog(
              title: 'About usage',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  contentSection(
                    title: "Graph",
                    description:
                        "Displays the combined duration of usage for all applications, with the option to specify the time frame under consideration.",
                  ),
                  contentSection(
                    title: "Time opened",
                    description:
                        "The applications displayed in this view are arranged in decreasing order based on the frequency of their usage.",
                  ),
                  contentSection(
                    title: "Screen time",
                    description:
                        "The applications displayed in this view are arranged in decreasing order based on the duration of time they have been used.",
                  ),
                  contentSection(
                    title: "Unused",
                    description:
                        "This display consists only applications that were not accessed during the selected period.",
                  ),
                ],
              ),
            );
          });
    }

    return Padding(
      padding: widget.padding,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "Usage",
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
              TimeSwitch(
                value: isDataDaily,
                onChanged: (value) {
                  setState(() {
                    isLoading = true;
                    isDataDaily = value;
                  });
                },
                onComplete: () {
                  setState(() {
                    isLoading = false;
                  });
                },
              )
            ],
          ),
          AnimatedOpacity(
            opacity: isLoading ? 0 : 1,
            curve: Curves.easeOutQuad,
            duration: const Duration(milliseconds: 500),
            child: Container(
              margin: const EdgeInsets.only(top: 32),
              height: appsUsageData.barChartData.any((element) => element.y > 0)
                  ? barChartHeight
                  : 0,
              child: BarChartUsage(
                barChartData: isLoading
                    ? appsUsageData.barChartData
                        .map((e) => e.copyWith(y: 0))
                        .toList()
                    : appsUsageData.barChartData,
                isDataDaily: isDataDaily,
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _UsageCategoryPart(
              key: ValueKey(isDataDaily),
              appsUsageData: appsUsageData,
            ),
          ),
        ],
      ),
    );
  }
}

class _UsageCategoryPart extends StatelessWidget {
  const _UsageCategoryPart({
    Key? key,
    required this.appsUsageData,
  }) : super(key: key);

  final AppsUsagePeriodData appsUsageData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (int i = 0; i < appsUsageData.categories.length; i++)
            AppsBlock(
              iconsData: appsUsageData.categories[i].items,
              size: appsUsageData.categories[i].numberOfApps.toString(),
              sortType: appsUsageData.categories[i].usageType,
              showBadge: appsUsageData.categories[i].showBadge,
              periodType: appsUsageData.periodType,
            )
        ],
      ),
    );
  }
}
