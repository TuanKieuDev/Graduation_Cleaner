enum AppType {
  all("All app"),
  installed("Installed"),
  system("System"),
  ignored("Ignored");

  const AppType(this.description);

  final String description;

  @override
  String toString() => description.toString();
}
