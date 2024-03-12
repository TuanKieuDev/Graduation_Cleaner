class AdUnitContainer {
  AdUnitContainer(this.ids);

  final List<String> ids;
  int index = 0;

  String getId() {
    return ids[index];
  }

  bool changeToAnother() {
    index++;
    if (index >= ids.length) {
      index = 0;
      return false;
    }

    return true;
  }

  void reset() {
    index = 0;
  }
}
