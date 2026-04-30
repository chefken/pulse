import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'app.dart';
import 'providers/theme_provider.dart';
import 'providers/task_provider.dart';
import 'providers/score_provider.dart';
import 'providers/streak_provider.dart';
import 'providers/gym_provider.dart';
import 'providers/workout_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));

  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await Hive.initFlutter();
  tz.initializeTimeZones();

  final theme   = ThemeProvider();
  final tasks   = TaskProvider();
  final score   = ScoreProvider();
  final streak  = StreakProvider();
  final gym     = GymProvider();
  final workout = WorkoutProvider();

  await theme.init();
  await tasks.init();
  await score.init();
  await streak.init();
  await gym.init();
  await workout.init();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: theme),
      ChangeNotifierProvider.value(value: tasks),
      ChangeNotifierProvider.value(value: score),
      ChangeNotifierProvider.value(value: streak),
      ChangeNotifierProvider.value(value: gym),
      ChangeNotifierProvider.value(value: workout),
    ],
    child: const PulseApp(),
  ));
}