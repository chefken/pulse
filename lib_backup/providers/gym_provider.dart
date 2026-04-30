import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/gym_routine.dart';
import '../core/utils/date_utils.dart';

class GymProvider extends ChangeNotifier {
  static const _routineBox  = 'gym_routine';
  static const _sessionBox  = 'gym_sessions';

  Box<GymDay>?     _routineB;
  Box<GymSession>? _sessionB;

  List<GymDay>               _routine  = [];
  Map<String, GymSession>    _sessions = {};

  List<GymDay> get routine => _routine;

  GymDay? get todayPlan {
    final wd = _weekdayShort(DateTime.now().weekday);
    try {
      return _routine.firstWhere((d) => d.weekday == wd);
    } catch (_) {
      return null;
    }
  }

  GymSession? get todaySession =>
      _sessions[PulseDateUtils.formatDateKey(PulseDateUtils.today)];

  bool get todayCompleted => todaySession?.completed ?? false;

  // Last 7 sessions for consistency chart
  List<bool> get last7Completions {
    return List.generate(7, (i) {
      final date = PulseDateUtils.today.subtract(Duration(days: 6 - i));
      final key  = PulseDateUtils.formatDateKey(date);
      final plan = _routine.firstWhere(
        (d) => d.weekday == _weekdayShort(date.weekday),
        orElse: () => GymDay(weekday: '', isRest: true),
      );
      if (plan.isRest) return true; // rest days count as "ok"
      return _sessions[key]?.completed ?? false;
    });
  }

  double get weeklyConsistency {
    final workoutDays = List.generate(7, (i) {
      final date = PulseDateUtils.today.subtract(Duration(days: 6 - i));
      final plan = _routine.firstWhere(
        (d) => d.weekday == _weekdayShort(date.weekday),
        orElse: () => GymDay(weekday: '', isRest: true),
      );
      return plan.isRest ? null : PulseDateUtils.formatDateKey(date);
    }).whereType<String>().toList();

    if (workoutDays.isEmpty) return 0;
    final done = workoutDays
        .where((k) => _sessions[k]?.completed ?? false)
        .length;
    return done / workoutDays.length;
  }

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(GymDayAdapter());
    if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(GymSessionAdapter());

    _routineB  = await Hive.openBox<GymDay>(_routineBox);
    _sessionB  = await Hive.openBox<GymSession>(_sessionBox);

    if (_routineB!.isEmpty) _seedDefaultRoutine();
    _routine  = _routineB!.values.toList();
    _sessions = {for (var s in _sessionB!.values) s.dateKey: s};
    notifyListeners();
  }

  void _seedDefaultRoutine() {
    final defaults = [
      GymDay(weekday: 'Mon', muscleGroup: 'Chest & Triceps'),
      GymDay(weekday: 'Tue', muscleGroup: 'Back & Biceps'),
      GymDay(weekday: 'Wed', muscleGroup: 'Legs'),
      GymDay(weekday: 'Thu', muscleGroup: 'Shoulders & Arms'),
      GymDay(weekday: 'Fri', muscleGroup: 'Full Body'),
      GymDay(weekday: 'Sat', muscleGroup: '', isRest: true),
      GymDay(weekday: 'Sun', muscleGroup: '', isRest: true),
    ];
    for (final d in defaults) _routineB!.add(d);
  }

  Future<void> updateRoutine(List<GymDay> updated) async {
    await _routineB!.clear();
    for (final d in updated) await _routineB!.add(d);
    _routine = _routineB!.values.toList();
    notifyListeners();
  }

  Future<void> toggleTodaySession() async {
    final key = PulseDateUtils.formatDateKey(PulseDateUtils.today);
    if (_sessions.containsKey(key)) {
      final s = _sessions[key]!;
      s.completed = !s.completed;
      await s.save();
    } else {
      final s = GymSession(dateKey: key, completed: true);
      await _sessionB!.add(s);
      _sessions[key] = s;
    }
    notifyListeners();
  }

  Future<void> updateRoutineDay(String weekday, String muscleGroup, bool isRest) async {
    final idx = _routine.indexWhere((d) => d.weekday == weekday);
    if (idx == -1) return;
    _routine[idx]
      ..muscleGroup = muscleGroup
      ..isRest = isRest;
    await _routine[idx].save();
    notifyListeners();
  }

  String _weekdayShort(int wd) =>
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][wd - 1];
}