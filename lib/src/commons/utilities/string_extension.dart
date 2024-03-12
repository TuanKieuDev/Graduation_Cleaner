import 'package:diacritic/diacritic.dart';

extension StringExtension on String {
  String get toDiacriticsRemove {
    return removeDiacritics(this);
  }

  String get folderOptimalName {
    final nameTemporary = substring(0, lastIndexOf('/'));
    final nameStartIndex = nameTemporary.lastIndexOf('/');
    return substring(nameStartIndex + 1);
  }

  int compareIgnoreCaseAndDiacriticsTo(String b) {
    return toUpperCase()
        .toDiacriticsRemove
        .compareTo(b.toUpperCase().toDiacriticsRemove);
  }
}
