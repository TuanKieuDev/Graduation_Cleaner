import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/features/features.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:phone_cleaner/main.dart';
import 'package:phone_cleaner/services/work_manager/work_task_manager.dart';

part 'quick_boost_controller.g.dart';

@riverpod
class QuickBoostController extends _$QuickBoostController {
  late AppManager appManager;

  @override
  FutureOr<QuickBoostInfo> build() async {
    return const QuickBoostInfo();
  }

  Future<QuickBoostInfoOptimization> clean() async {
    appManager = ref.read(appRepository);
    final value = await appManager.freeUpRam();

    state = AsyncData(
      state.value!.copyWith(
        freeMemory: value.afterRam.bytes,
        savedSpace: value.ramOptimized.bytes,
      ),
    );
    WorkTaskManager.registerPeriodicForJunkCleaningNotifications();
    debugPrint(
        "QuickBoostRam: ${value.beforeRam} | ${value.afterRam} | ${value.ramOptimized}");
    return value;
  }
}
