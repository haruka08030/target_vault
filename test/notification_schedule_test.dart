import 'package:flutter_test/flutter_test.dart';
import 'package:target_vault/services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  // group の宣言時に getLocation を呼ぶため、setUpAll ではなくここで初期化する。
  tz_data.initializeTimeZones();

  group('nextMonthlyOccurrence', () {
    final tokyo = tz.getLocation('Asia/Tokyo');

    tz.TZDateTime at(int y, int m, int d, [int h = 0, int min = 0]) =>
        tz.TZDateTime(tokyo, y, m, d, h, min);

    test('同じ月のまだ来ていない日を返す', () {
      final got = NotificationService.nextMonthlyOccurrence(
        day: 25,
        hour: 20,
        minute: 0,
        from: at(2026, 3, 10, 9),
      );
      expect(got, at(2026, 3, 25, 20));
    });

    test('その日を過ぎていれば翌月にずらす', () {
      final got = NotificationService.nextMonthlyOccurrence(
        day: 5,
        hour: 20,
        minute: 0,
        from: at(2026, 3, 10, 9),
      );
      expect(got, at(2026, 4, 5, 20));
    });

    test('同日でも時刻を過ぎていれば翌月', () {
      final got = NotificationService.nextMonthlyOccurrence(
        day: 10,
        hour: 8,
        minute: 0,
        from: at(2026, 3, 10, 9),
      );
      expect(got, at(2026, 4, 10, 8));
    });

    test('存在しない日は月末に丸める（2月の31日）', () {
      final got = NotificationService.nextMonthlyOccurrence(
        day: 31,
        hour: 20,
        minute: 0,
        from: at(2026, 2, 1, 9),
      );
      expect(got, at(2026, 2, 28, 20));
    });

    test('うるう年の2月29日も扱える', () {
      final got = NotificationService.nextMonthlyOccurrence(
        day: 31,
        hour: 20,
        minute: 0,
        from: at(2028, 2, 1, 9),
      );
      expect(got, at(2028, 2, 29, 20));
    });

    test('12月から翌年1月へ繰り越す', () {
      final got = NotificationService.nextMonthlyOccurrence(
        day: 1,
        hour: 20,
        minute: 0,
        from: at(2026, 12, 15, 9),
      );
      expect(got, at(2027, 1, 1, 20));
    });
  });
}
