import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/workout_log.dart';
import '../core/utils/date_utils.dart';

class WorkoutProvider extends ChangeNotifier {
  static const _box = 'workout_logs';
  Box<WorkoutLog>? _b;
  Map<String, WorkoutLog> _logs = {};

  Map<String, WorkoutLog> get logs => _logs;

  WorkoutLog? logFor(String dateKey) => _logs[dateKey];
  WorkoutLog? get todayLog =>
      _logs[PulseDateUtils.formatDateKey(PulseDateUtils.today)];

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(7))
      Hive.registerAdapter(ExerciseSetAdapter());
    if (!Hive.isAdapterRegistered(8))
      Hive.registerAdapter(WorkoutExerciseAdapter());
    if (!Hive.isAdapterRegistered(9))
      Hive.registerAdapter(WorkoutLogAdapter());

    _b = await Hive.openBox<WorkoutLog>(_box);
    _logs = {for (var l in _b!.values) l.dateKey: l};
    notifyListeners();
  }

  // Get or create log for a date
  Future<WorkoutLog> getOrCreate(
      {required String dateKey, required String muscleGroup}) async {
    if (_logs.containsKey(dateKey)) return _logs[dateKey]!;
    final log = WorkoutLog.create(
        dateKey: dateKey, muscleGroup: muscleGroup);
    await _b!.put(log.id, log);
    _logs[dateKey] = log;
    notifyListeners();
    return log;
  }

  // Add exercise
  Future<void> addExercise(String dateKey, String name) async {
    final log = _logs[dateKey];
    if (log == null) return;
    log.exercises.add(WorkoutExercise.create(name));
    await log.save();
    notifyListeners();
  }

  // Delete exercise
  Future<void> deleteExercise(String dateKey, String exerciseId) async {
    final log = _logs[dateKey];
    if (log == null) return;
    log.exercises.removeWhere((e) => e.id == exerciseId);
    await log.save();
    notifyListeners();
  }

  // Rename exercise
  Future<void> renameExercise(
      String dateKey, String exerciseId, String newName) async {
    final log = _logs[dateKey];
    if (log == null) return;
    final ex = log.exercises.firstWhere((e) => e.id == exerciseId);
    ex.name = newName;
    await log.save();
    notifyListeners();
  }

  // Add set
  Future<void> addSet(String dateKey, String exerciseId,
      {double weight = 0, int reps = 0}) async {
    final log = _logs[dateKey];
    if (log == null) return;
    final ex = log.exercises.firstWhere((e) => e.id == exerciseId);
    ex.sets.add(ExerciseSet.create(weight: weight, reps: reps));
    await log.save();
    notifyListeners();
  }

  // Update set
  Future<void> updateSet(String dateKey, String exerciseId, String setId,
      {required double weight, required int reps}) async {
    final log = _logs[dateKey];
    if (log == null) return;
    final ex = log.exercises.firstWhere((e) => e.id == exerciseId);
    final s = ex.sets.firstWhere((s) => s.id == setId);
    s.weight = weight;
    s.reps = reps;
    await log.save();
    notifyListeners();
  }

  // Delete set
  Future<void> deleteSet(
      String dateKey, String exerciseId, String setId) async {
    final log = _logs[dateKey];
    if (log == null) return;
    final ex = log.exercises.firstWhere((e) => e.id == exerciseId);
    ex.sets.removeWhere((s) => s.id == setId);
    await log.save();
    notifyListeners();
  }

  // Toggle completed
  Future<void> toggleCompleted(String dateKey) async {
    final log = _logs[dateKey];
    if (log == null) return;
    log.completed = !log.completed;
    await log.save();
    notifyListeners();
  }

  // Weight progression for a given exercise name (for chart)
  List<MapEntry<String, double>> progressionFor(String exerciseName) {
    final entries = <MapEntry<String, double>>[];
    final sorted = _logs.values.toList()
      ..sort((a, b) => a.dateKey.compareTo(b.dateKey));
    for (final log in sorted) {
      for (final ex in log.exercises) {
        if (ex.name.toLowerCase() == exerciseName.toLowerCase() &&
            ex.maxWeight > 0) {
          entries.add(MapEntry(log.dateKey, ex.maxWeight));
        }
      }
    }
    return entries;
  }

  // All unique exercise names ever logged
  Set<String> get allExerciseNames {
    final names = <String>{};
    for (final log in _logs.values) {
      for (final ex in log.exercises) {
        names.add(ex.name);
      }
    }
    return names;
  }
}