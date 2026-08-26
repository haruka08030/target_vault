import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
  ];

  /// No description provided for @goalsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goalsSectionTitle;

  /// No description provided for @totalSavings.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get totalSavings;

  /// No description provided for @totalDebt.
  ///
  /// In en, this message translates to:
  /// **'Owed'**
  String get totalDebt;

  /// No description provided for @goalsViewActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get goalsViewActive;

  /// No description provided for @goalsViewCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get goalsViewCompleted;

  /// No description provided for @categoryUnset.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get categoryUnset;

  /// No description provided for @exchangeRateFetchFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch exchange rates'**
  String get exchangeRateFetchFailed;

  /// No description provided for @emptyGoalsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Add an item to start saving'**
  String get emptyGoalsPrompt;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get addItem;

  /// No description provided for @noCompletedGoalsYet.
  ///
  /// In en, this message translates to:
  /// **'No completed goals yet'**
  String get noCompletedGoalsYet;

  /// No description provided for @purchasedFor.
  ///
  /// In en, this message translates to:
  /// **'Purchased for {amount}'**
  String purchasedFor(String amount);

  /// No description provided for @editItem.
  ///
  /// In en, this message translates to:
  /// **'Edit item'**
  String get editItem;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @imageSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save image'**
  String get imageSaveFailed;

  /// No description provided for @titleAndTargetRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title and target amount'**
  String get titleAndTargetRequired;

  /// No description provided for @convertToRepayingFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not switch to repaying (only available while saving)'**
  String get convertToRepayingFailed;

  /// No description provided for @deleteItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete item'**
  String get deleteItemTitle;

  /// No description provided for @deleteItemConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"? Transaction history will also be deleted.'**
  String deleteItemConfirm(String title);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @itemDeleted.
  ///
  /// In en, this message translates to:
  /// **'Item deleted'**
  String get itemDeleted;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @addPhotoOptional.
  ///
  /// In en, this message translates to:
  /// **'Add photo (optional)'**
  String get addPhotoOptional;

  /// No description provided for @fieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get fieldTitle;

  /// No description provided for @fieldTargetAmount.
  ///
  /// In en, this message translates to:
  /// **'Target amount'**
  String get fieldTargetAmount;

  /// No description provided for @purchasedOnCreditTitle.
  ///
  /// In en, this message translates to:
  /// **'Already purchased (record as debt)'**
  String get purchasedOnCreditTitle;

  /// No description provided for @purchasedOnCreditSubtitleNew.
  ///
  /// In en, this message translates to:
  /// **'Record as an advance for the full target amount'**
  String get purchasedOnCreditSubtitleNew;

  /// No description provided for @purchasedOnCreditSubtitleEdit.
  ///
  /// In en, this message translates to:
  /// **'On save, record as an advance for the target amount you enter'**
  String get purchasedOnCreditSubtitleEdit;

  /// No description provided for @fieldCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get fieldCurrency;

  /// No description provided for @fieldCategoryOptional.
  ///
  /// In en, this message translates to:
  /// **'Category (optional)'**
  String get fieldCategoryOptional;

  /// No description provided for @fieldTargetDateOptional.
  ///
  /// In en, this message translates to:
  /// **'Target date (optional)'**
  String get fieldTargetDateOptional;

  /// No description provided for @targetDateUnset.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get targetDateUnset;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @deleteThisItem.
  ///
  /// In en, this message translates to:
  /// **'Delete this item'**
  String get deleteThisItem;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @languageJapanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get languageJapanese;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @settingsBaseCurrency.
  ///
  /// In en, this message translates to:
  /// **'Base currency'**
  String get settingsBaseCurrency;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsWebUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Local notifications are not available on the web version.'**
  String get settingsNotificationsWebUnavailable;

  /// No description provided for @settingsNotifTiming.
  ///
  /// In en, this message translates to:
  /// **'Notification timing'**
  String get settingsNotifTiming;

  /// No description provided for @settingsNotifMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get settingsNotifMonthly;

  /// No description provided for @settingsNotifWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get settingsNotifWeekly;

  /// No description provided for @settingsNotifOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settingsNotifOff;

  /// No description provided for @settingsNotifWhichDay.
  ///
  /// In en, this message translates to:
  /// **'Which day of the month?'**
  String get settingsNotifWhichDay;

  /// No description provided for @settingsNotifMonthlyDay.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of each month'**
  String settingsNotifMonthlyDay(int day);

  /// No description provided for @settingsNotifWhichWeekday.
  ///
  /// In en, this message translates to:
  /// **'Which day of the week?'**
  String get settingsNotifWhichWeekday;

  /// No description provided for @settingsNotifTime.
  ///
  /// In en, this message translates to:
  /// **'Notification time'**
  String get settingsNotifTime;

  /// No description provided for @settingsNotifApply.
  ///
  /// In en, this message translates to:
  /// **'Save notifications'**
  String get settingsNotifApply;

  /// No description provided for @settingsNotifDisabledSnack.
  ///
  /// In en, this message translates to:
  /// **'Notifications turned off'**
  String get settingsNotifDisabledSnack;

  /// No description provided for @settingsNotifEnabledSnack.
  ///
  /// In en, this message translates to:
  /// **'Notifications saved'**
  String get settingsNotifEnabledSnack;

  /// No description provided for @notifBodyDaily.
  ///
  /// In en, this message translates to:
  /// **'Log today\'s deposit'**
  String get notifBodyDaily;

  /// No description provided for @notifBodyWeekly.
  ///
  /// In en, this message translates to:
  /// **'Log this week\'s deposit'**
  String get notifBodyWeekly;

  /// No description provided for @onboardingTagline.
  ///
  /// In en, this message translates to:
  /// **'Save up for what you want'**
  String get onboardingTagline;

  /// No description provided for @onboardingBody.
  ///
  /// In en, this message translates to:
  /// **'Make a jar for each thing you want, and watch it fill up.'**
  String get onboardingBody;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Let\'s start'**
  String get onboardingStart;

  /// No description provided for @homeHeroRemaining.
  ///
  /// In en, this message translates to:
  /// **'{amount} to go'**
  String homeHeroRemaining(String amount);

  /// No description provided for @homeHeroReached.
  ///
  /// In en, this message translates to:
  /// **'Ready to buy'**
  String get homeHeroReached;

  /// No description provided for @homeHeroRepaying.
  ///
  /// In en, this message translates to:
  /// **'{amount} left to pay back'**
  String homeHeroRepaying(String amount);

  /// No description provided for @homeHeroOf.
  ///
  /// In en, this message translates to:
  /// **'{current} of {target}'**
  String homeHeroOf(String current, String target);

  /// No description provided for @homeHeroDueInDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days left'**
  String homeHeroDueInDays(int days);

  /// No description provided for @homeHeroDueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get homeHeroDueToday;

  /// No description provided for @homeHeroOverdue.
  ///
  /// In en, this message translates to:
  /// **'{days} days past'**
  String homeHeroOverdue(int days);

  /// No description provided for @homeHeroNoDate.
  ///
  /// In en, this message translates to:
  /// **'No target date'**
  String get homeHeroNoDate;

  /// No description provided for @homeHeroPredicted.
  ///
  /// In en, this message translates to:
  /// **'On track for {date}'**
  String homeHeroPredicted(String date);

  /// No description provided for @homeHeroPredictedLate.
  ///
  /// In en, this message translates to:
  /// **'{days} days behind'**
  String homeHeroPredictedLate(int days);

  /// No description provided for @homeAddMoney.
  ///
  /// In en, this message translates to:
  /// **'Add money'**
  String get homeAddMoney;

  /// No description provided for @homeOtherVaults.
  ///
  /// In en, this message translates to:
  /// **'Your other jars'**
  String get homeOtherVaults;

  /// No description provided for @homeAllVaults.
  ///
  /// In en, this message translates to:
  /// **'Your jars'**
  String get homeAllVaults;

  /// No description provided for @homeViewCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed jars'**
  String get homeViewCompleted;

  /// No description provided for @homeSwipeHint.
  ///
  /// In en, this message translates to:
  /// **'Swipe to see other jars'**
  String get homeSwipeHint;

  /// No description provided for @pinToHome.
  ///
  /// In en, this message translates to:
  /// **'Pin to home'**
  String get pinToHome;

  /// No description provided for @pinnedToHome.
  ///
  /// In en, this message translates to:
  /// **'Pinned to home'**
  String get pinnedToHome;

  /// No description provided for @unpinnedFromHome.
  ///
  /// In en, this message translates to:
  /// **'Unpinned'**
  String get unpinnedFromHome;

  /// No description provided for @emptyVaultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No jars yet'**
  String get emptyVaultsTitle;

  /// No description provided for @notifPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are turned off. Allow them in Settings to get reminders.'**
  String get notifPermissionDenied;

  /// No description provided for @notifScheduleFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not set the reminder. Please try again.'**
  String get notifScheduleFailed;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @settingsDefaultCurrency.
  ///
  /// In en, this message translates to:
  /// **'Default currency'**
  String get settingsDefaultCurrency;

  /// No description provided for @settingsDefaultCurrencyHint.
  ///
  /// In en, this message translates to:
  /// **'Used when you create a new jar'**
  String get settingsDefaultCurrencyHint;

  /// No description provided for @notifBodyMonthly.
  ///
  /// In en, this message translates to:
  /// **'Time to add to your jars'**
  String get notifBodyMonthly;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @detailPurchaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark as bought'**
  String get detailPurchaseTitle;

  /// No description provided for @detailPurchaseConfirm.
  ///
  /// In en, this message translates to:
  /// **'Mark this item as bought?'**
  String get detailPurchaseConfirm;

  /// No description provided for @detailPurchaseDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get detailPurchaseDone;

  /// No description provided for @detailBuyOnCreditTitle.
  ///
  /// In en, this message translates to:
  /// **'Buy on credit'**
  String get detailBuyOnCreditTitle;

  /// No description provided for @detailBuyOnCreditConfirm.
  ///
  /// In en, this message translates to:
  /// **'You have not reached the target yet. Buy it now and record the remaining {amount} to pay back?'**
  String detailBuyOnCreditConfirm(String amount);

  /// No description provided for @detailBuyOnCreditConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get detailBuyOnCreditConfirmLabel;

  /// No description provided for @detailPurchasedSnack.
  ///
  /// In en, this message translates to:
  /// **'Bought!'**
  String get detailPurchasedSnack;

  /// No description provided for @detailOnCreditSnack.
  ///
  /// In en, this message translates to:
  /// **'Recorded as bought on credit ({amount} to pay back)'**
  String detailOnCreditSnack(String amount);

  /// No description provided for @detailBuyAction.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get detailBuyAction;

  /// No description provided for @detailRepayingHint.
  ///
  /// In en, this message translates to:
  /// **'Paying back: record your repayments here'**
  String get detailRepayingHint;

  /// No description provided for @detailHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get detailHistoryTitle;

  /// No description provided for @detailRecord.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get detailRecord;

  /// No description provided for @detailTargetDate.
  ///
  /// In en, this message translates to:
  /// **'Target date'**
  String get detailTargetDate;

  /// No description provided for @detailPredictedDate.
  ///
  /// In en, this message translates to:
  /// **'Predicted'**
  String get detailPredictedDate;

  /// No description provided for @detailDaysLate.
  ///
  /// In en, this message translates to:
  /// **'{days} days behind schedule'**
  String detailDaysLate(int days);

  /// No description provided for @detailNoTransactions.
  ///
  /// In en, this message translates to:
  /// **'No money in or out yet'**
  String get detailNoTransactions;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get invalidAmount;

  /// No description provided for @deleteTransactionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this record?'**
  String get deleteTransactionConfirm;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
