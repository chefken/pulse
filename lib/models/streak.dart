import 'package:hive/hive.dart';

part 'streak.g.dart';

@HiveType(typeId: 4)
class StreakData extends HiveObject {
  @HiveField(0) int currentStreak;
  @HiveField(1) int longestStreak;
  @HiveField(2) int totalActiveDays;
  @HiveField(3) int totalDays;

  StreakData({
    this.currentStreak   = 0,
    this.longestStreak   = 0,
    this.totalActiveDays = 0,
    this.totalDays       = 0,
  });

  double get consistencyPercent =>
      totalDays == 0 ? 0 : (totalActiveDays / totalDays) * 100;
}