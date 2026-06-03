import '../models/item_status.dart';
import '../models/vault_item.dart';
import '../repositories/transaction_repository.dart';
import 'exchange_rate_service.dart';

class AggregationResult {
  AggregationResult({
    required this.totalSavings,
    required this.totalDebt,
    required this.netWorth,
    required this.itemsWithAmounts,
  });

  final double totalSavings;
  final double totalDebt;
  final double netWorth;
  final Map<String, double> itemsWithAmounts;
}

class AggregationService {
  AggregationService(this._txRepo);

  final TransactionRepository _txRepo;

  Future<AggregationResult> computeWithBaseCurrency(
    List<VaultItem> items,
    String baseCurrency,
    ExchangeRateService exchange,
  ) async {
    double totalSavings = 0;
    double totalDebt = 0;
    final itemsWithAmounts = <String, double>{};

    for (final item in items) {
      final rawAmount = await _txRepo.getCurrentAmount(item.id);
      final amount = await exchange.toBaseCurrency(rawAmount, item.currency);
      itemsWithAmounts[item.id] = amount;

      switch (item.status) {
        case ItemStatus.saving:
          if (amount >= 0) {
            totalSavings += amount;
          } else {
            totalDebt += -amount;
          }
          break;
        case ItemStatus.repaying:
          if (amount < 0) {
            totalDebt += -amount;
          } else {
            totalSavings += amount;
          }
          break;
        case ItemStatus.completed:
          break;
      }
    }

    return AggregationResult(
      totalSavings: totalSavings,
      totalDebt: totalDebt,
      netWorth: totalSavings - totalDebt,
      itemsWithAmounts: itemsWithAmounts,
    );
  }

  Future<AggregationResult> compute(List<VaultItem> items) async {
    double totalSavings = 0;
    double totalDebt = 0;
    final itemsWithAmounts = <String, double>{};

    for (final item in items) {
      final amount = await _txRepo.getCurrentAmount(item.id);
      itemsWithAmounts[item.id] = amount;

      switch (item.status) {
        case ItemStatus.saving:
          if (amount >= 0) {
            totalSavings += amount;
          } else {
            totalDebt += -amount;
          }
          break;
        case ItemStatus.repaying:
          if (amount < 0) {
            totalDebt += -amount;
          } else {
            totalSavings += amount;
          }
          break;
        case ItemStatus.completed:
          break;
      }
    }

    return AggregationResult(
      totalSavings: totalSavings,
      totalDebt: totalDebt,
      netWorth: totalSavings - totalDebt,
      itemsWithAmounts: itemsWithAmounts,
    );
  }

  /// Predicted date from recent deposit pace (weighted average for accuracy)
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
