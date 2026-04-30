import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/day_record.dart';
import '../core/utils/date_utils.dart';

class ScoreProvider extends ChangeNotifier {
  static const _boxName = 'day_records';
  Box<DayRecord>? _box;
  Map<String, DayRecord> _records = {};

  DayRecord? get todayRecord =>
      _records[PulseDateUtils.formatDateKey(PulseDateUtils.today)];

  double get todayScore => todayRecord?.disciplineScore ?? 0.0;

  List<DayRecord> get allRecords => _records.values.toList()
    ..sort((a, b) => a.dateKey.compareTo(b.dateKey));

  DayRecord? recordFor(String dateKey) => _records[dateKey];

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(3))
      Hive.registerAdapter(DayRecordAdapter());
    _box     = await Hive.openBox<DayRecord>(_boxName);
    _records = {for (var r in _box!.values) r.dateKey: r};
    notifyListeners();
  }

  Future<void> updateTodayScore({
    required int earned,
    required int total,
    required int completedTasks,
    required int totalTasks,
    List<String> completedHabitTitles = const [],
    List<String> completedTaskTitles  = const [],
  }) async {
    final key    = PulseDateUtils.formatDateKey(PulseDateUtils.today);
    final score  = total == 0 ? 0.0 : (earned / total).clamp(0.0, 1.0);
    final record = _records[key] ?? DayRecord.create(key);

    record
      ..disciplineScore         = score
      ..earnedPoints            = earned
      ..totalPoints             = total
      ..completedTasks          = completedTasks
      ..totalTasks              = totalTasks
      ..completedHabitTitles    = completedHabitTitles
      ..completedTaskTitles     = completedTaskTitles;

    await _box!.put(key, record);
    _records[key] = record;
    notifyListeners();
  }

  Future<void> saveMoodRating(int rating) async {
    final key    = PulseDateUtils.formatDateKey(PulseDateUtils.today);
    final record = _records[key] ?? DayRecord.create(key);
    record
      ..userRating  = rating
      ..isReviewed  = true;
    await _box!.put(key, record);
    _records[key] = record;
    notifyListeners();
  }

  List<DayRecord> get last30Days {
    final cutoff = PulseDateUtils.today.subtract(const Duration(days: 30));
    return allRecords.where((r) {
      final d = DateTime.parse(r.dateKey);
      return !d.isBefore(cutoff);
    }).toList();
  }
}