/// 入金ペースから目標到達日を予測する。
///
/// 合計・純資産の集計は行わない（貯金箱ごとに見るアプリのため撤去済み）。
/// 通貨はアイテム単位で完結し、換算もしない。
abstract final class AggregationService {
  /// 直近の入金ペースから到達予定日を出す。
  ///
  /// 達成済み・入金実績が足りない場合は null。
  static DateTime? computePredictedDate({
    required double currentAmount,
    required double targetAmount,
    required List<({DateTime date, double amount})> deposits,
    required DateTime now,
  }) {
    if (currentAmount >= targetAmount) return null;
    final positiveDeposits = deposits.where((d) => d.amount > 0).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    if (positiveDeposits.isEmpty) return null;

    const maxRecent = 10;
    final recent = positiveDeposits.length > maxRecent
        ? positiveDeposits.sublist(positiveDeposits.length - maxRecent)
        : positiveDeposits;

    final totalAmount = recent.fold<double>(0, (s, d) => s + d.amount);
    final firstDate = recent.first.date;
    final lastDate = recent.last.date;
    final daysSpan = lastDate.difference(firstDate).inDays;
    if (daysSpan <= 0) return null;

    final dailyRate = totalAmount / daysSpan;
    if (dailyRate <= 0) return null;

    final remaining = targetAmount - currentAmount;
    final daysToGoal = (remaining / dailyRate).round();
    return now.add(Duration(days: daysToGoal));
  }
}
