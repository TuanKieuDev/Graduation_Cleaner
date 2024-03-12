import 'dart:math';

import 'package:phone_cleaner/router/router.dart';
import 'package:phone_cleaner/services/logger/logger.dart';
import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/features/features.dart';
import 'package:phone_cleaner/src/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LargeAppsPartView extends ConsumerStatefulWidget {
  const LargeAppsPartView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _LargeAppsPartViewState();
}

class _LargeAppsPartViewState extends ConsumerState<LargeAppsPartView> {
  void toggleAppItem(int index) {
    ref.read(largeAppsControllerProvider.notifier).toggleAppItem(index);
  }

  void goToFilterPage() {
    GoRouter.of(context).pushNamed(
      AppRouter.listApp,
      extra: const AppFilterArguments(
        appFilterParameter: largeAppsParams,
      ),
    );
  }

  void toggleUnInstall() {
    final checkedApp = ref
        .read(largeAppsControllerProvider)
        .value!
        .apps
        .where((element) => element.checked)
        .toList();
    GoRouter.of(context).pushNamed(
      AppRouter.uninstallApp,
      extra: UninstallAppArguments(appUninstall: checkedApp),
    );
    appLogger.info('Remove app success');
  }

  Function(AsyncValue? previous, AsyncValue next) logOnError() =>
      (previous, next) {
        if (previous?.hasError == true) {
          return;
        }

        if (next.hasError) {
          appLogger.error('Large Apps Part Error', next.error, next.stackTrace);
          GoRouter.of(context).pushNamed(
            AppRouter.error,
            extra: CleanerException(message: 'Some thing went wrong'),
          );
        }
      };
  @override
  Widget build(BuildContext context) {
    ref.listen(largeAppsControllerProvider, logOnError());

    final appsData = ref.watch(largeAppsControllerProvider);

    if (appsData.isLoading || appsData.value == null) {
      return const SizedBox.shrink();
    }
    final cleanerColor = CleanerColor.of(context)!;
    final state = appsData.value!;

    final apps = state.apps;
    final appItemCount = min(apps.length, 5);
    final appCanOptimizeTotalSize = state.appCanOptimizeTotalSize;

    final titleView = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Large Apps',
            style: semibold18.copyWith(color: cleanerColor.primary10),
          ),
          AllButton(
            onPress: goToFilterPage,
          ),
        ],
      ),
    );

    final subTitle = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'Apps that take up the most storage',
        style: regular14,
      ),
    );

    final appItemView = ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        return AppTipCheckboxItem(
          data: apps[index],
          onTap: () => toggleAppItem(index),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          selectedBackgroundColor: cleanerColor.primary2,
        );
      },
      itemCount: appItemCount,
    );

    final bottomView = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.appCheckedCount <= 1
                    ? 'Selected ${state.appCheckedCount} app'
                    : 'Selected ${state.appCheckedCount} apps',
                style: regular14,
              ),
              Text(
                state.appCheckedTotalSize.toStringOptimal(),
                style: semibold16.copyWith(color: cleanerColor.primary7),
              ),
            ],
          ),
          PrimaryButton(
            enable: state.canUnInstall,
            title: const Text('Uninstall'),
            onPressed: toggleUnInstall,
            borderRadius: BorderRadius.circular(16),
          )
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleView,
        subTitle,
        const SizedBox(height: 12),
        appItemView,
        const SizedBox(height: 11),
        bottomView
      ],
    );
  }
}
