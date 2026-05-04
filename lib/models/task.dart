import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
enum TaskPriority {
  @HiveField(0) high,
  @HiveField(1) medium,
  @HiveField(2) low,
}

@HiveType(typeId: 1)
enum TaskType {
  @HiveField(0) habit,
  @HiveField(1) oneTime,
}

@HiveType(typeId: 2)
class Task extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String title;
  @HiveField(2) TaskPriority priority;
  @HiveField(3) TaskType type;
  @HiveField(4) bool isCompleted;
  @HiveField(5) DateTime createdAt;
  @HiveField(6) String dateKey;
  @HiveField(7) List<String> skippedDates;
  @HiveField(8) List<String> completedDates;

  Task({
    required this.id,
    required this.title,
    required this.priority,
    required this.type,
    required this.dateKey,
    this.isCompleted = false,
    DateTime? createdAt,
    List<String>? skippedDates,
    List<String>? completedDates,
  })  : createdAt = createdAt ?? DateTime.now(),
        skippedDates = skippedDates ?? [],
        completedDates = completedDates ?? [];

  factory Task.create({
    required String title,
    required TaskPriority priority,
    required TaskType type,
    required String dateKey,
  }) =>
      Task(
        id: const Uuid().v4(),
        title: title,
        priority: priority,
        type: type,
        dateKey: dateKey,
      );

  int get points {
    switch (priority) {
      case TaskPriority.high:   return 3;
      case TaskPriority.medium: return 2;
      case TaskPriority.low:    return 1;
    }
  }

  bool isSkippedOn(String key)   => skippedDates.contains(key);
  bool isCompletedOn(String key) => completedDates.contains(key);
}