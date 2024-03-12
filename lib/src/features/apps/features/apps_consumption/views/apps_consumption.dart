import 'package:phone_cleaner/src/features/apps/apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone_cleaner/src/features/apps/views/battery_apps_block.dart';

import '../../../../../commons/commons.dart';
import '../../../../../themes/themes.dart';

class AppsConsumption extends ConsumerWidget {
  const AppsConsumption({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsConsumptionController =
        ref.watch(appsConsumptionControllerProvider);

    if (appsConsumptionController.hasError) {
      return const SizedBox.shrink();
    }

    final appsConsumptionData = appsConsumptionController.requireValue;

    final cleanerColor = CleanerColor.of(context)!;

    String sizeDisplay(int i) {
      if (i == 0) return appsConsumptionData[i].totalDataUsed.toStringOptimal();
      return appsConsumptionData[i].totalSize.toStringOptimal();
    }

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
              title: 'About consumption',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  contentSection(
                    title: "Data",
                    description:
                        "The applications displayed in this view are sorted based on their data consumption.",
                  ),
                  contentSection(
                    title: "Size",
                    description:
                        "The applications displayed in this view are sorted based on their overall size, which comprises the total of installation files, app data, and cache.",
                  ),
                  contentSection(
                    title: "Battery",
                    description:
                        "The applications displayed in this view are sorted based on the percentage of battery they have consumed in the previous seven days.",
                  ),
                ],
              ),
            );
          });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "High consumption",
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
        const SizedBox(
          height: 32,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (int i = 0; i < appsConsumptionData.length; i++)
              appsConsumptionData[i].type == SortType.batteryUse
                  ? BatteryAppsBlock(
                      iconsData: appsConsumptionData[i].consumptionData,
                      size: sizeDisplay(i),
                      sortType: appsConsumptionData[i].type,
                      showBadge: appsConsumptionData[i].showBadge,
                      periodType: PeriodType.unknown,
                    )
                  : AppsBlock(
                      iconsData: appsConsumptionData[i].consumptionData,
                      size: sizeDisplay(i),
                      sortType: appsConsumptionData[i].type,
                      showBadge: appsConsumptionData[i].showBadge,
                      periodType: PeriodType.unknown,
                    )
          ],
        )
      ],
    );
  }
}
