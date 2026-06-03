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
}
