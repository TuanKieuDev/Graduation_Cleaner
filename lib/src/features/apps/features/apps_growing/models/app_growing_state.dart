import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/features/apps/features/apps_growing/models/app_growing_info.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_growing_state.freezed.dart';

@freezed
class AppGrowingState with _$AppGrowingState {
  factory AppGrowingState({
    @Default([]) List<AppGrowingInfo> apps,
    required int timeRemaining,
  }) = _AppGrowingState;
}
