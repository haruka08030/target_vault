import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// 通知のスケジュール結果。
///
/// 失敗を握り潰すと「設定しました」と表示されたまま通知が来ない状態になるため、
/// 呼び出し側が結果を見てユーザーに次の行動を示せるようにする。
enum NotificationResult {
  /// スケジュールできた。
  scheduled,

  /// OS に通知を拒否されている。設定アプリでの許可が必要。
  permissionDenied,

  /// その他の失敗。
  failed,

  /// この環境では通知を扱わない（Web）。
  unsupported,
}

class NotificationService {
  NotificationService() {
    _init();
  }

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _androidDetails = AndroidNotificationDetails(
    'target_vault_reminder',
    'Target Vault Reminders',
    channelDescription: 'Reminders to put money in your vaults',
  );
  static const _iosDetails = DarwinNotificationDetails();
  static const _details = NotificationDetails(
    android: _androidDetails,
    iOS: _iosDetails,
  );

  bool _initialized = false;
  bool _timezonesReady = false;

  Future<void> _init() async {
    if (kIsWeb) {
      _initialized = true;
      return;
    }
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

  /// タイムゾーンDBの初期化は1度だけでよい。
  void _ensureTimezones() {
    if (_timezonesReady) return;
    tz_data.initializeTimeZones();
    _timezonesReady = true;
  }

  Future<void> cancelAll() async {
    if (kIsWeb) return;
    await _plugin.cancelAll();
  }

  /// 通知の許可を要求し、許可されたかを返す。
  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;
    await _init();
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, badge: true) ?? false;
    }
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    return false;
  }

  /// 共通のスケジュール処理。失敗の理由を [NotificationResult] で返す。
  Future<NotificationResult> _schedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime when,
    DateTimeComponents? repeat,
  }) async {
    if (kIsWeb) return NotificationResult.unsupported;
    await _init();
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        when,
        _details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: repeat,
      );
      return NotificationResult.scheduled;
    } on PlatformException catch (e) {
      debugPrint('通知のスケジュールに失敗: ${e.code} ${e.message}');
      final code = e.code.toLowerCase();
      if (code.contains('permission') || code.contains('denied')) {
        return NotificationResult.permissionDenied;
      }
      return NotificationResult.failed;
    } catch (e) {
      debugPrint('通知のスケジュールに失敗: $e');
      return NotificationResult.failed;
    }
  }

  Future<NotificationResult> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime date,
  }) async {
    if (kIsWeb) return NotificationResult.unsupported;
    _ensureTimezones();
    return _schedule(
      id: id,
      title: title,
      body: body,
      when: tz.TZDateTime.from(date, tz.local),
    );
  }

  /// 毎日 [hour]:[minute] に通知する。
  Future<NotificationResult> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    if (kIsWeb) return NotificationResult.unsupported;
    _ensureTimezones();
    final local = tz.local;
    final now = tz.TZDateTime.now(local);
    var when = tz.TZDateTime(local, now.year, now.month, now.day, hour, minute);
    if (!when.isAfter(now)) {
      when = when.add(const Duration(days: 1));
    }
    return _schedule(
      id: id,
      title: title,
      body: body,
      when: when,
      repeat: DateTimeComponents.time,
    );
  }

  /// 毎週 [weekday]（1=月 … 7=日）の [hour]:[minute] に通知する。
  Future<NotificationResult> scheduleWeekly({
    required int id,
    required String title,
    required String body,
    required int weekday,
    required int hour,
    required int minute,
  }) async {
    if (kIsWeb) return NotificationResult.unsupported;
    _ensureTimezones();
    final local = tz.local;
    final now = tz.TZDateTime.now(local);
    var when = tz.TZDateTime(local, now.year, now.month, now.day, hour, minute);
    var daysToAdd = (weekday - now.weekday) % 7;
    if (daysToAdd < 0) daysToAdd += 7;
    when = when.add(Duration(days: daysToAdd));
    if (!when.isAfter(now)) {
      when = when.add(const Duration(days: 7));
    }
    return _schedule(
      id: id,
      title: title,
      body: body,
      when: when,
      repeat: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  /// 毎月 [day] 日の [hour]:[minute] に通知する。
  ///
  /// [DateTimeComponents.dayOfMonthAndTime] は日付が一致する月のみ発火するため、
  /// 31日など存在しない月がある指定では、その月はスキップされる。
  /// 毎月必ず届かせたい場合は [nextMonthlyOccurrence] が丸めた日付を使う。
  Future<NotificationResult> scheduleMonthly({
    required int id,
    required String title,
    required String body,
    required int day,
    required int hour,
    required int minute,
  }) async {
    if (kIsWeb) return NotificationResult.unsupported;
    _ensureTimezones();
    final when = nextMonthlyOccurrence(
      day: day,
      hour: hour,
      minute: minute,
      from: tz.TZDateTime.now(tz.local),
    );
    return _schedule(
      id: id,
      title: title,
      body: body,
      when: when,
      repeat: DateTimeComponents.dayOfMonthAndTime,
    );
  }

  /// 次に「毎月 [day] 日 [hour]:[minute]」が来る日時を返す。
  ///
  /// その月に [day] 日が存在しない場合（2月の31日など）は月末に丸める。
  @visibleForTesting
  static tz.TZDateTime nextMonthlyOccurrence({
    required int day,
    required int hour,
    required int minute,
    required tz.TZDateTime from,
  }) {
    tz.TZDateTime build(int year, int month) {
      final lastDay = DateTime(year, month + 1, 0).day;
      final d = day > lastDay ? lastDay : day;
      return tz.TZDateTime(from.location, year, month, d, hour, minute);
    }

    var when = build(from.year, from.month);
    if (!when.isAfter(from)) {
      final nextMonth = from.month == 12 ? 1 : from.month + 1;
      final nextYear = from.month == 12 ? from.year + 1 : from.year;
      when = build(nextYear, nextMonth);
    }
    return when;
  }
}
