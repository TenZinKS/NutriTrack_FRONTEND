import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../features/dashboard/domain/entities/reminder.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(settings);
    await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  Future<void> syncReminders(List<Reminder> reminders) async {
    if (!_initialized) return;
    await _plugin.cancelAll();
    final now = tz.TZDateTime.now(tz.local);
    var notificationId = 1;
    for (final reminder in reminders) {
      final scheduled = tz.TZDateTime.from(reminder.scheduledAt, tz.local);
      if (scheduled.isAfter(now.add(const Duration(minutes: 1)))) {
        await _plugin.zonedSchedule(
          notificationId++,
          reminder.title,
          reminder.message,
          scheduled,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'reminders_channel',
              'Reminders',
              channelDescription: 'Personalized nutrition reminders',
              importance: Importance.max,
              priority: Priority.high,
              color: reminder.isCritical ? const Color(0xFFFF6C2F) : null,
            ),
            iOS: const DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }
}
