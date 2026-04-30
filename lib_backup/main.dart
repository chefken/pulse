import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/task_provider.dart';
import 'providers/score_provider.dart';
import 'providers/streak_provider.dart';
import 'providers/gym_provider.dart';
import 'providers/workout_provider.dart';
import 'providers/theme_provider.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  await Hive.initFlutter();

  final themeProvider   = ThemeProvider();
  final taskProvider    = TaskProvider();
  final scoreProvider   = ScoreProvider();
  final streakProvider  = StreakProvider();
  final gymProvider     = GymProvider();
  final workoutProvider = WorkoutProvider();

  await themeProvider.init();
  await taskProvider.init();
  await scoreProvider.init();
  await streakProvider.init();
  await gymProvider.init();
  await workoutProvider.init();

  // Init notifications (won't crash if permission denied)
  try {
    await NotificationService.instance.init();
  } catch (_) {}

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: taskProvider),
        ChangeNotifierProvider.value(value: scoreProvider),
        ChangeNotifierProvider.value(value: streakProvider),
        ChangeNotifierProvider.value(value: gymProvider),
        ChangeNotifierProvider.value(value: workoutProvider),
      ],
      child: const PulseApp(),
    ),
  );
}