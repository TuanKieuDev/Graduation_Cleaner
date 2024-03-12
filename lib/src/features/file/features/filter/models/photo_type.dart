enum PhotoType {
  none("None"),
  optimize("Optimizable"),
  similar("Similar"),
  sensitive("Sensitive"),
  bad("Low quality");

  const PhotoType(this.description);

  final String description;

  @override
  String toString() => description.toString();
}
