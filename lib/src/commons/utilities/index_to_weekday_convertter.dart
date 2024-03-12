String indexToWeekday(int index) {
  switch (index) {
    case 1:
      return "mon";
    case 2:
      return "tue";
    case 3:
      return "wed";
    case 4:
      return "thu";
    case 5:
      return "fri";
    case 6:
      return "sat";
    case 7:
      return "sun";
    default:
      return "error";
  }
}
