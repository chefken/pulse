import 'package:intl/intl.dart';

class PulseDateUtils {
  PulseDateUtils._();

  static String formatDate(DateTime date) =>
      DateFormat('EEE, d MMM').format(date);

  static String formatDateKey(DateTime date) =>
      DateFormat('yyyy-MM-dd').format(date);

  static String formatMonth(DateTime date) =>
      DateFormat('MMMM yyyy').format(date);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime get today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning.';
    if (hour < 17) return 'Stay focused.';
    return 'Finish strong.';
  }
}