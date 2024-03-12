class FileChecker {
  List<String> socialsNetwork = ["Messenger/", "Telegram/", "Skype/"];

  late String externalPath;
  late String screenshotFolderPath;
  late String downloadFolderPath;

  FileChecker(this.externalPath) {
    screenshotFolderPath = "$externalPath/DCIM/Screenshots";
    downloadFolderPath = "$externalPath/Download";
  }

  bool isLargeOldFile(DateTime modifiedTime, DateTime latestObsoleteTime,
      int fileSize, int minimumBytes) {
    return isLargePhoto(fileSize, minimumBytes) &&
        isOldFile(modifiedTime, latestObsoleteTime);
  }

  bool isOldFile(DateTime modifiedTime, DateTime latestObsoleteTime) {
    return modifiedTime.isBefore(latestObsoleteTime);
  }

  bool isLargeNewFile(DateTime modifiedTime, DateTime newestPhotoTime,
      int fileSize, int minimumBytes) {
    return isLargePhoto(fileSize, minimumBytes) &&
        isNewFile(modifiedTime, newestPhotoTime);
  }

  bool isNewScreenShot(
      String path, DateTime modifiedTime, DateTime newestPhotoTime) {
    return isScreenShot(path) && isNewFile(modifiedTime, newestPhotoTime);
  }

  bool isNewFile(DateTime modifiedTime, DateTime newestPhotoTime) {
    return modifiedTime.isBefore(newestPhotoTime);
  }

  bool isLargePhoto(int fileSize, int minimumBytes) {
    return fileSize >= minimumBytes;
  }

  bool isScreenShot(String path) {
    return path.startsWith(screenshotFolderPath);
  }

  bool isDownloaded(String path) {
    return path.startsWith(downloadFolderPath);
  }

  bool isSensitiveImage(String path) {
    for (String socialNetwork in socialsNetwork) {
      if (path.contains(socialNetwork)) {
        return true;
      }
    }
    return false;
  }
}
