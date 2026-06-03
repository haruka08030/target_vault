import 'package:flutter_test/flutter_test.dart';
import 'package:target_vault/services/aggregation_service.dart';

void main() {
  group('AggregationService.computePredictedDate', () {
    test('returns null when currentAmount >= targetAmount', () {
      final now = DateTime(2025, 6, 15);
      expect(
        AggregationService.computePredictedDate(
          currentAmount: 100,
          targetAmount: 100,
          deposits: [(date: now, amount: 10.0)],
          now: now,
        ),
        isNull,
      );
      expect(
        AggregationService.computePredictedDate(
          currentAmount: 150,
          targetAmount: 100,
          deposits: [],
          now: now,
        ),
        isNull,
      );
    });

    test('returns null when no positive deposits', () {
      final now = DateTime(2025, 6, 15);
      expect(
        AggregationService.computePredictedDate(
          currentAmount: 50,
          targetAmount: 100,
          deposits: [(date: now, amount: 0.0), (date: now, amount: -10.0)],
          now: now,
        ),
        isNull,
      );
    });

    test('returns null when single deposit (daysSpan 0)', () {
      final now = DateTime(2025, 6, 15);
      expect(
        AggregationService.computePredictedDate(
          currentAmount: 50,
          targetAmount: 100,
          deposits: [(date: now, amount: 10.0)],
          now: now,
        ),
        isNull,
      );
    });

    test('computes predicted date from deposit pace', () {
      final d1 = DateTime(2025, 6, 1);
      final d2 = DateTime(2025, 6, 11); // 10 days
      final now = DateTime(2025, 6, 15);
      // 10 days, 100 total -> 10/day. Need 50 more -> 5 days from now
      final result = AggregationService.computePredictedDate(
        currentAmount: 50,
        targetAmount: 100,
        deposits: [(date: d1, amount: 50.0), (date: d2, amount: 50.0)],
        now: now,
      );
      expect(result, isNotNull);
      expect(result!.difference(now).inDays, 5);
    });

    test('uses only last 10 deposits for pace', () {
      final base = DateTime(2025, 1, 1);
      final deposits = List.generate(
        15,
        (i) => (date: base.add(Duration(days: i)), amount: 10.0),
      );
      final now = DateTime(2025, 1, 20);
      final result = AggregationService.computePredictedDate(
        currentAmount: 0,
        targetAmount: 100,
        deposits: deposits,
        now: now,
      );
      expect(result, isNotNull);
      // Should be based on last 10 deposits (100 total over 9 days) -> ~11.1/day, 100 needed -> ~9 days
      expect(result!.isAfter(now), true);
    });
  });
}
