import 'package:hive/hive.dart';

part 'gym_routine.g.dart';

@HiveType(typeId: 5)
class GymDay extends HiveObject {
  @HiveField(0) String weekday;
  @HiveField(1) String muscleGroup;
  @HiveField(2) bool   isRest;

  GymDay({
    required this.weekday,
    this.muscleGroup = '',
    this.isRest      = false,
  });
}

@HiveType(typeId: 6)
class GymSession extends HiveObject {
  @HiveField(0) String dateKey;
  @HiveField(1) bool   completed;

  GymSession({required this.dateKey, this.completed = false});
}