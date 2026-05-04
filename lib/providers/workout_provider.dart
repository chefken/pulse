import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/workout_log.dart';
import '../core/utils/date_utils.dart';

class WorkoutProvider extends ChangeNotifier {
  Box<WorkoutLog>?        _box;
  Map<String, WorkoutLog> _logs = {};

  WorkoutLog? logFor(String dateKey) => _logs[dateKey];
  WorkoutLog? get todayLog =>
      _logs[PulseDateUtils.formatDateKey(PulseDateUtils.today)];

  Set<String> get allExerciseNames {
    final names = <String>{};
    for (final l in _logs.values) {
      for (final e in l.exercises) names.add(e.name);
    }
    return names;
  }

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(7))
      Hive.registerAdapter(ExerciseSetAdapter());
    if (!Hive.isAdapterRegistered(8))
      Hive.registerAdapter(WorkoutExerciseAdapter());
    if (!Hive.isAdapterRegistered(9))
      Hive.registerAdapter(WorkoutLogAdapter());
    _box  = await Hive.openBox<WorkoutLog>('workout_logs');
    _logs = {for (var l in _box!.values) l.dateKey: l};
    notifyListeners();
  }

  Future<WorkoutLog> getOrCreate({
    required String dateKey,
    required String muscleGroup,
  }) async {
    if (_logs.containsKey(dateKey)) return _logs[dateKey]!;
    final log = WorkoutLog.create(
        dateKey: dateKey, muscleGroup: muscleGroup);
    await _box!.put(log.id, log);
    _logs[dateKey] = log;
    notifyListeners();
    return log;
  }

  Future<void> addExercise(String dateKey, String name) async {
    final log = _logs[dateKey]; if (log == null) return;
    log.exercises.add(WorkoutExercise.create(name));
    await log.save(); notifyListeners();
  }

  Future<void> deleteExercise(String dateKey, String exId) async {
    final log = _logs[dateKey]; if (log == null) return;
    log.exercises.removeWhere((e) => e.id == exId);
    await log.save(); notifyListeners();
  }

  Future<void> addSet(String dateKey, String exId,
      {double weight = 0, int reps = 0}) async {
    final log = _logs[dateKey]; if (log == null) return;
    final ex  = log.exercises.firstWhere((e) => e.id == exId);
    ex.sets.add(ExerciseSet.create(weight: weight, reps: reps));
    await log.save(); notifyListeners();
  }

  Future<void> updateSet(String dateKey, String exId, String setId,
      {required double weight, required int reps}) async {
    final log = _logs[dateKey]; if (log == null) return;
    final ex  = log.exercises.firstWhere((e) => e.id == exId);
    final s   = ex.sets.firstWhere((s) => s.id == setId);
    s.weight  = weight; s.reps = reps;
    await log.save(); notifyListeners();
  }

  Future<void> deleteSet(
      String dateKey, String exId, String setId) async {
    final log = _logs[dateKey]; if (log == null) return;
    final ex  = log.exercises.firstWhere((e) => e.id == exId);
    ex.sets.removeWhere((s) => s.id == setId);
    await log.save(); notifyListeners();
  }

  Future<void> toggleCompleted(String dateKey) async {
    final log = _logs[dateKey]; if (log == null) return;
    log.completed = !log.completed;
    await log.save(); notifyListeners();
  }
}