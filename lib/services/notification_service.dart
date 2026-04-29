import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService() {
    _init();
  }

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> _init() async {
    if (_initialized) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (_) {},
    );
    _initialized = true;
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime date,
  }) async {
    try {
      tz_data.initializeTimeZones();
      final local = tz.local;
      final scheduledDate = tz.TZDateTime.from(date, local);

      const android = AndroidNotificationDetails(
        'target_vault_reminder',
        'Target Vault Reminders',
        channelDescription: 'Reminders for savings and repayments',
      );
      const ios = DarwinNotificationDetails();

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        NotificationDetails(android: android, iOS: ios),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {}
  }

  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    try {
      tz_data.initializeTimeZones();
      final local = tz.local;
      final now = tz.TZDateTime.now(local);
      var scheduledDate = tz.TZDateTime(
        local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      if (scheduledDate.isBefore(tz.TZDateTime.now(local))) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const android = AndroidNotificationDetails(
        'target_vault_reminder',
        'Target Vault Reminders',
        channelDescription: 'Reminders for savings and repayments',
      );
      const ios = DarwinNotificationDetails();

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        NotificationDetails(android: android, iOS: ios),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {}
  }

  Future<void> scheduleWeekly({
    required int id,
    required String title,
    required String body,
    required int weekday,
    required int hour,
    required int minute,
  }) async {
    try {
      tz_data.initializeTimeZones();
      final local = tz.local;
      final now = tz.TZDateTime.now(local);
      var daysToAdd = weekday - now.weekday;
      if (daysToAdd < 0) daysToAdd += 7;
      var scheduledDate = tz.TZDateTime(
        local,
        now.year,
        now.month,
        now.day + daysToAdd,
        hour,
        minute,
      );
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 7));
      }

      const android = AndroidNotificationDetails(
        'target_vault_reminder',
        'Target Vault Reminders',
        channelDescription: 'Reminders for savings and repayments',
      );
      const ios = DarwinNotificationDetails();

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        NotificationDetails(android: android, iOS: ios),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    } catch (_) {}
  }
}
