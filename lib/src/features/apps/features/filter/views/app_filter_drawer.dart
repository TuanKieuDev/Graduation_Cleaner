import 'package:phone_cleaner/src/features/apps/models/app_specific_type.dart';
import 'package:phone_cleaner/src/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../commons/commons.dart';
import '../../../../features.dart';
import '../../../../file/features/filter/views/file_filter_drawer.dart';

class AppFilterDrawer extends ConsumerWidget {
  const AppFilterDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cleanerColor = CleanerColor.of(context)!;
    final params = ref.watch(appFilterControllerProvider
        .select((value) => value.valueOrNull?.appFilterParameter));

    void updateFilterParameters(AppFilterParameter params) {
      ref.read(appFilterControllerProvider.notifier).setParameters(params);
    }

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
                    'Filters',
                    style: bold24,
                    gradient: cleanerColor.gradient1,
                  ),
                  FilterGroup<AppType>(
                    label: 'App type',
                    options: AppType.values,
                    selected: params?.appType,
                    onOptionSeleted: (value) => updateFilterParameters(
                        params!.copyWith(appType: value)),
                  ),

                  FilterGroup<SortType>(
                    label: 'Sort type',
                    options: SortType.values,
                    selected: params?.sortType,
                    onOptionSeleted: (value) => updateFilterParameters(
                        params!.copyWith(sortType: value)),
                  ),

                  if (params != null && params.sortType == SortType.size)
                    FilterGroup<AppSpecificType>(
                      label: 'Allowed by',
                      options: AppSpecificType.values,
                      selected: params.specificType,
                      onOptionSeleted: (value) {
                        updateFilterParameters(
                            params.copyWith(specificType: value));
                      },
                    ),

                  // FilterGroup<ShowType>(
                  //   label: 'Show type',
                  //   options: ShowType.values,
                  //   selected: params?.showType,
                  //   onOptionSeleted: (value) => updateFilterParameters(
                  //       params!.copyWith(showType: value)),
                  // ),

                  //Time period
                  if (params != null &&
                      (params.sortType == SortType.screenTime ||
                          params.sortType == SortType.timeOpened ||
                          params.sortType == SortType.unused))
                    FilterGroup<PeriodType>(
                      label: 'Period type',
                      options: PeriodType.values.take(2).toList(),
                      selected: params.periodType,
                      onOptionSeleted: (value) => updateFilterParameters(
                          params.copyWith(periodType: value)),
                    ),
                ],
              ),
            ),
            const SizedBox(
              height: 7,
            ),
          ]),
    );
  }
}
