// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get goalsSectionTitle => 'Goals';

  @override
  String get totalSavings => '貯めたお金';

  @override
  String get totalDebt => '借りたお金';

  @override
  String get goalsViewActive => '進行中';

  @override
  String get goalsViewCompleted => '完了';

  @override
  String get categoryUnset => 'カテゴリなし';

  @override
  String get exchangeRateFetchFailed => '為替レートの取得に失敗しました';

  @override
  String get emptyGoalsPrompt => 'アイテムを追加して貯金を始めましょう';

  @override
  String get addItem => 'アイテムを追加';

  @override
  String get noCompletedGoalsYet => 'まだ完了したものはありません';

  @override
  String purchasedFor(String amount) {
    return '$amount で購入済み';
  }

  @override
  String get editItem => 'アイテムを編集';

  @override
  String get save => '保存';

  @override
  String get imageSaveFailed => '画像の保存に失敗しました';

  @override
  String get titleAndTargetRequired => 'タイトルと目標金額を入力してください';

  @override
  String get convertToRepayingFailed => '返済中への切り替えに失敗しました（貯金中のみ可能です）';

  @override
  String get deleteItemTitle => 'アイテムを削除';

  @override
  String deleteItemConfirm(String title) {
    return '「$title」を削除しますか？ 入出金履歴も一緒に削除されます。';
  }

  @override
  String get delete => '削除';

  @override
  String get itemDeleted => 'アイテムを削除しました';

  @override
  String get removePhoto => '写真を削除';

  @override
  String get addPhotoOptional => '写真を追加（任意）';

  @override
  String get fieldTitle => 'タイトル';

  @override
  String get fieldTargetAmount => '目標金額';

  @override
  String get purchasedOnCreditTitle => 'すでに購入済み（返済として登録）';

  @override
  String get purchasedOnCreditSubtitleNew => '目標金額ぶんの前借りとして記録します';

  @override
  String get purchasedOnCreditSubtitleEdit => '保存時に、入力した目標金額ぶんの前借りとして記録します';

  @override
  String get fieldCurrency => '通貨';

  @override
  String get fieldCategoryOptional => 'カテゴリ（任意）';

  @override
  String get fieldTargetDateOptional => '目標日（任意）';

  @override
  String get targetDateUnset => '未設定';

  @override
  String get clear => 'クリア';

  @override
  String get deleteThisItem => 'このアイテムを削除';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsLanguage => '言語';

  @override
  String get languageSystem => '端末の設定に合わせる';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageEnglish => 'English';

  @override
  String get settingsBaseCurrency => 'ベース通貨';

  @override
  String get settingsNotifications => '通知';

  @override
  String get settingsNotificationsWebUnavailable => 'Web版ではローカル通知は利用できません。';

  @override
  String get settingsNotifTiming => '通知のタイミング';

  @override
  String get settingsNotifMonthly => '毎月';

  @override
  String get settingsNotifWeekly => '毎週';

  @override
  String get settingsNotifOff => 'オフ';

  @override
  String get settingsNotifWhichDay => '毎月の何日？';

  @override
  String settingsNotifMonthlyDay(int day) {
    return '毎月$day日';
  }

  @override
  String get settingsNotifWhichWeekday => '毎週の何曜日？';

  @override
  String get settingsNotifTime => '通知時刻';

  @override
  String get settingsNotifApply => '通知を設定';

  @override
  String get settingsNotifDisabledSnack => '通知をオフにしました';

  @override
  String get settingsNotifEnabledSnack => '通知を設定しました';

  @override
  String get notifBodyDaily => '今日の入金を記録しましょう';

  @override
  String get notifBodyWeekly => '今週の入金を記録しましょう';
}
