enum ShowType {
  all("Show all"),
  deepCleaned("Can be Deep cleaned"),
  stop("Can be stopped"),
  ;

  const ShowType(this.description);

  final String description;

  @override
  String toString() => description.toString();
}
