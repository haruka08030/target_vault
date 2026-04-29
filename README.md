# Target Vault

「欲しいものへの貯金」と「購入後の回収」を一元管理する資産形成アプリ。

## 技術スタック

- **フレームワーク**: Flutter
- **データベース**: Drift (SQLite)
- **為替API**: Frankfurter API
- **状態管理**: Provider

## セットアップ

```bash
cd target_vault
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## 主な機能

- **ホーム画面**:
  純資産・貯蓄・負債の一覧、アイテムカード（写真・進捗バー・残高）
- **アイテム管理**: 追加・編集、写真（フォトライブラリ、任意）、目標日・カテゴリ
- **購入ボタン**: 目標額達成時は完了、未達時は前借りとして Repaying に遷移
- **入出金**: 2タップで入金登録（金額のみ、日付は自動）
- **予測日**: 直近の入金ペースから算出、目標日とのギャップ表示
- **多通貨**: アイテム単位で通貨指定、ホームはベース通貨で換算表示
- **通知**: 設定画面で日付・曜日・時刻を指定

## プロジェクト構成

```
lib/
├── database/          # Drift DB、Settings
├── repositories/      # Item, Transaction
├── services/          # ExchangeRate, Notification, Aggregation
├── screens/           # Home, ItemDetail, AddItem, Settings, QuickAdd
├── providers/         # Provider 設定
└── utils/             # format など
```
