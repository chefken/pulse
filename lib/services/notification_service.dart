import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    _initialized = true;
    await _scheduleAll();
  }

  Future<void> _scheduleAll() async {
    await _plugin.cancelAll();
    await _scheduleCallHome();
    await _scheduleMorning();
    await _scheduleWorkout();
    await _scheduleNight();
  }

  Future<void> _scheduleCallHome() async {
    await _plugin.zonedSchedule(
      1,
      'Call Home 📞',
      "It's 6 PM. Check in with home.",
      _next(18, 0),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'call_home', 'Call Home',
          channelDescription: 'Daily 6 PM reminder',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _scheduleMorning() async {
    await _plugin.zonedSchedule(
      2,
      'Good morning 🌅',
      'Discipline beats motivation. Start strong.',
      _next(7, 0),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'morning', 'Morning Motivation',
          channelDescription: 'Daily morning motivation',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _scheduleWorkout() async {
    await _plugin.zonedSchedule(
      3,
      'Gym time 🏋️',
      "Your workout is waiting. Don't skip.",
      _next(8, 0),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'workout', 'Workout Reminder',
          channelDescription: 'Daily workout reminder',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _scheduleNight() async {
    await _plugin.zonedSchedule(
      4,
      'End of day 🌙',
      'Log your reflection before you sleep.',
      _next(21, 30),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'night', 'Night Reflection',
          channelDescription: 'Daily night reflection reminder',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _next(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var t = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (t.isBefore(now)) t = t.add(const Duration(days: 1));
    return t;
  }
}