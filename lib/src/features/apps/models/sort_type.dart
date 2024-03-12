enum SortType {
  size("Size"),
  sizeChange("Size change"),
  name("Name"),
  screenTime("Screen time"),
  batteryUse("Battery use"),
  dataUse("Data use"),
  notification("Notifications"),
  lastUsed("Last used"),
  timeOpened("Time opened"),
  unused("Unused"),
  ;

  const SortType(this.description);

  final String description;

  @override
  String toString() => description.toString();
}
