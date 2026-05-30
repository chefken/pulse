import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import '../core/utils/date_utils.dart';

class TaskProvider extends ChangeNotifier {
  static const _boxName = 'tasks';
  Box<Task>? _box;
  List<Task> _tasks = [];

  String get _todayKey =>
      PulseDateUtils.formatDateKey(PulseDateUtils.today);

  // ── Sorted lists ───────────────────────────────────────────

  List<Task> get todayTasks {
    final habits = _tasks
        .where((t) => t.type == TaskType.habit && !t.isSkippedOn(_todayKey))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final oneTime = _tasks
        .where((t) => t.type == TaskType.oneTime && t.dateKey == _todayKey)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return [...habits, ...oneTime];
  }

  List<Task> get habits => _tasks
      .where((t) => t.type == TaskType.habit)
      .toList()
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  List<Task> get completedToday =>
      todayTasks.where((t) => t.isCompleted).toList();

  int get earnedPoints =>
      completedToday.fold(0, (s, t) => s + t.points);

  int get totalPoints =>
      todayTasks.fold(0, (s, t) => s + t.points);

  // ── Init ───────────────────────────────────────────────────

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(0))
      Hive.registerAdapter(TaskPriorityAdapter());
    if (!Hive.isAdapterRegistered(1))
      Hive.registerAdapter(TaskTypeAdapter());
    if (!Hive.isAdapterRegistered(2))
      Hive.registerAdapter(TaskAdapter());

    _box   = await Hive.openBox<Task>(_boxName);
    _tasks = _box!.values.toList();

    // Back-fill sortOrder for tasks created before this field existed
    bool needsSave = false;
    for (int i = 0; i < _tasks.length; i++) {
      if (_tasks[i].sortOrder == 0 && i > 0) {
        _tasks[i].sortOrder = i;
        needsSave = true;
      }
    }
    if (needsSave) {
      for (final t in _tasks) await t.save();
    }

    _resetHabitsIfNewDay();
    notifyListeners();
  }

  void _resetHabitsIfNewDay() {
    final today   = _todayKey;
    bool  changed = false;
    for (final task in _tasks) {
      if (task.type == TaskType.habit && task.isCompleted) {
        if (!task.completedDates.contains(today)) {
          task.isCompleted = false;
          task.save();
          changed = true;
        }
      }
    }
    if (changed) _tasks = _box!.values.toList();
  }

  // ── Next sort order ────────────────────────────────────────

  int _nextSortOrder(TaskType type) {
    final same = _tasks.where((t) => t.type == type);
    if (same.isEmpty) return 0;
    return same.map((t) => t.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
  }

  // ── CRUD ───────────────────────────────────────────────────

  Future<void> addTask(Task task) async {
    // Assign next sort order if not set
    if (task.sortOrder == 0) {
      task.sortOrder = _nextSortOrder(task.type);
    }
    await _box!.put(task.id, task);
    _tasks = _box!.values.toList();
    notifyListeners();
  }

  Future<void> toggleTask(String id) async {
    final t = _box!.get(id);
    if (t == null) return;
    t.isCompleted = !t.isCompleted;
    if (t.isCompleted) {
      if (!t.completedDates.contains(_todayKey))
        t.completedDates.add(_todayKey);
    } else {
      t.completedDates.remove(_todayKey);
    }
    await t.save();
    _tasks = _box!.values.toList();
    notifyListeners();
  }

  Future<void> skipToday(String id) async {
    final t = _box!.get(id);
    if (t == null) return;
    if (!t.skippedDates.contains(_todayKey)) {
      t.skippedDates.add(_todayKey);
      await t.save();
    }
    _tasks = _box!.values.toList();
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    await _box!.delete(id);
    _tasks = _box!.values.toList();
    notifyListeners();
  }

  /// Reorder within a section, persists sortOrder to Hive.
  Future<void> reorderTasks(
      List<Task> section, int oldIndex, int newIndex) async {
    if (oldIndex == newIndex) return;
    if (newIndex > oldIndex) newIndex -= 1;

    // Reorder the section list
    final reordered = List<Task>.from(section);
    final moved     = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, moved);

    // Assign new sortOrders and persist
    for (int i = 0; i < reordered.length; i++) {
      reordered[i].sortOrder = i;
      await reordered[i].save();
    }

    _tasks = _box!.values.toList();
    notifyListeners();
  }
}