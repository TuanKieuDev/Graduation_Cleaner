import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/features/apps/apps.dart';
import 'package:phone_cleaner/src/features/apps/models/app_specific_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_filter_parameter.freezed.dart';

@freezed
class AppFilterParameter with _$AppFilterParameter {
  const factory AppFilterParameter({
    @Default(SortType.size) SortType sortType,
    @Default(AppType.all) AppType appType,
    @Default(ShowType.all) ShowType showType,
    @Default(PeriodType.day) PeriodType periodType,
    @Default(AppSpecificType.total) AppSpecificType specificType,
    @Default(false) bool isReversed,
    @Default(false) bool isRarelyUsed,
  }) = _AppFilterParameter;
}
