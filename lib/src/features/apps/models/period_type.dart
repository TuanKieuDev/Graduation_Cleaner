enum PeriodType {
  day("24 hrs"),
  week("7 days"),
  month("month"),
  year("year"),
  unknown("Unknown"),
  ;

  const PeriodType(this.description);

  final String description;

  @override
  String toString() => description.toString();
}
