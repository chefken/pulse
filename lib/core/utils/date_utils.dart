import 'package:intl/intl.dart';

class PulseDateUtils {
  PulseDateUtils._();

  static String formatDateKey(DateTime d) =>
      DateFormat('yyyy-MM-dd').format(d);

  static String formatDisplay(DateTime d) =>
      DateFormat('EEE, d MMM').format(d);

  static String formatFull(DateTime d) =>
      DateFormat('EEEE, d MMMM yyyy').format(d);

  static String formatMonth(DateTime d) =>
      DateFormat('MMMM yyyy').format(d);

  static DateTime get today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning.';
    if (h < 17) return 'Good afternoon.';
    return 'Good evening.';
  }
}