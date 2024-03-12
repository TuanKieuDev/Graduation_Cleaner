enum FolderType {
  all("All folders"),
  camera("Camera"),
  download("Download"),
  screenShot("Screenshots");

  const FolderType(this.description);

  final String description;

  @override
  String toString() => description.toString();
}
