enum OriginalOption {
  backup("Back and delete originals"),
  delete("Just delete"),
  keepOriginal("Keep originals");

  const OriginalOption(this.description);

  final String description;

  @override
  String toString() => description.toString();
}
