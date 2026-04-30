import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/gym_routine.dart';
import '../core/utils/date_utils.dart';

class GymProvider extends ChangeNotifier {
  Box<GymDay>?     _routineBox;
  Box<GymSession>? _sessionBox;

  List<GymDay>             _routine  = [];
  Map<String, GymSession>  _sessions = {};

  List<GymDay>            get routine  => _routine;
  Map<String, GymSession> get sessions => _sessions;

  GymDay? get todayPlan {
    final wd = _wd(DateTime.now().weekday);
    try { return _routine.firstWhere((d) => d.weekday == wd); }
    catch (_) { return null; }
  }

  bool get todayCompleted =>
      _sessions[PulseDateUtils.formatDateKey(PulseDateUtils.today)]
          ?.completed ??
      false;

  bool sessionCompletedOn(DateTime date) =>
      _sessions[PulseDateUtils.formatDateKey(date)]?.completed ?? false;

  List<bool> get last7Completions => List.generate(7, (i) {
    final d    = PulseDateUtils.today.subtract(Duration(days: 6 - i));
    final plan = _routine.firstWhere(
      (r) => r.weekday == _wd(d.weekday),
      orElse: () => GymDay(weekday: '', isRest: true),
    );
    if (plan.isRest) return true;
    return _sessions[PulseDateUtils.formatDateKey(d)]?.completed ?? false;
  });

  double get weeklyConsistency {
    final days = List.generate(7, (i) {
      final d    = PulseDateUtils.today.subtract(Duration(days: 6 - i));
      final plan = _routine.firstWhere(
        (r) => r.weekday == _wd(d.weekday),
        orElse: () => GymDay(weekday: '', isRest: true),
      );
      return plan.isRest ? null : PulseDateUtils.formatDateKey(d);
    }).whereType<String>().toList();
    if (days.isEmpty) return 0;
    final done = days.where((k) => _sessions[k]?.completed ?? false).length;
    return done / days.length;
  }

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(GymDayAdapter());
    if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(GymSessionAdapter());
    _routineBox = await Hive.openBox<GymDay>('gym_routine');
    _sessionBox = await Hive.openBox<GymSession>('gym_sessions');
    if (_routineBox!.isEmpty) _seed();
    _routine  = _routineBox!.values.toList();
    _sessions = {for (var s in _sessionBox!.values) s.dateKey: s};
    notifyListeners();
  }

  void _seed() {
    final defaults = [
      GymDay(weekday: 'Mon', muscleGroup: 'Chest & Triceps'),
      GymDay(weekday: 'Tue', muscleGroup: 'Back & Biceps'),
      GymDay(weekday: 'Wed', muscleGroup: 'Legs'),
      GymDay(weekday: 'Thu', muscleGroup: 'Shoulders & Arms'),
      GymDay(weekday: 'Fri', muscleGroup: 'Full Body'),
      GymDay(weekday: 'Sat', isRest: true),
      GymDay(weekday: 'Sun', isRest: true),
    ];
    for (final d in defaults) _routineBox!.add(d);
  }

  Future<void> toggleTodaySession() async {
    final key = PulseDateUtils.formatDateKey(PulseDateUtils.today);
    if (_sessions.containsKey(key)) {
      _sessions[key]!.completed = !_sessions[key]!.completed;
      await _sessions[key]!.save();
    } else {
      final s = GymSession(dateKey: key, completed: true);
      await _sessionBox!.add(s);
      _sessions[key] = s;
    }
    notifyListeners();
  }

  Future<void> updateRoutine(List<GymDay> updated) async {
    await _routineBox!.clear();
    for (final d in updated) await _routineBox!.add(d);
    _routine = _routineBox!.values.toList();
    notifyListeners();
  }

  String _wd(int w) =>
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][w - 1];
}