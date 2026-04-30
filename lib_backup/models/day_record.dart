import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'day_record.g.dart';

@HiveType(typeId: 3)
class DayRecord extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String dateKey;           // 'yyyy-MM-dd'
  @HiveField(2) double disciplineScore;   // 0.0 – 1.0
  @HiveField(3) int userRating;           // 1–10 (0 = not rated yet)
  @HiveField(4) int totalTasks;
  @HiveField(5) int completedTasks;
  @HiveField(6) int earnedPoints;
  @HiveField(7) int totalPoints;
  @HiveField(8) String? wentWell;
  @HiveField(9) String? wentWrong;
  @HiveField(10) String? notes;
  @HiveField(11) bool isReviewed;

  DayRecord({
    required this.id,
    required this.dateKey,
    required this.disciplineScore,
    required this.totalTasks,
    required this.completedTasks,
    required this.earnedPoints,
    required this.totalPoints,
    this.userRating = 0,
    this.wentWell,
    this.wentWrong,
    this.notes,
    this.isReviewed = false,
  });

  factory DayRecord.create(String dateKey) => DayRecord(
    id: const Uuid().v4(),
    dateKey: dateKey,
    disciplineScore: 0,
    totalTasks: 0,
    completedTasks: 0,
    earnedPoints: 0,
    totalPoints: 0,
  );

  // Mismatch logic: difference between user perception and actual performance
  double get actualPerformance => totalTasks == 0 ? 0 : completedTasks / totalTasks;
  double get ratingNormalized  => userRating / 10.0;
  double get mismatch          => ratingNormalized - actualPerformance; // + = overrated, - = underrated

  bool get isGoodDay  => disciplineScore >= 0.7;
  bool get isMissedDay => disciplineScore < 0.4;
}