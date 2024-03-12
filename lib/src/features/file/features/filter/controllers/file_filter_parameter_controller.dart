import 'package:phone_cleaner/src/features/file/features/filter/models/file_filter_parameter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'file_filter_parameter_controller.g.dart';

@riverpod
class FileFilterParameterController extends _$FileFilterParameterController {
  @override
  FileFilterParameter build() {
    return const FileFilterParameter();
  }
}
