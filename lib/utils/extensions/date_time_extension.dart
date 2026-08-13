import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  /// Formats as `Jul 28th 7:35am`.
  String toMeasuredLabel({bool isHourly = false}) {
    final local = toLocal();
    final month = DateFormat('MMM').format(local);
    final day = '${local.day}${_dayOrdinal(local.day)}';
    final hour12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour < 12 ? 'am' : 'pm';
    return '$month $day ${isHourly ? '$hour12:$minute$period' : ''}';
  }
}

String _dayOrdinal(int day) {
  if (day >= 11 && day <= 13) return 'th';
  return switch (day % 10) {
    1 => 'st',
    2 => 'nd',
    3 => 'rd',
    _ => 'th',
  };
}
