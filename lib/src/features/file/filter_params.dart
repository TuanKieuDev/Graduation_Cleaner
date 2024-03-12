import 'features/filter/filter.dart';
import 'models/models.dart';

const mediaFolderFilterParam = FileFilterParameter(
  fileType: FileType.media,
  photoType: PhotoType.none,
  showFileType: ShowFileType.all,
  sortFileType: SortFileType.size,
  groupType: GroupType.folder,
  isReversed: true,
);

const similarPhotosFilterParam = FileFilterParameter(
  fileType: FileType.photo,
  photoType: PhotoType.similar,
  showFileType: ShowFileType.all,
  sortFileType: SortFileType.date,
  groupType: GroupType.folder,
);

const badPhotosFilterParam = FileFilterParameter(
  fileType: FileType.photo,
  photoType: PhotoType.bad,
  showFileType: ShowFileType.all,
  sortFileType: SortFileType.date,
  groupType: GroupType.none,
);

const sensitivePhotosFilterParam = FileFilterParameter(
  fileType: FileType.photo,
  photoType: PhotoType.sensitive,
  showFileType: ShowFileType.all,
  sortFileType: SortFileType.date,
  groupType: GroupType.none,
);

const oldPhotosFilterParam = FileFilterParameter(
  fileType: FileType.photo,
  photoType: PhotoType.none,
  showFileType: ShowFileType.month,
  sortFileType: SortFileType.date,
  groupType: GroupType.none,
  isReversed: true,
);

const optimizedPhotosFilterParam = FileFilterParameter(
  fileType: FileType.photo,
  photoType: PhotoType.optimize,
  showFileType: ShowFileType.all,
  sortFileType: SortFileType.date,
  groupType: GroupType.none,
);

const largeVideosFilterParam = FileFilterParameter(
  fileType: FileType.video,
  photoType: PhotoType.none,
  showFileType: ShowFileType.size,
  sortFileType: SortFileType.size,
  groupType: GroupType.none,
);

const screenshotsFilterParam = FileFilterParameter(
  fileType: FileType.photo,
  showFileType: ShowFileType.all,
  folderType: FolderType.screenShot,
  sortFileType: SortFileType.date,
  groupType: GroupType.none,
);

const largeFilesFilterParam = FileFilterParameter(
  fileType: FileType.other,
  showFileType: ShowFileType.size,
  sortFileType: SortFileType.date,
  groupType: GroupType.none,
);
