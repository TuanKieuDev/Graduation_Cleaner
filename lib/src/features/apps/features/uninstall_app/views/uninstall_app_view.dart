// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:phone_cleaner/router/router.dart';
import 'package:phone_cleaner/services/logger/logger.dart';
import 'package:phone_cleaner/services/notifications/notification_services.dart';
import 'package:phone_cleaner/services/work_manager/work_task.dart';
import 'package:phone_cleaner/src/commons/widgets/lottie_looper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/features/features.dart';
import 'package:go_router/go_router.dart';

class UninstallAppArguments {
  final List<AppCheckboxItemData> appUninstall;
  UninstallAppArguments({
    required this.appUninstall,
  });
}

class UninstallAppView extends ConsumerStatefulWidget {
  final UninstallAppArguments uninstallAppArguments;
  const UninstallAppView({
    super.key,
    required this.uninstallAppArguments,
  });
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _UnInstallAppViewState();
}

class _UnInstallAppViewState extends ConsumerState<UninstallAppView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    appLogger.debug('UnInstallAppView build');
    final isLoading = ref.watch(
      uninstallAppControllerProvider(widget.uninstallAppArguments)
          .select((value) => value.isLoading),
    );
    final state = ref
        .watch(uninstallAppControllerProvider(widget.uninstallAppArguments))
        .valueOrNull;
    return LottieLooper(
      'assets/lotties/uninstall_app.json',
      loop: isLoading,
      height: 300,
      width: 300,
      onStop: () {
        GoRouter.of(context).pushReplacement(
          AppRouter.result,
          extra: ResultArgs(
            title: 'Uninstall',
            savedValue: state?.saveValue ?? 0.kb,
            successResults: state?.successResults ?? [],
          ),
        );
        NotificationServices.showCommonNotification(
          title: 'Quick Clean',
          body: 'Clean up unnecessary things',
          payload: WorkTask.quickClean,
        );
      },
    );
  }
}
