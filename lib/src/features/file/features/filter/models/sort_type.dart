enum SortFileType {
  size("Size"),
  name("Name"),
  date("Date");

  const SortFileType(this.description);

  final String description;

  @override
  String toString() => description.toString();
}
