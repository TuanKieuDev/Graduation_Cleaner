import 'dart:collection';
import 'dart:typed_data';

import 'package:phone_cleaner/main.dart';
import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/fake_data.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final batteryBoostControllerProvider = StateNotifierProvider<
    BatteryBoostController, AsyncValue<List<AppCheckboxItemData?>>>(
  (ref) {
    return BatteryBoostController(ref.read(generalInfoRepository));
  },
);

class BatteryBoostController
    extends StateNotifier<AsyncValue<List<AppCheckboxItemData?>>> {
  BatteryBoostController(this.infoManager)
      : super(const AsyncData<List<AppCheckboxItemData?>>([])) {
    fetchData();
  }

  final GeneralInfoManager infoManager;

  Future fetchData() async {
    if (state.hasValue) {
      state = const AsyncValue<List<AppCheckboxItemData?>>.loading()
          .copyWithPrevious(state);
    } else {
      state = const AsyncLoading();
    }

    final fakeData = FakeData();
    final fakeIcons =
        Queue<Uint8List>.from(await fakeData.takeRandomIconsAsync(10).toList());
    state = const AsyncValue.data([]);
  }

  int getAppSelected() {
    int total = 0;
    for (var item in state.value!) {
      if (item!.checked) {
        total++;
      }
    }
    return total;
  }

  int getBatteryLifeExtend() {
    return 5;
  }

  void modifyTickedAllState() {
    final newState = state.value!;
    bool value = false;
    for (var item in newState) {
      if (item!.checked) value = true;
    }
    final newValue = !value;
    for (int i = 0; i < newState.length; i++) {
      newState[i] = newState[i]?.copyWith(checked: newValue);
      state = AsyncData(newState);
    }
  }
}
