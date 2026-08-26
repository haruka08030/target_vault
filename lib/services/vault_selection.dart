import '../models/item_status.dart';
import '../models/vault_item.dart';

/// 貯金箱1件と、その残高・進捗をまとめたもの。
///
/// ホームは残高を1度のクエリでまとめて取得し、この形にして各カードへ配る。
class VaultSnapshot {
  const VaultSnapshot({required this.item, required this.balance});

  final VaultItem item;

  /// 入出金の合計。前借り中はマイナスになりうる。
  final double balance;

  /// 目標に対する進捗（0.0〜1.0）。目標額が0以下なら0。
  double get progress {
    if (item.targetAmount <= 0) return 0;
    final p = balance / item.targetAmount;
    return p.clamp(0.0, 1.0);
  }

  /// 目標達成まであといくらか。達成済み・超過なら0。
  double get remaining {
    final r = item.targetAmount - balance;
    return r <= 0 ? 0 : r;
  }

  /// 埋め戻し中（前借りで購入済み）か。
  bool get isRepaying =>
      item.status == ItemStatus.repaying || balance < 0;

  /// 目標額に到達しているか。
  bool get isReached =>
      item.targetAmount > 0 && balance >= item.targetAmount;

  /// 目標日まであと何日か。目標日が無ければ null。過去なら負の値。
  int? daysUntilTarget({DateTime? now}) {
    final target = item.targetDate;
    if (target == null) return null;
    final today = _dateOnly(now ?? DateTime.now());
    return _dateOnly(target).difference(today).inDays;
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}

/// ホームの主役カードに出す貯金箱を選ぶ。
///
/// 優先順位:
/// 1. ピン留めされたもの（ユーザーの明示的な意思）
/// 2. 目標日が最も近いもの（締切があるものは待ってくれない）
/// 3. 目標日が無ければ、達成率が最も高いもの（達成の快感が最短で来る）
/// 4. それも並ぶなら、並び順（sortOrder）
///
/// 完了したものは対象外。該当が無ければ null。
VaultSnapshot? selectHeroVault(
  List<VaultSnapshot> snapshots, {
  DateTime? now,
}) {
  final candidates = snapshots
      .where((s) => s.item.status != ItemStatus.completed)
      .toList();
  if (candidates.isEmpty) return null;

  final pinned = candidates.where((s) => s.item.isPinned);
  if (pinned.isNotEmpty) return pinned.first;

  final withDate = candidates
      .where((s) => s.item.targetDate != null)
      .toList();

  if (withDate.isNotEmpty) {
    withDate.sort((a, b) {
      final c = a.item.targetDate!.compareTo(b.item.targetDate!);
      if (c != 0) return c;
      return a.item.sortOrder.compareTo(b.item.sortOrder);
    });
    return withDate.first;
  }

  final byProgress = List<VaultSnapshot>.from(candidates);
  byProgress.sort((a, b) {
    final c = b.progress.compareTo(a.progress);
    if (c != 0) return c;
    return a.item.sortOrder.compareTo(b.item.sortOrder);
  });
  return byProgress.first;
}

/// 直近の入金ペースから、目標到達日を予測する。
///
/// [balance] が目標に達している、または入金の実績が足りない場合は null。
/// 予測は「最初の入金から今日までの日数」あたりの平均増加額で線形に外挿する。
DateTime? predictReachDate({
  required double balance,
  required double targetAmount,
  required List<DateTime> depositDates,
  required double depositedTotal,
  DateTime? now,
}) {
  if (targetAmount <= 0) return null;
  if (balance >= targetAmount) return null;
  if (depositDates.length < 2 || depositedTotal <= 0) return null;

  final today = now ?? DateTime.now();
  final sorted = List<DateTime>.from(depositDates)..sort();
  final spanDays = today.difference(sorted.first).inDays;
  if (spanDays <= 0) return null;

  final perDay = depositedTotal / spanDays;
  if (perDay <= 0) return null;

  final remaining = targetAmount - balance;
  final daysNeeded = (remaining / perDay).ceil();
  // 極端に遠い予測は現実味が無いので出さない（10年）。
  if (daysNeeded > 3650) return null;
  return today.add(Duration(days: daysNeeded));
}
