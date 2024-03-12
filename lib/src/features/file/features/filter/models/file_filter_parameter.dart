import 'package:phone_cleaner/src/features/features.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'file_filter_parameter.freezed.dart';

@freezed
class FileFilterParameter with _$FileFilterParameter {
  const factory FileFilterParameter({
    @Default(FileType.all) FileType fileType,
    @Default(PhotoType.none) PhotoType photoType,
    @Default(FolderType.all) FolderType folderType,
    @Default(SortFileType.date) SortFileType sortFileType,
    @Default(ShowFileType.all) ShowFileType showFileType,
    @Default(GroupType.none) GroupType groupType,
    @Default(true) bool isReversed,
  }) = _FileFilterParameter;
}
