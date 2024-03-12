abstract class FileQueryParameter {
  const FileQueryParameter();
}

class LargeOldFileParameter extends FileQueryParameter {
  final Duration oldDuration;
  final int minimumBytes;

  const LargeOldFileParameter(this.oldDuration, this.minimumBytes);
}

class LargeNewFileParameter extends FileQueryParameter {
  final Duration newDuration;
  final int minimumBytes;

  const LargeNewFileParameter(this.newDuration, this.minimumBytes);
}

class OldFileParameter extends FileQueryParameter {
  final Duration oldDuration;

  const OldFileParameter(this.oldDuration);
}

class NewFileParameter extends FileQueryParameter {
  final Duration newDuration;

  const NewFileParameter(this.newDuration);
}
