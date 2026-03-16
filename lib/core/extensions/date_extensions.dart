extension DateFormattingX on DateTime {
  String toIsoDate() => toIso8601String().split('T').first;
}
