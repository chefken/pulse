import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'day_record.g.dart';

@HiveType(typeId: 3)
class DayRecord extends HiveObject {
  @HiveField(0)  String id;
  @HiveField(1)  String dateKey;
  @HiveField(2)  double disciplineScore;
  @HiveField(3)  int    userRating;
  @HiveField(4)  int    totalTasks;
  @HiveField(5)  int    completedTasks;
  @HiveField(6)  int    earnedPoints;
  @HiveField(7)  int    totalPoints;
  @HiveField(8)  bool   isReviewed;
  @HiveField(9)  List<String> completedHabitTitles;
  @HiveField(10) List<String> completedTaskTitles;

  DayRecord({
    required this.id,
    required this.dateKey,
    this.disciplineScore     = 0,
    this.userRating          = 0,
    this.totalTasks          = 0,
    this.completedTasks      = 0,
    this.earnedPoints        = 0,
    this.totalPoints         = 0,
    this.isReviewed          = false,
    List<String>? completedHabitTitles,
    List<String>? completedTaskTitles,
  })  : completedHabitTitles = completedHabitTitles ?? [],
        completedTaskTitles  = completedTaskTitles  ?? [];

  factory DayRecord.create(String dateKey) => DayRecord(
    id: const Uuid().v4(),
    dateKey: dateKey,
  );

  bool get isGoodDay => disciplineScore >= 0.5;
}