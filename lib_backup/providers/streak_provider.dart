import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/streak.dart';
import '../models/day_record.dart';
import '../core/utils/date_utils.dart';

class StreakProvider extends ChangeNotifier {
  static const _boxName = 'streak';
  Box<StreakData>? _box;

  StreakData _data = StreakData();
  StreakData get data => _data;

  int get currentStreak  => _data.currentStreak;
  int get longestStreak  => _data.longestStreak;
  double get consistency => _data.consistencyPercent;

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(StreakDataAdapter());
    _box = await Hive.openBox<StreakData>(_boxName);
    _data = _box!.get('streak') ?? StreakData();
    notifyListeners();
  }

  Future<void> recalculate(List<DayRecord> records) async {
    if (records.isEmpty) return;

    final sorted = records.toList()
      ..sort((a, b) => a.dateKey.compareTo(b.dateKey));

    int current = 0;
    int longest = 0;
    int active  = 0;

    // Walk backwards from today to calc current streak
    DateTime cursor = PulseDateUtils.today;
    final recordMap = {for (var r in sorted) r.dateKey: r};

    while (true) {
      final key = PulseDateUtils.formatDateKey(cursor);
      final rec = recordMap[key];
      if (rec != null && rec.isGoodDay) {
        current++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    // Total active days + longest streak
    int tempStreak = 0;
    for (final rec in sorted) {
      if (rec.isGoodDay) {
        active++;
        tempStreak++;
        if (tempStreak > longest) longest = tempStreak;
      } else {
        tempStreak = 0;
      }
    }

    _data
      ..currentStreak  = current
      ..longestStreak  = longest > _data.longestStreak ? longest : _data.longestStreak
      ..totalActiveDays = active
      ..totalDays      = sorted.length
      ..lastActiveDate = sorted.last.dateKey;

    await _box!.put('streak', _data);
    notifyListeners();
  }
}