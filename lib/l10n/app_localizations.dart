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
