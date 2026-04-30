import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/streak.dart';
import '../models/day_record.dart';
import '../core/utils/date_utils.dart';

class StreakProvider extends ChangeNotifier {
  Box<StreakData>? _box;
  StreakData _data = StreakData();

  int    get currentStreak => _data.currentStreak;
  int    get longestStreak => _data.longestStreak;
  double get consistency   => _data.consistencyPercent;

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(4))
      Hive.registerAdapter(StreakDataAdapter());
    _box  = await Hive.openBox<StreakData>('streak');
    _data = _box!.get('streak') ?? StreakData();
    notifyListeners();
  }

  Future<void> recalculate(List<DayRecord> records) async {
    if (records.isEmpty) return;
    final sorted = records.toList()
      ..sort((a, b) => a.dateKey.compareTo(b.dateKey));
    final map = {for (var r in sorted) r.dateKey: r};

    // Current streak (walk back from today)
    int current = 0;
    DateTime cursor = PulseDateUtils.today;
    while (true) {
      final key = PulseDateUtils.formatDateKey(cursor);
      final r   = map[key];
      if (r != null && r.isGoodDay) {
        current++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    int longest = 0, temp = 0, active = 0;
    for (final r in sorted) {
      if (r.isGoodDay) {
        active++;
        temp++;
        if (temp > longest) longest = temp;
      } else {
        temp = 0;
      }
    }

    _data
      ..currentStreak   = current
      ..longestStreak   = longest > _data.longestStreak
          ? longest
          : _data.longestStreak
      ..totalActiveDays = active
      ..totalDays       = sorted.length;

    await _box!.put('streak', _data);
    notifyListeners();
  }
}