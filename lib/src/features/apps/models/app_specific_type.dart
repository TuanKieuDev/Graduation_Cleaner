enum AppSpecificType {
  total("Total size"),
  app("App size"),
  data("Data size"),
  cache("Cache size"),
  ;

  const AppSpecificType(this.description);

  final String description;

  @override
  String toString() => description.toString();
}
