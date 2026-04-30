import 'package:hive/hive.dart';

part 'gym_routine.g.dart';

const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

@HiveType(typeId: 5)
class GymDay extends HiveObject {
  @HiveField(0) String weekday;      // 'Mon' … 'Sun'
  @HiveField(1) String muscleGroup;  // e.g. 'Chest & Triceps'
  @HiveField(2) bool isRest;

  GymDay({
    required this.weekday,
    this.muscleGroup = '',
    this.isRest = false,
  });
}

@HiveType(typeId: 6)
class GymSession extends HiveObject {
  @HiveField(0) String dateKey;      // 'yyyy-MM-dd'
  @HiveField(1) bool completed;
  @HiveField(2) String? notes;

  GymSession({
    required this.dateKey,
    this.completed = false,
    this.notes,
  });
}