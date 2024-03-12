enum ShowFileType {
  all("All"),
  month("1 month or older"),
  size(">20 MB");

  const ShowFileType(this.description);

  final String description;

  @override
  String toString() => description.toString();
}
