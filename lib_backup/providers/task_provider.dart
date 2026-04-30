import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import '../core/utils/date_utils.dart';

class TaskProvider extends ChangeNotifier {
  static const _boxName = 'tasks';
  Box<Task>? _box;
  List<Task> _tasks = [];

  String get _todayKey => PulseDateUtils.formatDateKey(PulseDateUtils.today);

  // All habits not skipped today + today's one-time tasks
  List<Task> get todayTasks {
    final habits = _tasks
        .where((t) =>
            t.type == TaskType.habit && !t.isSkippedOn(_todayKey))
        .toList();
    final oneTime = _tasks
        .where((t) => t.type == TaskType.oneTime && t.dateKey == _todayKey)
        .toList();
    return [...habits, ...oneTime];
  }

  List<Task> get habits =>
      _tasks.where((t) => t.type == TaskType.habit).toList();

  List<Task> get completedToday =>
      todayTasks.where((t) => t.isCompleted).toList();

  List<Task> get pendingToday =>
      todayTasks.where((t) => !t.isCompleted).toList();

  int get earnedPoints =>
      completedToday.fold(0, (s, t) => s + t.points);

  int get totalPoints =>
      todayTasks.fold(0, (s, t) => s + t.points);

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(0))
      Hive.registerAdapter(TaskPriorityAdapter());
    if (!Hive.isAdapterRegistered(1))
      Hive.registerAdapter(TaskTypeAdapter());
    if (!Hive.isAdapterRegistered(2))
      Hive.registerAdapter(TaskAdapter());

    _box = await Hive.openBox<Task>(_boxName);
    _tasks = _box!.values.toList();
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await _box!.put(task.id, task);
    _tasks = _box!.values.toList();
    notifyListeners();
  }

  Future<void> toggleTask(String id) async {
    final task = _box!.get(id);
    if (task == null) return;
    task.isCompleted = !task.isCompleted;
    await task.save();
    _tasks = _box!.values.toList();
    notifyListeners();
  }

  Future<void> skipToday(String id) async {
    final task = _box!.get(id);
    if (task == null) return;
    if (!task.skippedDates.contains(_todayKey)) {
      task.skippedDates.add(_todayKey);
      await task.save();
      _tasks = _box!.values.toList();
      notifyListeners();
    }
  }

  Future<void> unskipToday(String id) async {
    final task = _box!.get(id);
    if (task == null) return;
    task.skippedDates.remove(_todayKey);
    await task.save();
    _tasks = _box!.values.toList();
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    await _box!.delete(id);
    _tasks = _box!.values.toList();
    notifyListeners();
  }

  Future<void> updateTask(Task updated) async {
    await _box!.put(updated.id, updated);
    _tasks = _box!.values.toList();
    notifyListeners();
  }
}