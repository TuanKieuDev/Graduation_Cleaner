enum ImportantLevel {
  /// Not needed, the data can be recreated easily
  low("Unneeded files"),

  /// Needs review, cannot guarantee to be recreated
  medium("Files to review"),

  /// Needs review, cannot be recreated
  high("Dangerous files");

  bool operator >(ImportantLevel other) {
    return index > other.index;
  }

  bool operator <(ImportantLevel other) {
    return index < other.index;
  }

  bool operator >=(ImportantLevel other) {
    return index > other.index || this == other;
  }

  bool operator <=(ImportantLevel other) {
    return index < other.index || this == other;
  }

  const ImportantLevel(this.description);

  final String description;

  @override
  String toString() => description.toString();
}
