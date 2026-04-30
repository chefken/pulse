import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'workout_log.g.dart';

@HiveType(typeId: 7)
class ExerciseSet extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) double weight; // kg
  @HiveField(2) int reps;

  ExerciseSet({
    required this.id,
    required this.weight,
    required this.reps,
  });

  factory ExerciseSet.create({double weight = 0, int reps = 0}) =>
      ExerciseSet(id: const Uuid().v4(), weight: weight, reps: reps);

  String get display =>
      '${weight % 1 == 0 ? weight.toInt() : weight}kg × $reps';
}

@HiveType(typeId: 8)
class WorkoutExercise extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String name;
  @HiveField(2) List<ExerciseSet> sets;

  WorkoutExercise({
    required this.id,
    required this.name,
    required this.sets,
  });

  factory WorkoutExercise.create(String name) => WorkoutExercise(
      id: const Uuid().v4(), name: name, sets: []);

  double get maxWeight =>
      sets.isEmpty ? 0 : sets.map((s) => s.weight).reduce((a, b) => a > b ? a : b);

  int get totalVolume =>
      sets.fold(0, (sum, s) => sum + (s.weight * s.reps).toInt());
}

@HiveType(typeId: 9)
class WorkoutLog extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String dateKey;
  @HiveField(2) String muscleGroup;
  @HiveField(3) List<WorkoutExercise> exercises;
  @HiveField(4) bool completed;
  @HiveField(5) DateTime createdAt;

  WorkoutLog({
    required this.id,
    required this.dateKey,
    required this.muscleGroup,
    required this.exercises,
    this.completed = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory WorkoutLog.create(
          {required String dateKey, required String muscleGroup}) =>
      WorkoutLog(
        id: const Uuid().v4(),
        dateKey: dateKey,
        muscleGroup: muscleGroup,
        exercises: [],
      );
}