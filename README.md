# Target Vault

欲しいものごとに「貯金箱」をつくって貯めるアプリ。
開いたときに見えるのは資産の合計ではなく、
**いま一番近い貯金箱に、あといくらで届くか**。

## 技術スタック

- **フレームワーク**: Flutter（iOS / Android）
- **永続化**: Drift + SQLite（端末ローカル）
- **状態管理**: Provider
- **外部通信**: なし（完全オフライン）

Web ビルドは非対応です。

## セットアップ

```bash
flutter pub get
dart run build_runner build   # 初回、または lib/database/app_database.dart 変更時
flutter run
```

`lib/l10n/*.arb` を変更したら `flutter gen-l10n` を実行してください。

## 主な機能

- **ホーム**: 主役カード（いま一番近い貯金箱／あと◯◯円／「貯金する」）＋
  すべての貯金箱のタイル。左右スワイプで主役を切り替え。
  主役はピックアップとして上に出るだけで、棚の並びは変わらない
- **ピン留め**: 詳細画面から、ホームの主役に固定（最大1件）
- **貯金箱の管理**: 追加・編集、写真、目標日、カテゴリ。画像は端末内に保存
- **購入**: 目標額に達していれば完了、未達なら前借りとして埋め戻しに移行
- **入出金**: 金額のみで登録（日付は自動）。履歴の修正・削除も可能
- **予測日**: 直近の入金ペースから算出し、目標日とのギャップを表示
- **通貨**: 貯金箱ごとに指定。換算・合算はしない
- **通知**: 毎月○日 / 毎週○曜日 / オフ

## プロジェクト構成

```
lib/
├── database/     # AppDatabase, SettingsStore（Drift）
├── models/       # VaultItem, VaultTransaction, ItemStatus
├── repositories/ # Item / Transaction
├── services/     # VaultSelection（主役の選定）, Notification, Aggregation（予測）
├── screens/      # Home, ItemDetail, AddItem, Settings, QuickAdd, Onboarding
├── widgets/      # VaultHeroCard, VaultTile, VaultIllustration
├── theme/        # AppColors（色トークン）, AppTheme
└── l10n/         # 日本語 / 英語
```

## テスト

```bash
flutter test
```

`test/layout_resilience_test.dart` は、文字サイズ2.0倍・320pt幅で
レイアウトが溢れないことを検証します。UI を変更したら必ず通してください。
