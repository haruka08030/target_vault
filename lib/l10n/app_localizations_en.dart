// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get goalsSectionTitle => 'Goals';

  @override
  String get totalSavings => 'Saved';

  @override
  String get totalDebt => 'Owed';

  @override
  String get goalsViewActive => 'Active';

  @override
  String get goalsViewCompleted => 'Completed';

  @override
  String get categoryUnset => 'Uncategorized';

  @override
  String get exchangeRateFetchFailed => 'Failed to fetch exchange rates';

  @override
  String get emptyGoalsPrompt => 'Add an item to start saving';

  @override
  String get addItem => 'Add item';

  @override
  String get noCompletedGoalsYet => 'No completed goals yet';

  @override
  String purchasedFor(String amount) {
    return 'Purchased for $amount';
  }

  @override
  String get editItem => 'Edit item';

  @override
  String get save => 'Save';

  @override
  String get imageSaveFailed => 'Failed to save image';

  @override
  String get titleAndTargetRequired => 'Please enter a title and target amount';

  @override
  String get convertToRepayingFailed =>
      'Could not switch to repaying (only available while saving)';

  @override
  String get deleteItemTitle => 'Delete item';

  @override
  String deleteItemConfirm(String title) {
    return 'Delete \"$title\"? Transaction history will also be deleted.';
  }

  @override
  String get delete => 'Delete';

  @override
  String get itemDeleted => 'Item deleted';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get addPhotoOptional => 'Add photo (optional)';

  @override
  String get fieldTitle => 'Title';

  @override
  String get fieldTargetAmount => 'Target amount';

  @override
  String get purchasedOnCreditTitle => 'Already purchased (record as debt)';

  @override
  String get purchasedOnCreditSubtitleNew =>
      'Record as an advance for the full target amount';

  @override
  String get purchasedOnCreditSubtitleEdit =>
      'On save, record as an advance for the target amount you enter';

  @override
  String get fieldCurrency => 'Currency';

  @override
  String get fieldCategoryOptional => 'Category (optional)';

  @override
  String get fieldTargetDateOptional => 'Target date (optional)';

  @override
  String get targetDateUnset => 'Not set';

  @override
  String get clear => 'Clear';

  @override
  String get deleteThisItem => 'Delete this item';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageJapanese => 'Japanese';

  @override
  String get languageEnglish => 'English';

  @override
  String get settingsBaseCurrency => 'Base currency';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsWebUnavailable =>
      'Local notifications are not available on the web version.';

  @override
  String get settingsNotifTiming => 'Notification timing';

  @override
  String get settingsNotifMonthly => 'Monthly';

  @override
  String get settingsNotifWeekly => 'Weekly';

  @override
  String get settingsNotifOff => 'Off';

  @override
  String get settingsNotifWhichDay => 'Which day of the month?';

  @override
  String settingsNotifMonthlyDay(int day) {
    return 'Day $day of each month';
  }

  @override
  String get settingsNotifWhichWeekday => 'Which day of the week?';

  @override
  String get settingsNotifTime => 'Notification time';

  @override
  String get settingsNotifApply => 'Save notifications';

  @override
  String get settingsNotifDisabledSnack => 'Notifications turned off';

  @override
  String get settingsNotifEnabledSnack => 'Notifications saved';

  @override
  String get notifBodyDaily => 'Log today\'s deposit';

  @override
  String get notifBodyWeekly => 'Log this week\'s deposit';

  @override
  String get onboardingTagline => 'Save up for what you want';

  @override
  String get onboardingBody =>
      'Make a jar for each thing you want, and watch it fill up.';

  @override
  String get onboardingStart => 'Let\'s start';

  @override
  String homeHeroRemaining(String amount) {
    return '$amount to go';
  }

  @override
  String get homeHeroReached => 'Ready to buy';

  @override
  String homeHeroRepaying(String amount) {
    return '$amount left to pay back';
  }

  @override
  String homeHeroOf(String current, String target) {
    return '$current of $target';
  }

  @override
  String homeHeroDueInDays(int days) {
    return '$days days left';
  }

  @override
  String get homeHeroDueToday => 'Due today';

  @override
  String homeHeroOverdue(int days) {
    return '$days days past';
  }

  @override
  String get homeHeroNoDate => 'No target date';

  @override
  String homeHeroPredicted(String date) {
    return 'On track for $date';
  }

  @override
  String homeHeroPredictedLate(int days) {
    return '$days days behind';
  }

  @override
  String get homeAddMoney => 'Add money';

  @override
  String get homeOtherVaults => 'Your other jars';

  @override
  String get homeAllVaults => 'Your jars';

  @override
  String get homeViewCompleted => 'Completed jars';

  @override
  String get homeSwipeHint => 'Swipe to see other jars';

  @override
  String get pinToHome => 'Pin to home';

  @override
  String get pinnedToHome => 'Pinned to home';

  @override
  String get unpinnedFromHome => 'Unpinned';

  @override
  String get emptyVaultsTitle => 'No jars yet';

  @override
  String get notifPermissionDenied =>
      'Notifications are turned off. Allow them in Settings to get reminders.';

  @override
  String get notifScheduleFailed =>
      'Could not set the reminder. Please try again.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get settingsDefaultCurrency => 'Default currency';

  @override
  String get settingsDefaultCurrencyHint => 'Used when you create a new jar';

  @override
  String get notifBodyMonthly => 'Time to add to your jars';

  @override
  String get retry => 'Retry';

  @override
  String get detailPurchaseTitle => 'Mark as bought';

  @override
  String get detailPurchaseConfirm => 'Mark this item as bought?';

  @override
  String get detailPurchaseDone => 'Done';

  @override
  String get detailBuyOnCreditTitle => 'Buy on credit';

  @override
  String detailBuyOnCreditConfirm(String amount) {
    return 'You have not reached the target yet. Buy it now and record the remaining $amount to pay back?';
  }

  @override
  String get detailBuyOnCreditConfirmLabel => 'Buy';

  @override
  String get detailPurchasedSnack => 'Bought!';

  @override
  String detailOnCreditSnack(String amount) {
    return 'Recorded as bought on credit ($amount to pay back)';
  }

  @override
  String get detailBuyAction => 'Buy';

  @override
  String get detailRepayingHint => 'Paying back: record your repayments here';

  @override
  String get detailHistoryTitle => 'History';

  @override
  String get detailRecord => 'Record';

  @override
  String get detailTargetDate => 'Target date';

  @override
  String get detailPredictedDate => 'Predicted';

  @override
  String detailDaysLate(int days) {
    return '$days days behind schedule';
  }

  @override
  String get detailNoTransactions => 'No money in or out yet';

  @override
  String get invalidAmount => 'Please enter a valid amount';

  @override
  String get deleteTransactionConfirm => 'Delete this record?';
}
