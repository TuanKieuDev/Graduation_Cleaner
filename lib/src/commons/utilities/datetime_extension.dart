extension DateTimeFunction on DateTime {
  bool get isLessThanAMonth {
    return DateTime.now().difference(this).inDays < 30;
  }

  bool get isMoreThanAMonth {
    return DateTime.now().difference(this).inDays > 30;
  }

  bool isMoreThanMinutesFromNow([int minutes = 5]) {
    return DateTime.now().difference(this).inMinutes >= minutes;
  }
}
