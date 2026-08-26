import 'package:flutter_test/flutter_test.dart';
import 'package:target_vault/models/item_status.dart';
import 'package:target_vault/models/vault_item.dart';
import 'package:target_vault/services/vault_selection.dart';

VaultItem _item({
  required String id,
  DateTime? targetDate,
  double target = 10000,
  bool isPinned = false,
  int sortOrder = 0,
  ItemStatus status = ItemStatus.saving,
}) {
  final now = DateTime(2026, 1, 1);
  return VaultItem(
    id: id,
    title: id,
    targetAmount: target,
    currency: 'JPY',
    targetDate: targetDate,
    status: status,
    sortOrder: sortOrder,
    isPinned: isPinned,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('VaultSnapshot', () {
    test('progress は 0〜1 に収まる', () {
      final s = VaultSnapshot(item: _item(id: 'a'), balance: 15000);
      expect(s.progress, 1.0);
      expect(VaultSnapshot(item: _item(id: 'a'), balance: -500).progress, 0.0);
    });

    test('目標額が0なら progress は0（0除算しない）', () {
      final s = VaultSnapshot(item: _item(id: 'a', target: 0), balance: 100);
      expect(s.progress, 0.0);
    });

    test('remaining は達成後に負にならない', () {
      expect(VaultSnapshot(item: _item(id: 'a'), balance: 12000).remaining, 0);
      expect(VaultSnapshot(item: _item(id: 'a'), balance: 4000).remaining, 6000);
    });

    test('残高がマイナスなら埋め戻し中とみなす', () {
      expect(
        VaultSnapshot(item: _item(id: 'a'), balance: -1).isRepaying,
        isTrue,
      );
      expect(
        VaultSnapshot(
          item: _item(id: 'a', status: ItemStatus.repaying),
          balance: 0,
        ).isRepaying,
        isTrue,
      );
    });

    test('daysUntilTarget は日付だけで比較する', () {
      final s = VaultSnapshot(
        item: _item(id: 'a', targetDate: DateTime(2026, 1, 10, 1)),
        balance: 0,
      );
      expect(s.daysUntilTarget(now: DateTime(2026, 1, 1, 23)), 9);
    });
  });

  group('selectHeroVault', () {
    test('候補が無ければ null', () {
      expect(selectHeroVault(const []), isNull);
    });

    test('完了したものは主役にしない', () {
      final s = [
        VaultSnapshot(
          item: _item(id: 'done', status: ItemStatus.completed),
          balance: 0,
        ),
      ];
      expect(selectHeroVault(s), isNull);
    });

    test('ピン留めが最優先', () {
      final s = [
        VaultSnapshot(
          item: _item(id: 'soon', targetDate: DateTime(2026, 2, 1)),
          balance: 0,
        ),
        VaultSnapshot(item: _item(id: 'pinned', isPinned: true), balance: 0),
      ];
      expect(selectHeroVault(s)!.item.id, 'pinned');
    });

    test('ピンが無ければ目標日が最も近いもの', () {
      final s = [
        VaultSnapshot(
          item: _item(id: 'later', targetDate: DateTime(2026, 6, 1)),
          balance: 0,
        ),
        VaultSnapshot(
          item: _item(id: 'sooner', targetDate: DateTime(2026, 2, 1)),
          balance: 0,
        ),
        VaultSnapshot(item: _item(id: 'nodate'), balance: 9000),
      ];
      expect(selectHeroVault(s)!.item.id, 'sooner');
    });

    test('目標日が無ければ達成率が最も高いもの', () {
      final s = [
        VaultSnapshot(item: _item(id: 'low'), balance: 1000),
        VaultSnapshot(item: _item(id: 'high'), balance: 8000),
      ];
      expect(selectHeroVault(s)!.item.id, 'high');
    });

    test('達成率が並ぶなら並び順で決める', () {
      final s = [
        VaultSnapshot(item: _item(id: 'second', sortOrder: 1), balance: 5000),
        VaultSnapshot(item: _item(id: 'first', sortOrder: 0), balance: 5000),
      ];
      expect(selectHeroVault(s)!.item.id, 'first');
    });
  });

  group('predictReachDate', () {
    test('実績が足りなければ予測しない', () {
      expect(
        predictReachDate(
          balance: 100,
          targetAmount: 1000,
          depositDates: [DateTime(2026, 1, 1)],
          depositedTotal: 100,
        ),
        isNull,
      );
    });

    test('達成済みなら予測しない', () {
      expect(
        predictReachDate(
          balance: 1000,
          targetAmount: 1000,
          depositDates: [DateTime(2026, 1, 1), DateTime(2026, 1, 10)],
          depositedTotal: 1000,
        ),
        isNull,
      );
    });

    test('平均ペースから到達日を出す', () {
      // 10日で 5,000 貯めた → 1日 500。残り 5,000 なら 10日後。
      final got = predictReachDate(
        balance: 5000,
        targetAmount: 10000,
        depositDates: [DateTime(2026, 1, 1), DateTime(2026, 1, 6)],
        depositedTotal: 5000,
        now: DateTime(2026, 1, 11),
      );
      expect(got, DateTime(2026, 1, 21));
    });

    test('遠すぎる予測は出さない', () {
      expect(
        predictReachDate(
          balance: 1,
          targetAmount: 100000000,
          depositDates: [DateTime(2026, 1, 1), DateTime(2026, 1, 2)],
          depositedTotal: 1,
          now: DateTime(2026, 1, 11),
        ),
        isNull,
      );
    });
  });
}
