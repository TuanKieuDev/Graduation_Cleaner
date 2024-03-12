enum GroupType {
  none("None"),
  folder("Folder"),
  type("Type");

  const GroupType(this.description);

  final String description;

  @override
  String toString() => description.toString();
}
