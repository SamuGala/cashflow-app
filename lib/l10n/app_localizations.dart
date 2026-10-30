import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_it.dart';

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
    Locale('es'),
    Locale('it'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Pockets Vault'**
  String get appName;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add transaction'**
  String get addTransaction;

  /// No description provided for @saveTransaction.
  ///
  /// In en, this message translates to:
  /// **'Save transaction'**
  String get saveTransaction;

  /// No description provided for @editTransaction.
  ///
  /// In en, this message translates to:
  /// **'Edit transaction'**
  String get editTransaction;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select category'**
  String get selectCategory;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @incomes.
  ///
  /// In en, this message translates to:
  /// **'Incomes'**
  String get incomes;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @transactionSaved.
  ///
  /// In en, this message translates to:
  /// **'Transaction saved'**
  String get transactionSaved;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent transactions'**
  String get recentTransactions;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions'**
  String get noTransactions;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get stats;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @lfTransactions.
  ///
  /// In en, this message translates to:
  /// **'Search transactions'**
  String get lfTransactions;

  /// No description provided for @newCategory.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get newCategory;

  /// No description provided for @nameCategory.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get nameCategory;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @expensesDistribution.
  ///
  /// In en, this message translates to:
  /// **'Expenses distribution'**
  String get expensesDistribution;

  /// No description provided for @noExpenses.
  ///
  /// In en, this message translates to:
  /// **'No expenses'**
  String get noExpenses;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @cancelAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all data'**
  String get cancelAll;

  /// No description provided for @categoryRemoved.
  ///
  /// In en, this message translates to:
  /// **'Category removed'**
  String get categoryRemoved;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @removeTransactionQ.
  ///
  /// In en, this message translates to:
  /// **'Delete transaction?'**
  String get removeTransactionQ;

  /// No description provided for @youSure.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get youSure;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @transactionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted'**
  String get transactionDeleted;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @deleteAllQ.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all saved data?'**
  String get deleteAllQ;

  /// No description provided for @salary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get salary;

  /// No description provided for @bonus.
  ///
  /// In en, this message translates to:
  /// **'Bonus'**
  String get bonus;

  /// No description provided for @gift.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get gift;

  /// No description provided for @food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get food;

  /// No description provided for @groceries.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get groceries;

  /// No description provided for @transport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get transport;

  /// No description provided for @rent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get rent;

  /// No description provided for @bills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get bills;

  /// No description provided for @shopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get shopping;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @entertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get entertainment;

  /// No description provided for @travel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get travel;

  /// No description provided for @education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// No description provided for @otherCategory.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherCategory;

  /// No description provided for @recurrents.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get recurrents;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @everyMonth.
  ///
  /// In en, this message translates to:
  /// **'Every month'**
  String get everyMonth;

  /// No description provided for @recurrenceEveryDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every day} other{Every {count} days}}'**
  String recurrenceEveryDays(int count);

  /// No description provided for @recurrenceEveryWeeks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every week} other{Every {count} weeks}}'**
  String recurrenceEveryWeeks(int count);

  /// No description provided for @recurrenceEveryMonths.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every month} other{Every {count} months}}'**
  String recurrenceEveryMonths(int count);

  /// No description provided for @recurrenceEveryYears.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every year} other{Every {count} years}}'**
  String recurrenceEveryYears(int count);

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @modify.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get modify;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @recurrent.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get recurrent;

  /// No description provided for @recurrentMsg.
  ///
  /// In en, this message translates to:
  /// **'Turn on to repeat it automatically'**
  String get recurrentMsg;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @modifyRecurrent.
  ///
  /// In en, this message translates to:
  /// **'Edit recurring transaction'**
  String get modifyRecurrent;

  /// No description provided for @modifyCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get modifyCategory;

  /// No description provided for @noRecurrent.
  ///
  /// In en, this message translates to:
  /// **'No recurring transactions'**
  String get noRecurrent;

  /// No description provided for @reactivate.
  ///
  /// In en, this message translates to:
  /// **'Reactivate'**
  String get reactivate;

  /// No description provided for @reactivateMsg.
  ///
  /// In en, this message translates to:
  /// **'Recurring transaction reactivated'**
  String get reactivateMsg;

  /// No description provided for @reactivatePauseMsg.
  ///
  /// In en, this message translates to:
  /// **'Recurring transaction paused'**
  String get reactivatePauseMsg;

  /// No description provided for @dayOfMonth.
  ///
  /// In en, this message translates to:
  /// **'Day of the month'**
  String get dayOfMonth;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @recurringCreationMsg.
  ///
  /// In en, this message translates to:
  /// **'Recurring transaction created '**
  String get recurringCreationMsg;

  /// No description provided for @deleteMovement.
  ///
  /// In en, this message translates to:
  /// **'Delete transaction?'**
  String get deleteMovement;

  /// No description provided for @deleteMovementSure.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone'**
  String get deleteMovementSure;

  /// No description provided for @deletedMovement.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted'**
  String get deletedMovement;

  /// No description provided for @addExpenseToViewGraph.
  ///
  /// In en, this message translates to:
  /// **'Add an expense to view the chart'**
  String get addExpenseToViewGraph;

  /// No description provided for @selectYear.
  ///
  /// In en, this message translates to:
  /// **'Select year'**
  String get selectYear;

  /// No description provided for @existingCategory.
  ///
  /// In en, this message translates to:
  /// **'Category already exists'**
  String get existingCategory;

  /// No description provided for @saveCategory.
  ///
  /// In en, this message translates to:
  /// **'Save category'**
  String get saveCategory;

  /// No description provided for @canceledAll.
  ///
  /// In en, this message translates to:
  /// **'All data has been deleted'**
  String get canceledAll;

  /// No description provided for @searchBar.
  ///
  /// In en, this message translates to:
  /// **'Search transaction'**
  String get searchBar;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @savedMore.
  ///
  /// In en, this message translates to:
  /// **'You spent {value}% less than last month'**
  String savedMore(Object value);

  /// No description provided for @spentMore.
  ///
  /// In en, this message translates to:
  /// **'You spent {value}% more than last month'**
  String spentMore(Object value);

  /// No description provided for @spentSameAsLastMonth.
  ///
  /// In en, this message translates to:
  /// **'This month you are spending about the same as last month'**
  String get spentSameAsLastMonth;

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get period;

  /// No description provided for @selectPeriod.
  ///
  /// In en, this message translates to:
  /// **'Select period'**
  String get selectPeriod;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get allCategories;

  /// No description provided for @mostUsedCategories.
  ///
  /// In en, this message translates to:
  /// **'Most used categories'**
  String get mostUsedCategories;

  /// No description provided for @otherCategories.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherCategories;

  /// No description provided for @deleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get deleteCategory;

  /// No description provided for @deleteCategoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this category?'**
  String get deleteCategoryConfirm;

  /// No description provided for @createPin.
  ///
  /// In en, this message translates to:
  /// **'Create PIN'**
  String get createPin;

  /// No description provided for @confirmPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get confirmPin;

  /// No description provided for @enterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get enterPin;

  /// No description provided for @enableBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Enable biometric unlock'**
  String get enableBiometrics;

  /// No description provided for @enableBiometricsMessage.
  ///
  /// In en, this message translates to:
  /// **'Use Face ID or your fingerprint to unlock Pockets Vault?'**
  String get enableBiometricsMessage;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @biometricUnlock.
  ///
  /// In en, this message translates to:
  /// **'Biometric unlock'**
  String get biometricUnlock;

  /// No description provided for @biometricReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock Pockets Vault'**
  String get biometricReason;

  /// No description provided for @deleteDigit.
  ///
  /// In en, this message translates to:
  /// **'Delete digit'**
  String get deleteDigit;

  /// No description provided for @clearPin.
  ///
  /// In en, this message translates to:
  /// **'Clear PIN'**
  String get clearPin;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// No description provided for @mainCurrency.
  ///
  /// In en, this message translates to:
  /// **'Main currency'**
  String get mainCurrency;

  /// No description provided for @updateRates.
  ///
  /// In en, this message translates to:
  /// **'Refresh rates'**
  String get updateRates;

  /// No description provided for @automaticLock.
  ///
  /// In en, this message translates to:
  /// **'Automatic lock'**
  String get automaticLock;

  /// No description provided for @backupPortability.
  ///
  /// In en, this message translates to:
  /// **'Backup and portability'**
  String get backupPortability;

  /// No description provided for @encryptedBackupCaption.
  ///
  /// In en, this message translates to:
  /// **'AES-256 encryption, CSV export and local restore'**
  String get encryptedBackupCaption;

  /// No description provided for @exportEncryptedBackup.
  ///
  /// In en, this message translates to:
  /// **'Export encrypted backup'**
  String get exportEncryptedBackup;

  /// No description provided for @exportTransactionsCsv.
  ///
  /// In en, this message translates to:
  /// **'Export transactions as CSV'**
  String get exportTransactionsCsv;

  /// No description provided for @importBackup.
  ///
  /// In en, this message translates to:
  /// **'Import backup'**
  String get importBackup;

  /// No description provided for @safeMergeOrReplace.
  ///
  /// In en, this message translates to:
  /// **'Safe merge or complete replacement'**
  String get safeMergeOrReplace;

  /// No description provided for @localSmartRules.
  ///
  /// In en, this message translates to:
  /// **'Local smart rules'**
  String get localSmartRules;

  /// No description provided for @privateCategorization.
  ///
  /// In en, this message translates to:
  /// **'Private categorization without sending data'**
  String get privateCategorization;

  /// No description provided for @noRules.
  ///
  /// In en, this message translates to:
  /// **'No rules'**
  String get noRules;

  /// No description provided for @noRulesHint.
  ///
  /// In en, this message translates to:
  /// **'You can remember one while adding a transaction.'**
  String get noRulesHint;

  /// No description provided for @availableToSpend.
  ///
  /// In en, this message translates to:
  /// **'Available to spend'**
  String get availableToSpend;

  /// No description provided for @budgets.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgets;

  /// No description provided for @optionalMonthlyBudgets.
  ///
  /// In en, this message translates to:
  /// **'Optional monthly budgets, editable at any time'**
  String get optionalMonthlyBudgets;

  /// No description provided for @noBudget.
  ///
  /// In en, this message translates to:
  /// **'No budget'**
  String get noBudget;

  /// No description provided for @forecast90Days.
  ///
  /// In en, this message translates to:
  /// **'90-day forecast'**
  String get forecast90Days;

  /// No description provided for @noForecastMovements.
  ///
  /// In en, this message translates to:
  /// **'No recurring transactions forecast.'**
  String get noForecastMovements;

  /// No description provided for @savingsGoals.
  ///
  /// In en, this message translates to:
  /// **'Savings goals'**
  String get savingsGoals;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// No description provided for @createGoalHint.
  ///
  /// In en, this message translates to:
  /// **'Create a goal and track your progress.'**
  String get createGoalHint;

  /// No description provided for @newGoal.
  ///
  /// In en, this message translates to:
  /// **'New goal'**
  String get newGoal;

  /// No description provided for @noGoals.
  ///
  /// In en, this message translates to:
  /// **'No goals'**
  String get noGoals;

  /// No description provided for @rememberCategory.
  ///
  /// In en, this message translates to:
  /// **'Remember this category'**
  String get rememberCategory;

  /// No description provided for @rememberCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Suggest it for similar descriptions, only on this device.'**
  String get rememberCategoryHint;

  /// No description provided for @addReceipt.
  ///
  /// In en, this message translates to:
  /// **'Add receipt'**
  String get addReceipt;

  /// No description provided for @receiptAttached.
  ///
  /// In en, this message translates to:
  /// **'Receipt attached'**
  String get receiptAttached;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhoto;

  /// No description provided for @chooseLibrary.
  ///
  /// In en, this message translates to:
  /// **'Choose from library'**
  String get chooseLibrary;

  /// No description provided for @repeatEvery.
  ///
  /// In en, this message translates to:
  /// **'Repeat every'**
  String get repeatEvery;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get endDate;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @recurrenceDeleted.
  ///
  /// In en, this message translates to:
  /// **'Recurrence deleted'**
  String get recurrenceDeleted;

  /// No description provided for @availableThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Available this month'**
  String get availableThisMonth;

  /// No description provided for @availableAllTime.
  ///
  /// In en, this message translates to:
  /// **'Overall available'**
  String get availableAllTime;

  /// No description provided for @availableForPeriod.
  ///
  /// In en, this message translates to:
  /// **'Available in period'**
  String get availableForPeriod;

  /// No description provided for @availableFormula.
  ///
  /// In en, this message translates to:
  /// **'Income − expenses − reserved savings − scheduled recurring payments'**
  String get availableFormula;

  /// No description provided for @reservedSavings.
  ///
  /// In en, this message translates to:
  /// **'Reserved'**
  String get reservedSavings;

  /// No description provided for @scheduledUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming transactions'**
  String get scheduledUpcoming;

  /// No description provided for @categoryLimits.
  ///
  /// In en, this message translates to:
  /// **'Category limits'**
  String get categoryLimits;

  /// No description provided for @activeBudgets.
  ///
  /// In en, this message translates to:
  /// **'{count} active'**
  String activeBudgets(Object count);

  /// No description provided for @remainingBudget.
  ///
  /// In en, this message translates to:
  /// **'{amount} remaining'**
  String remainingBudget(Object amount);

  /// No description provided for @budgetExceededBy.
  ///
  /// In en, this message translates to:
  /// **'Exceeded by {amount}'**
  String budgetExceededBy(Object amount);

  /// No description provided for @setOptionalLimit.
  ///
  /// In en, this message translates to:
  /// **'Set an optional limit'**
  String get setOptionalLimit;

  /// No description provided for @budgetForCategory.
  ///
  /// In en, this message translates to:
  /// **'Monthly budget · {category}'**
  String budgetForCategory(Object category);

  /// No description provided for @amountInCurrency.
  ///
  /// In en, this message translates to:
  /// **'Amount in {currency}'**
  String amountInCurrency(Object currency);

  /// No description provided for @enterPositiveAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than zero.'**
  String get enterPositiveAmount;

  /// No description provided for @budgetDeleted.
  ///
  /// In en, this message translates to:
  /// **'Budget deleted'**
  String get budgetDeleted;

  /// No description provided for @budgetPeriodHint.
  ///
  /// In en, this message translates to:
  /// **'Monthly limits are prorated to the selected interval.'**
  String get budgetPeriodHint;

  /// No description provided for @forecastRecurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring forecast'**
  String get forecastRecurring;

  /// No description provided for @forecastExplanation.
  ///
  /// In en, this message translates to:
  /// **'Estimate from the current balance using scheduled recurring transactions only.'**
  String get forecastExplanation;

  /// No description provided for @currentBalance.
  ///
  /// In en, this message translates to:
  /// **'Current balance'**
  String get currentBalance;

  /// No description provided for @forecastAfter.
  ///
  /// In en, this message translates to:
  /// **'In {duration}'**
  String forecastAfter(Object duration);

  /// No description provided for @recurringIncluded.
  ///
  /// In en, this message translates to:
  /// **'{count} recurring transactions included in the calculation.'**
  String recurringIncluded(Object count);

  /// No description provided for @oneMonth.
  ///
  /// In en, this message translates to:
  /// **'1 month'**
  String get oneMonth;

  /// No description provided for @monthsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} months'**
  String monthsCount(Object count);

  /// No description provided for @oneYear.
  ///
  /// In en, this message translates to:
  /// **'1 year'**
  String get oneYear;

  /// No description provided for @yearsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} years'**
  String yearsCount(Object count);

  /// No description provided for @savingsReservedHint.
  ///
  /// In en, this message translates to:
  /// **'Reserved amounts reduce what is available to spend, while remaining part of your balance.'**
  String get savingsReservedHint;

  /// No description provided for @allocatedInSelection.
  ///
  /// In en, this message translates to:
  /// **'Reserved in this period: {amount}'**
  String allocatedInSelection(Object amount);

  /// No description provided for @reserveFunds.
  ///
  /// In en, this message translates to:
  /// **'Reserve'**
  String get reserveFunds;

  /// No description provided for @releaseFunds.
  ///
  /// In en, this message translates to:
  /// **'Release funds'**
  String get releaseFunds;

  /// No description provided for @addSavings.
  ///
  /// In en, this message translates to:
  /// **'Add savings'**
  String get addSavings;

  /// No description provided for @releaseSavings.
  ///
  /// In en, this message translates to:
  /// **'Release savings'**
  String get releaseSavings;

  /// No description provided for @goalName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get goalName;

  /// No description provided for @goalTarget.
  ///
  /// In en, this message translates to:
  /// **'Goal · {name}'**
  String goalTarget(Object name);

  /// No description provided for @deleteGoal.
  ///
  /// In en, this message translates to:
  /// **'Delete this goal?'**
  String get deleteGoal;

  /// No description provided for @deleteGoalReleasesFunds.
  ///
  /// In en, this message translates to:
  /// **'Reserved funds will become available again. History is preserved and transactions are not changed.'**
  String get deleteGoalReleasesFunds;

  /// No description provided for @goalDeleted.
  ///
  /// In en, this message translates to:
  /// **'Goal deleted'**
  String get goalDeleted;

  /// No description provided for @maximumAmount.
  ///
  /// In en, this message translates to:
  /// **'Maximum {amount}'**
  String maximumAmount(Object amount);

  /// No description provided for @receiptOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional receipt'**
  String get receiptOptional;

  /// No description provided for @receiptPurpose.
  ///
  /// In en, this message translates to:
  /// **'Reads amount, date, merchant and category directly on your device.'**
  String get receiptPurpose;

  /// No description provided for @receiptStoredLocally.
  ///
  /// In en, this message translates to:
  /// **'Private on-device scan, with review before saving.'**
  String get receiptStoredLocally;

  /// No description provided for @receiptLinked.
  ///
  /// In en, this message translates to:
  /// **'Attached to this transaction'**
  String get receiptLinked;

  /// No description provided for @receiptPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied. Enable photos and camera in Settings.'**
  String get receiptPermissionDenied;

  /// No description provided for @cameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Camera unavailable on this device.'**
  String get cameraUnavailable;

  /// No description provided for @libraryUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Photo library unavailable on this device.'**
  String get libraryUnavailable;

  /// No description provided for @receiptAttachFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to attach the receipt.'**
  String get receiptAttachFailed;

  /// No description provided for @convertedToMainCurrency.
  ///
  /// In en, this message translates to:
  /// **'≈ {amount} in the main currency'**
  String convertedToMainCurrency(Object amount);

  /// No description provided for @conversionOnSave.
  ///
  /// In en, this message translates to:
  /// **'The exchange rate will be calculated when saving.'**
  String get conversionOnSave;

  /// No description provided for @ecbRefreshNeeded.
  ///
  /// In en, this message translates to:
  /// **'ECB conversion · update required'**
  String get ecbRefreshNeeded;

  /// No description provided for @ecbRatesDate.
  ///
  /// In en, this message translates to:
  /// **'ECB rates from {date}'**
  String ecbRatesDate(Object date);

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate app'**
  String get rateApp;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share app'**
  String get shareApp;

  /// No description provided for @protectBackup.
  ///
  /// In en, this message translates to:
  /// **'Protect backup'**
  String get protectBackup;

  /// No description provided for @unlockBackup.
  ///
  /// In en, this message translates to:
  /// **'Unlock backup'**
  String get unlockBackup;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @exportCanceled.
  ///
  /// In en, this message translates to:
  /// **'Export canceled.'**
  String get exportCanceled;

  /// No description provided for @backupReady.
  ///
  /// In en, this message translates to:
  /// **'Backup ready to save or share.'**
  String get backupReady;

  /// No description provided for @csvReady.
  ///
  /// In en, this message translates to:
  /// **'CSV ready to save or share.'**
  String get csvReady;

  /// No description provided for @importMode.
  ///
  /// In en, this message translates to:
  /// **'Import mode'**
  String get importMode;

  /// No description provided for @importModeExplanation.
  ///
  /// In en, this message translates to:
  /// **'Merge keeps current data and updates items with the same identifier. Replace first deletes all local financial data.'**
  String get importModeExplanation;

  /// No description provided for @merge.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get merge;

  /// No description provided for @replace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replace;

  /// No description provided for @backupRestored.
  ///
  /// In en, this message translates to:
  /// **'Backup restored successfully.'**
  String get backupRestored;

  /// No description provided for @minimumPassword.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters.'**
  String get minimumPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatch;

  /// No description provided for @minimumEightCharacters.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get minimumEightCharacters;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @changeCurrency.
  ///
  /// In en, this message translates to:
  /// **'Change currency'**
  String get changeCurrency;

  /// No description provided for @recursEvery.
  ///
  /// In en, this message translates to:
  /// **'Every {interval} {frequency}'**
  String recursEvery(Object frequency, Object interval);

  /// No description provided for @savingsUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to update the savings goal.'**
  String get savingsUpdateFailed;

  /// No description provided for @hideAmounts.
  ///
  /// In en, this message translates to:
  /// **'Hide amounts'**
  String get hideAmounts;

  /// No description provided for @showAmounts.
  ///
  /// In en, this message translates to:
  /// **'Show amounts'**
  String get showAmounts;

  /// No description provided for @scanReceipt.
  ///
  /// In en, this message translates to:
  /// **'Scan receipt'**
  String get scanReceipt;

  /// No description provided for @receiptScanHint.
  ///
  /// In en, this message translates to:
  /// **'Take or choose a receipt photo to fill the expense automatically.'**
  String get receiptScanHint;

  /// No description provided for @scanWithCamera.
  ///
  /// In en, this message translates to:
  /// **'Scan with camera'**
  String get scanWithCamera;

  /// No description provided for @scanFromLibrary.
  ///
  /// In en, this message translates to:
  /// **'Scan a photo'**
  String get scanFromLibrary;

  /// No description provided for @cameraFlash.
  ///
  /// In en, this message translates to:
  /// **'Flash'**
  String get cameraFlash;

  /// No description provided for @receiptScanReview.
  ///
  /// In en, this message translates to:
  /// **'Review scan'**
  String get receiptScanReview;

  /// No description provided for @receiptScanCheckData.
  ///
  /// In en, this message translates to:
  /// **'We found these details. Review and edit them before continuing.'**
  String get receiptScanCheckData;

  /// No description provided for @receiptScanNoData.
  ///
  /// In en, this message translates to:
  /// **'We could not read reliable details. Enter them manually or attach the photo only.'**
  String get receiptScanNoData;

  /// No description provided for @receiptMerchant.
  ///
  /// In en, this message translates to:
  /// **'Merchant'**
  String get receiptMerchant;

  /// No description provided for @receiptScanPrivate.
  ///
  /// In en, this message translates to:
  /// **'OCR and analysis happen entirely on this device.'**
  String get receiptScanPrivate;

  /// No description provided for @attachOnly.
  ///
  /// In en, this message translates to:
  /// **'Attach only'**
  String get attachOnly;

  /// No description provided for @useDetectedData.
  ///
  /// In en, this message translates to:
  /// **'Use details'**
  String get useDetectedData;

  /// No description provided for @receiptScanApplied.
  ///
  /// In en, this message translates to:
  /// **'Receipt details applied. Review and save the transaction.'**
  String get receiptScanApplied;

  /// No description provided for @receiptScanning.
  ///
  /// In en, this message translates to:
  /// **'Analyzing receipt…'**
  String get receiptScanning;

  /// No description provided for @dataTemporarilyUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Data temporarily unavailable.'**
  String get dataTemporarilyUnavailable;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @yourMonth.
  ///
  /// In en, this message translates to:
  /// **'Your month'**
  String get yourMonth;

  /// No description provided for @byCategory.
  ///
  /// In en, this message translates to:
  /// **'By category'**
  String get byCategory;

  /// No description provided for @statsOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get statsOverview;

  /// No description provided for @statsCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get statsCategories;

  /// No description provided for @statsComparisons.
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get statsComparisons;

  /// No description provided for @statsTrend.
  ///
  /// In en, this message translates to:
  /// **'Cumulative trend'**
  String get statsTrend;

  /// No description provided for @statsBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Where your money goes'**
  String get statsBreakdown;

  /// No description provided for @statsWhatChanged.
  ///
  /// In en, this message translates to:
  /// **'What changed'**
  String get statsWhatChanged;

  /// No description provided for @statsChangeDrivers.
  ///
  /// In en, this message translates to:
  /// **'What explains the change'**
  String get statsChangeDrivers;

  /// No description provided for @statsPreviousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get statsPreviousMonth;

  /// No description provided for @statsChooseMonth.
  ///
  /// In en, this message translates to:
  /// **'Choose a month'**
  String get statsChooseMonth;

  /// No description provided for @statsYearAverage.
  ///
  /// In en, this message translates to:
  /// **'Average of earlier months this year'**
  String get statsYearAverage;

  /// No description provided for @statsCompareWith.
  ///
  /// In en, this message translates to:
  /// **'Compare with'**
  String get statsCompareWith;

  /// No description provided for @statsComparisonPeriod.
  ///
  /// In en, this message translates to:
  /// **'Comparison period'**
  String get statsComparisonPeriod;

  /// No description provided for @statsPrimaryMonth.
  ///
  /// In en, this message translates to:
  /// **'Month to analyse'**
  String get statsPrimaryMonth;

  /// No description provided for @statsReferenceMonth.
  ///
  /// In en, this message translates to:
  /// **'Reference month'**
  String get statsReferenceMonth;

  /// No description provided for @statsElapsedDays.
  ///
  /// In en, this message translates to:
  /// **'Align elapsed days'**
  String get statsElapsedDays;

  /// No description provided for @statsElapsedHint.
  ///
  /// In en, this message translates to:
  /// **'For the current month, compare the same days in each reference month.'**
  String get statsElapsedHint;

  /// No description provided for @statsThroughDay.
  ///
  /// In en, this message translates to:
  /// **'Days 1–{day} in each month'**
  String statsThroughDay(int day);

  /// No description provided for @statsWholeMonths.
  ///
  /// In en, this message translates to:
  /// **'Entire selected months'**
  String get statsWholeMonths;

  /// No description provided for @statsAverageBasis.
  ///
  /// In en, this message translates to:
  /// **'Average of {count} months, including months with no transactions.'**
  String statsAverageBasis(int count);

  /// No description provided for @statsNoEarlierMonths.
  ///
  /// In en, this message translates to:
  /// **'January has no earlier months in the same year. Choose a different comparison.'**
  String get statsNoEarlierMonths;

  /// No description provided for @statsZeroReference.
  ///
  /// In en, this message translates to:
  /// **'Percentage unavailable: the reference amount is zero.'**
  String get statsZeroReference;

  /// No description provided for @statsNet.
  ///
  /// In en, this message translates to:
  /// **'Income − expenses'**
  String get statsNet;

  /// No description provided for @statsShowTransactions.
  ///
  /// In en, this message translates to:
  /// **'View transactions'**
  String get statsShowTransactions;

  /// No description provided for @statsDragHint.
  ///
  /// In en, this message translates to:
  /// **'Drag across the chart to explore'**
  String get statsDragHint;

  /// No description provided for @statsForecastToday.
  ///
  /// In en, this message translates to:
  /// **'Recurring forecast from today'**
  String get statsForecastToday;

  /// No description provided for @statsCompareHint.
  ///
  /// In en, this message translates to:
  /// **'Choose the months to compare here.'**
  String get statsCompareHint;

  /// No description provided for @statsRecordedOnly.
  ///
  /// In en, this message translates to:
  /// **'Recorded transactions'**
  String get statsRecordedOnly;

  /// No description provided for @statsMonthTitle.
  ///
  /// In en, this message translates to:
  /// **'Select month'**
  String get statsMonthTitle;

  /// No description provided for @statsCategoryChange.
  ///
  /// In en, this message translates to:
  /// **'Change by category'**
  String get statsCategoryChange;

  /// No description provided for @statsCurrent.
  ///
  /// In en, this message translates to:
  /// **'Selected month'**
  String get statsCurrent;

  /// No description provided for @statsReference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get statsReference;

  /// No description provided for @statsHiddenChart.
  ///
  /// In en, this message translates to:
  /// **'Chart hidden while amount privacy is enabled.'**
  String get statsHiddenChart;

  /// No description provided for @statsAllTime.
  ///
  /// In en, this message translates to:
  /// **'All recorded dates'**
  String get statsAllTime;

  /// No description provided for @statsComparisonUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No reference period'**
  String get statsComparisonUnavailable;

  /// No description provided for @statsTransactionCount.
  ///
  /// In en, this message translates to:
  /// **'{count} transactions'**
  String statsTransactionCount(int count);

  /// No description provided for @statsPercentage.
  ///
  /// In en, this message translates to:
  /// **'{value}%'**
  String statsPercentage(String value);

  /// No description provided for @statsVersus.
  ///
  /// In en, this message translates to:
  /// **'Compared with {period}'**
  String statsVersus(String period);

  /// No description provided for @statsAverageLabel.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get statsAverageLabel;

  /// No description provided for @statsMonthlyExpenses.
  ///
  /// In en, this message translates to:
  /// **'Monthly spending'**
  String get statsMonthlyExpenses;

  /// No description provided for @statsMonthlyIncome.
  ///
  /// In en, this message translates to:
  /// **'Monthly income'**
  String get statsMonthlyIncome;

  /// No description provided for @statsPeriodExpenses.
  ///
  /// In en, this message translates to:
  /// **'Period spending'**
  String get statsPeriodExpenses;

  /// No description provided for @statsPeriodIncome.
  ///
  /// In en, this message translates to:
  /// **'Period income'**
  String get statsPeriodIncome;

  /// No description provided for @statsTotalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total spending'**
  String get statsTotalExpenses;

  /// No description provided for @statsTotalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total income'**
  String get statsTotalIncome;

  /// No description provided for @statsPreviousPeriod.
  ///
  /// In en, this message translates to:
  /// **'previous period'**
  String get statsPreviousPeriod;

  /// No description provided for @statsRangeCaption.
  ///
  /// In en, this message translates to:
  /// **'Comparison: {period}'**
  String statsRangeCaption(Object period);

  /// No description provided for @statsSpentLess.
  ///
  /// In en, this message translates to:
  /// **'{amount} less spent'**
  String statsSpentLess(Object amount);

  /// No description provided for @statsSpentMore.
  ///
  /// In en, this message translates to:
  /// **'{amount} more spent'**
  String statsSpentMore(Object amount);

  /// No description provided for @statsIncomeLess.
  ///
  /// In en, this message translates to:
  /// **'{amount} less income'**
  String statsIncomeLess(Object amount);

  /// No description provided for @statsIncomeMore.
  ///
  /// In en, this message translates to:
  /// **'{amount} more income'**
  String statsIncomeMore(Object amount);

  /// No description provided for @statsMainVariation.
  ///
  /// In en, this message translates to:
  /// **'{category} is the main change'**
  String statsMainVariation(Object category);

  /// No description provided for @statsExplainsDrop.
  ///
  /// In en, this message translates to:
  /// **'{category} explains the decrease'**
  String statsExplainsDrop(Object category);

  /// No description provided for @statsExplainsRise.
  ///
  /// In en, this message translates to:
  /// **'{category} explains the increase'**
  String statsExplainsRise(Object category);

  /// No description provided for @statsOpenCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Open the category to see transactions'**
  String get statsOpenCategoryHint;

  /// No description provided for @statsExpenseVersus.
  ///
  /// In en, this message translates to:
  /// **'in spending compared with {period}'**
  String statsExpenseVersus(Object period);

  /// No description provided for @statsIncomeVersus.
  ///
  /// In en, this message translates to:
  /// **'in income compared with {period}'**
  String statsIncomeVersus(Object period);

  /// No description provided for @movementsHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get movementsHistory;

  /// No description provided for @swipeHint.
  ///
  /// In en, this message translates to:
  /// **'Swipe right to edit, left to delete'**
  String get swipeHint;

  /// No description provided for @movementsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 transaction} other{{count} transactions}}'**
  String movementsCount(int count);

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @newCategoryShort.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newCategoryShort;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get addNote;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsSupport.
  ///
  /// In en, this message translates to:
  /// **'Support Pockets Vault'**
  String get settingsSupport;

  /// No description provided for @suggested.
  ///
  /// In en, this message translates to:
  /// **'Suggested'**
  String get suggested;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @filterType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get filterType;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get filterCategories;

  /// No description provided for @filterCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get filterCurrency;

  /// No description provided for @filterReceipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get filterReceipt;

  /// No description provided for @filterWithReceipt.
  ///
  /// In en, this message translates to:
  /// **'With receipt'**
  String get filterWithReceipt;

  /// No description provided for @filterWithoutReceipt.
  ///
  /// In en, this message translates to:
  /// **'Without receipt'**
  String get filterWithoutReceipt;

  /// No description provided for @filterReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get filterReset;

  /// No description provided for @filterShowMovements.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No movements} =1{Show 1 movement} other{Show {count} movements}}'**
  String filterShowMovements(int count);

  /// No description provided for @filterNoResults.
  ///
  /// In en, this message translates to:
  /// **'No movements match these filters.'**
  String get filterNoResults;

  /// No description provided for @filterClear.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get filterClear;

  /// No description provided for @filterCategoriesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 category} other{{count} categories}}'**
  String filterCategoriesCount(int count);

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notifyRecurring.
  ///
  /// In en, this message translates to:
  /// **'Upcoming recurrences'**
  String get notifyRecurring;

  /// No description provided for @notifyBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget alert'**
  String get notifyBudget;

  /// No description provided for @notifyReminder.
  ///
  /// In en, this message translates to:
  /// **'Evening reminder'**
  String get notifyReminder;

  /// No description provided for @notifyReminderCaption.
  ///
  /// In en, this message translates to:
  /// **'Only if you haven\'t logged anything today'**
  String get notifyReminderCaption;

  /// No description provided for @notifyHideAmounts.
  ///
  /// In en, this message translates to:
  /// **'Hide amounts in notifications'**
  String get notifyHideAmounts;

  /// No description provided for @notifySameDay.
  ///
  /// In en, this message translates to:
  /// **'On the day'**
  String get notifySameDay;

  /// No description provided for @notifyDaysBefore.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day before} other{{count} days before}}'**
  String notifyDaysBefore(int count);

  /// No description provided for @notifyAtPercent.
  ///
  /// In en, this message translates to:
  /// **'At {percent}%'**
  String notifyAtPercent(int percent);

  /// No description provided for @notifyPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off. Turn them on in the phone settings.'**
  String get notifyPermissionDenied;

  /// No description provided for @notifyRecurringTitleToday.
  ///
  /// In en, this message translates to:
  /// **'{name} today'**
  String notifyRecurringTitleToday(String name);

  /// No description provided for @notifyRecurringTitleTomorrow.
  ///
  /// In en, this message translates to:
  /// **'{name} tomorrow'**
  String notifyRecurringTitleTomorrow(String name);

  /// No description provided for @notifyRecurringTitleIn.
  ///
  /// In en, this message translates to:
  /// **'{name} in {days} days'**
  String notifyRecurringTitleIn(String name, int days);

  /// No description provided for @notifyRecurringExpenseBody.
  ///
  /// In en, this message translates to:
  /// **'Recurring expense of {amount}.'**
  String notifyRecurringExpenseBody(String amount);

  /// No description provided for @notifyRecurringIncomeBody.
  ///
  /// In en, this message translates to:
  /// **'Recurring income of {amount}.'**
  String notifyRecurringIncomeBody(String amount);

  /// No description provided for @notifyRecurringHiddenBody.
  ///
  /// In en, this message translates to:
  /// **'A recurring movement is coming up.'**
  String get notifyRecurringHiddenBody;

  /// No description provided for @notifyBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'{category} at {percent}% of budget'**
  String notifyBudgetTitle(String category, int percent);

  /// No description provided for @notifyBudgetOverTitle.
  ///
  /// In en, this message translates to:
  /// **'{category} budget exceeded'**
  String notifyBudgetOverTitle(String category);

  /// No description provided for @notifyBudgetBody.
  ///
  /// In en, this message translates to:
  /// **'{spent} of {limit} spent this month.'**
  String notifyBudgetBody(String spent, String limit);

  /// No description provided for @notifyBudgetHiddenBody.
  ///
  /// In en, this message translates to:
  /// **'Open the app to see the details.'**
  String get notifyBudgetHiddenBody;

  /// No description provided for @notifyReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Did you spend anything today?'**
  String get notifyReminderTitle;

  /// No description provided for @notifyReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Log it in a few seconds.'**
  String get notifyReminderBody;

  /// No description provided for @notifyChannelName.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get notifyChannelName;

  /// No description provided for @notifyWhen.
  ///
  /// In en, this message translates to:
  /// **'When to remind you'**
  String get notifyWhen;

  /// No description provided for @notifyThreshold.
  ///
  /// In en, this message translates to:
  /// **'Threshold'**
  String get notifyThreshold;

  /// No description provided for @notifyTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get notifyTime;

  /// No description provided for @notifyRecurringCaption.
  ///
  /// In en, this message translates to:
  /// **'At 9:00, before each recurring movement'**
  String get notifyRecurringCaption;

  /// No description provided for @notifyBudgetCaption.
  ///
  /// In en, this message translates to:
  /// **'When a category nears its monthly limit'**
  String get notifyBudgetCaption;

  /// No description provided for @widgetMonthBalance.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get widgetMonthBalance;

  /// No description provided for @widgetReceipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get widgetReceipt;

  /// No description provided for @quickActionExpense.
  ///
  /// In en, this message translates to:
  /// **'New expense'**
  String get quickActionExpense;

  /// No description provided for @quickActionIncome.
  ///
  /// In en, this message translates to:
  /// **'New income'**
  String get quickActionIncome;

  /// No description provided for @quickActionScan.
  ///
  /// In en, this message translates to:
  /// **'Scan receipt'**
  String get quickActionScan;

  /// No description provided for @recapTitle.
  ///
  /// In en, this message translates to:
  /// **'Your {year}'**
  String recapTitle(String year);

  /// No description provided for @recapEarnedIn.
  ///
  /// In en, this message translates to:
  /// **'In {year} you earned'**
  String recapEarnedIn(String year);

  /// No description provided for @recapSpentIn.
  ///
  /// In en, this message translates to:
  /// **'In {year} you spent'**
  String recapSpentIn(String year);

  /// No description provided for @recapYouSpent.
  ///
  /// In en, this message translates to:
  /// **'You spent'**
  String get recapYouSpent;

  /// No description provided for @recapYouKept.
  ///
  /// In en, this message translates to:
  /// **'You kept'**
  String get recapYouKept;

  /// No description provided for @recapKeptPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of what you earned'**
  String recapKeptPercent(int percent);

  /// No description provided for @recapMonthByMonth.
  ///
  /// In en, this message translates to:
  /// **'Month by month'**
  String get recapMonthByMonth;

  /// No description provided for @recapMonthsHeadline.
  ///
  /// In en, this message translates to:
  /// **'{high} the priciest month, {low} the lightest'**
  String recapMonthsHeadline(String high, String low);

  /// No description provided for @recapMonthlyAverage.
  ///
  /// In en, this message translates to:
  /// **'Monthly average'**
  String get recapMonthlyAverage;

  /// No description provided for @recapWhereItWent.
  ///
  /// In en, this message translates to:
  /// **'Where it went'**
  String get recapWhereItWent;

  /// No description provided for @recapTopCategory.
  ///
  /// In en, this message translates to:
  /// **'{category} took {percent}%'**
  String recapTopCategory(String category, int percent);

  /// No description provided for @recapBiggest.
  ///
  /// In en, this message translates to:
  /// **'The biggest expense'**
  String get recapBiggest;

  /// No description provided for @recapBiggestNote.
  ///
  /// In en, this message translates to:
  /// **'Recurring charges aside. It equals {percent}% of an average month of spending.'**
  String recapBiggestNote(int percent);

  /// No description provided for @recapRhythm.
  ///
  /// In en, this message translates to:
  /// **'Your rhythm'**
  String get recapRhythm;

  /// No description provided for @recapRhythmBody.
  ///
  /// In en, this message translates to:
  /// **'movements logged. {weekday} is your busiest day, with {count} movements.'**
  String recapRhythmBody(String weekday, int count);

  /// No description provided for @recapRecurring.
  ///
  /// In en, this message translates to:
  /// **'Your recurrences'**
  String get recapRecurring;

  /// No description provided for @recapRecurringHeadline.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 recurrence, {amount} this year} other{{count} recurrences, {amount} this year}}'**
  String recapRecurringHeadline(int count, String amount);

  /// No description provided for @recapRecurringShare.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of the year\'s expenses.'**
  String recapRecurringShare(int percent);

  /// No description provided for @recapTimes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 charge} other{{count} charges}}'**
  String recapTimes(int count);

  /// No description provided for @recapGoals.
  ///
  /// In en, this message translates to:
  /// **'Your goals'**
  String get recapGoals;

  /// No description provided for @recapGoalsHeadline.
  ///
  /// In en, this message translates to:
  /// **'{reached} of {total} reached'**
  String recapGoalsHeadline(int reached, int total);

  /// No description provided for @recapGoalReached.
  ///
  /// In en, this message translates to:
  /// **'Reached'**
  String get recapGoalReached;

  /// No description provided for @recapGoalOf.
  ///
  /// In en, this message translates to:
  /// **'{saved} of {target}'**
  String recapGoalOf(String saved, String target);

  /// No description provided for @recapBudgetKept.
  ///
  /// In en, this message translates to:
  /// **'Budget kept in {kept} of {months} months'**
  String recapBudgetKept(int kept, int months);

  /// No description provided for @recapBudgetsOnly.
  ///
  /// In en, this message translates to:
  /// **'Your budgets'**
  String get recapBudgetsOnly;

  /// No description provided for @recapComparedTo.
  ///
  /// In en, this message translates to:
  /// **'Compared with {year}'**
  String recapComparedTo(String year);

  /// No description provided for @recapSpentLess.
  ///
  /// In en, this message translates to:
  /// **'You spent {percent}% less'**
  String recapSpentLess(int percent);

  /// No description provided for @recapSpentMore.
  ///
  /// In en, this message translates to:
  /// **'You spent {percent}% more'**
  String recapSpentMore(int percent);

  /// No description provided for @recapSavingFromTo.
  ///
  /// In en, this message translates to:
  /// **'Savings from {from}% to {to}%'**
  String recapSavingFromTo(int from, int to);

  /// No description provided for @recapFirstYear.
  ///
  /// In en, this message translates to:
  /// **'Your first year'**
  String get recapFirstYear;

  /// No description provided for @recapStartedIn.
  ///
  /// In en, this message translates to:
  /// **'You started in {month} and kept going'**
  String recapStartedIn(String month);

  /// No description provided for @recapWholeYear.
  ///
  /// In en, this message translates to:
  /// **'A whole year of movements'**
  String get recapWholeYear;

  /// No description provided for @recapCategoriesUsed.
  ///
  /// In en, this message translates to:
  /// **'Categories used'**
  String get recapCategoriesUsed;

  /// No description provided for @recapSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get recapSaved;

  /// No description provided for @recapNextYear.
  ///
  /// In en, this message translates to:
  /// **'Next year you\'ll see the comparison with {year} here.'**
  String recapNextYear(String year);

  /// No description provided for @recapShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get recapShare;

  /// No description provided for @recapShareTitle.
  ///
  /// In en, this message translates to:
  /// **'Share your year'**
  String get recapShareTitle;

  /// No description provided for @recapShareImage.
  ///
  /// In en, this message translates to:
  /// **'Share image'**
  String get recapShareImage;

  /// No description provided for @recapCopyText.
  ///
  /// In en, this message translates to:
  /// **'Copy text'**
  String get recapCopyText;

  /// No description provided for @recapTextCopied.
  ///
  /// In en, this message translates to:
  /// **'Text copied'**
  String get recapTextCopied;

  /// No description provided for @recapHideAmounts.
  ///
  /// In en, this message translates to:
  /// **'Hide amounts'**
  String get recapHideAmounts;

  /// No description provided for @recapHideAmountsCaption.
  ///
  /// In en, this message translates to:
  /// **'Percentages only, no figures'**
  String get recapHideAmountsCaption;

  /// No description provided for @recapMyYear.
  ///
  /// In en, this message translates to:
  /// **'MY YEAR'**
  String get recapMyYear;

  /// No description provided for @recapSpentShort.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get recapSpentShort;

  /// No description provided for @recapTopCategoryShort.
  ///
  /// In en, this message translates to:
  /// **'Top category'**
  String get recapTopCategoryShort;

  /// No description provided for @recapVsYear.
  ///
  /// In en, this message translates to:
  /// **'{percent}% vs {year}'**
  String recapVsYear(String percent, String year);

  /// No description provided for @recapOfIncome.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of income'**
  String recapOfIncome(int percent);

  /// No description provided for @recapShareText.
  ///
  /// In en, this message translates to:
  /// **'My {year} with Pockets Vault: {spent} spent, {saved} saved.'**
  String recapShareText(String year, String spent, String saved);

  /// No description provided for @recapShareTextHidden.
  ///
  /// In en, this message translates to:
  /// **'My {year} with Pockets Vault: saved {percent}% of my income.'**
  String recapShareTextHidden(String year, int percent);

  /// No description provided for @recapShareTextPlain.
  ///
  /// In en, this message translates to:
  /// **'My {year} with Pockets Vault: {count} movements logged.'**
  String recapShareTextPlain(String year, int count);

  /// No description provided for @recapBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Your {year} in Pockets Vault'**
  String recapBannerTitle(String year);

  /// No description provided for @recapBannerBody.
  ///
  /// In en, this message translates to:
  /// **'Relive the year in {count} cards'**
  String recapBannerBody(int count);

  /// No description provided for @recapOpen.
  ///
  /// In en, this message translates to:
  /// **'{year} recap'**
  String recapOpen(String year);

  /// No description provided for @recapCardOf.
  ///
  /// In en, this message translates to:
  /// **'Card {index} of {total}'**
  String recapCardOf(int index, int total);

  /// No description provided for @recapNoData.
  ///
  /// In en, this message translates to:
  /// **'No movements this year.'**
  String get recapNoData;

  /// No description provided for @widgetAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get widgetAvailable;

  /// No description provided for @widgetIncomeSpent.
  ///
  /// In en, this message translates to:
  /// **'of income already spent'**
  String get widgetIncomeSpent;

  /// No description provided for @widgetNoIncome.
  ///
  /// In en, this message translates to:
  /// **'no income this month'**
  String get widgetNoIncome;
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
      <String>['en', 'es', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
