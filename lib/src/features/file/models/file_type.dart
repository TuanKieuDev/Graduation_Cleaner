enum FileType {
  all("All files"),
  media("All media"),
  photo("Photo"),
  video("Video"),
  audio("Audio"),
  other("Other files");

  const FileType(this.description);

  final String description;

  @override
  String toString() => description.toString();

  String? get mimeTypePrefix {
    if (equals(FileType.audio)) {
      return 'audio';
    }

    if (equals(FileType.video)) {
      return 'video';
    }

    if (equals(FileType.photo)) {
      return 'image';
    }

    return null;
  }

  bool equals(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    if (other is! FileType) {
      return false;
    }

    var otherFileType = other;

    switch (otherFileType) {
      case FileType.all:
        return true;
      case FileType.media:
        return this == FileType.photo ||
            this == FileType.video ||
            this == FileType.audio;
      case FileType.photo:
        return this == FileType.photo;
      case FileType.video:
        return this == FileType.video;
      case FileType.audio:
        return this == FileType.audio;
      case FileType.other:
        return this == FileType.other;
    }
  }
}
