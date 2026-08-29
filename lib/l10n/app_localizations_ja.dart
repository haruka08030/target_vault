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

  @override
  String get onboardingTagline => '欲しいものへ、こつこつ貯金';

  @override
  String get onboardingBody => '欲しいものごとに貯金箱をつくって、貯まっていくのを眺めましょう。';

  @override
  String get onboardingStart => 'はじめる';

  @override
  String homeHeroRemaining(String amount) {
    return 'あと $amount';
  }

  @override
  String get homeHeroReached => '買えます';

  @override
  String homeHeroRepaying(String amount) {
    return '残り $amount を埋め戻し';
  }

  @override
  String homeHeroOf(String current, String target) {
    return '$target のうち $current';
  }

  @override
  String homeHeroDueInDays(int days) {
    return 'あと $days 日';
  }

  @override
  String get homeHeroDueToday => '今日まで';

  @override
  String homeHeroOverdue(int days) {
    return '$days 日すぎています';
  }

  @override
  String get homeHeroNoDate => '目標日なし';

  @override
  String homeHeroPredicted(String date) {
    return 'このペースで $date ごろ';
  }

  @override
  String homeHeroPredictedLate(int days) {
    return '目標日より $days 日おそい見込み';
  }

  @override
  String get homeAddMoney => '貯金する';

  @override
  String get homeOtherVaults => 'ほかの貯金箱';

  @override
  String get homeAllVaults => '貯金箱';

  @override
  String get homeViewCompleted => '完了した貯金箱';

  @override
  String get homeSwipeHint => 'スワイプでほかの貯金箱へ';

  @override
  String get pinToHome => 'ホームに固定';

  @override
  String get pinnedToHome => 'ホームに固定しました';

  @override
  String get unpinnedFromHome => '固定を解除しました';

  @override
  String get emptyVaultsTitle => 'まだ貯金箱がありません';

  @override
  String get notifPermissionDenied => '通知がオフになっています。設定アプリで許可してください。';

  @override
  String get notifScheduleFailed => '通知を設定できませんでした。もう一度お試しください。';

  @override
  String get openSettings => '設定を開く';

  @override
  String get settingsDefaultCurrency => 'デフォルトの通貨';

  @override
  String get settingsDefaultCurrencyHint => '新しい貯金箱をつくるときの初期値です';

  @override
  String get notifBodyMonthly => '貯金箱にお金を入れましょう';

  @override
  String get retry => 'もう一度';

  @override
  String get detailPurchaseTitle => '購入完了';

  @override
  String get detailPurchaseConfirm => 'このアイテムを購入完了としてマークしますか？';

  @override
  String get detailPurchaseDone => '完了';

  @override
  String get detailBuyOnCreditTitle => '前借りで購入';

  @override
  String detailBuyOnCreditConfirm(String amount) {
    return '目標額に達していません。前借りで購入し、残り $amount を埋め戻しとして記録しますか？';
  }

  @override
  String get detailBuyOnCreditConfirmLabel => '購入する';

  @override
  String get detailPurchasedSnack => '購入完了！';

  @override
  String detailOnCreditSnack(String amount) {
    return '前借りで購入しました（残り $amount を埋め戻し）';
  }

  @override
  String get detailBuyAction => '購入する';

  @override
  String get detailRepayingHint => '埋め戻し中：入金を記録してください';

  @override
  String get detailHistoryTitle => '入出金履歴';

  @override
  String get detailRecord => '記録';

  @override
  String get detailTargetDate => '目標日';

  @override
  String get detailPredictedDate => '予測日';

  @override
  String detailDaysLate(int days) {
    return '$days日おそい見込み';
  }

  @override
  String get detailNoTransactions => 'まだ入出金がありません';

  @override
  String get invalidAmount => '正しい金額を入力してください';

  @override
  String get deleteTransactionConfirm => 'この入出金を削除しますか？';

  @override
  String get archiveItem => 'アーカイブ';

  @override
  String get archiveItemTitle => 'この貯金箱をアーカイブ';

  @override
  String archiveItemConfirm(String title) {
    return '「$title」を棚から下ろします。履歴は残り、いつでも戻せます。';
  }

  @override
  String get archivedSnack => 'アーカイブしました';

  @override
  String get unarchiveItem => '棚に戻す';

  @override
  String get unarchivedSnack => '棚に戻しました';

  @override
  String get shelfTitle => '棚から下ろした箱';

  @override
  String get sectionCompleted => '完了';

  @override
  String get sectionArchived => 'アーカイブ';

  @override
  String get emptyOffShelf => 'まだ何もありません';

  @override
  String get emptyOffShelfBody => '買い終えた箱や、やめた箱がここに入ります。';

  @override
  String get moreActions => 'その他';
}
