// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Pockets Vault';

  @override
  String get addTransaction => 'Add transaction';

  @override
  String get saveTransaction => 'Save transaction';

  @override
  String get editTransaction => 'Edit transaction';

  @override
  String get amount => 'Amount';

  @override
  String get category => 'Category';

  @override
  String get selectCategory => 'Select category';

  @override
  String get date => 'Date';

  @override
  String get note => 'Note';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get incomes => 'Incomes';

  @override
  String get expenses => 'Expenses';

  @override
  String get transactionSaved => 'Transaction saved';

  @override
  String get recentTransactions => 'Recent transactions';

  @override
  String get noTransactions => 'No transactions';

  @override
  String get total => 'Total';

  @override
  String get month => 'Month';

  @override
  String get transactions => 'Transactions';

  @override
  String get stats => 'Statistics';

  @override
  String get settings => 'Settings';

  @override
  String get lfTransactions => 'Search transactions';

  @override
  String get newCategory => 'New category';

  @override
  String get nameCategory => 'Category name';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get expensesDistribution => 'Expenses distribution';

  @override
  String get noExpenses => 'No expenses';

  @override
  String get theme => 'Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get data => 'Data';

  @override
  String get cancelAll => 'Delete all data';

  @override
  String get categoryRemoved => 'Category removed';

  @override
  String get balance => 'Balance';

  @override
  String get removeTransactionQ => 'Delete transaction?';

  @override
  String get youSure => 'This action cannot be undone.';

  @override
  String get delete => 'Delete';

  @override
  String get transactionDeleted => 'Transaction deleted';

  @override
  String get confirm => 'Confirm';

  @override
  String get deleteAllQ => 'Are you sure you want to delete all saved data?';

  @override
  String get salary => 'Salary';

  @override
  String get bonus => 'Bonus';

  @override
  String get gift => 'Gift';

  @override
  String get food => 'Food';

  @override
  String get groceries => 'Groceries';

  @override
  String get transport => 'Transport';

  @override
  String get rent => 'Rent';

  @override
  String get bills => 'Bills';

  @override
  String get shopping => 'Shopping';

  @override
  String get health => 'Health';

  @override
  String get entertainment => 'Entertainment';

  @override
  String get travel => 'Travel';

  @override
  String get education => 'Education';

  @override
  String get otherCategory => 'Other';

  @override
  String get recurrents => 'Recurring';

  @override
  String get security => 'Security';

  @override
  String get everyMonth => 'Every month';

  @override
  String get active => 'Active';

  @override
  String get modify => 'Edit';

  @override
  String get pause => 'Pause';

  @override
  String get recurrent => 'Recurring';

  @override
  String get recurrentMsg => 'Enable to repeat every month';

  @override
  String get color => 'Color';

  @override
  String get day => 'Day';

  @override
  String get modifyRecurrent => 'Edit recurring transaction';

  @override
  String get modifyCategory => 'Edit category';

  @override
  String get noRecurrent => 'No recurring transactions';

  @override
  String get reactivate => 'Reactivate';

  @override
  String get reactivateMsg => 'Recurring transaction reactivated';

  @override
  String get reactivatePauseMsg => 'Recurring transaction paused';

  @override
  String get dayOfMonth => 'Day of the month';

  @override
  String get save => 'Save';

  @override
  String get recurringCreationMsg => 'Recurring transaction created ';

  @override
  String get deleteMovement => 'Delete transaction?';

  @override
  String get deleteMovementSure => 'This action cannot be undone';

  @override
  String get deletedMovement => 'Transaction deleted';

  @override
  String get addExpenseToViewGraph => 'Add an expense to view the chart';

  @override
  String get selectYear => 'Select year';

  @override
  String get existingCategory => 'Category already exists';

  @override
  String get saveCategory => 'Save category';

  @override
  String get canceledAll => 'All data has been deleted';

  @override
  String get searchBar => 'Search transaction';

  @override
  String get paused => 'Paused';

  @override
  String savedMore(Object value) {
    return 'You spent $value% less than last month';
  }

  @override
  String spentMore(Object value) {
    return 'You spent $value% more than last month';
  }

  @override
  String get period => 'Period';

  @override
  String get selectPeriod => 'Select period';

  @override
  String get allCategories => 'All categories';

  @override
  String get mostUsedCategories => 'Most used categories';

  @override
  String get otherCategories => 'Other';

  @override
  String get deleteCategory => 'Delete category';

  @override
  String get deleteCategoryConfirm => 'Are you sure you want to delete this category?';

  @override
  String get createPin => 'Create PIN';

  @override
  String get confirmPin => 'Confirm PIN';

  @override
  String get enterPin => 'Enter PIN';

  @override
  String get enableBiometrics => 'Enable biometric unlock';

  @override
  String get enableBiometricsMessage => 'Use Face ID or your fingerprint to unlock Pockets Vault?';

  @override
  String get notNow => 'Not now';

  @override
  String get enable => 'Enable';

  @override
  String get biometricUnlock => 'Biometric unlock';

  @override
  String get deleteDigit => 'Delete digit';

  @override
  String get clearPin => 'Clear PIN';

  @override
  String get home => 'Home';

  @override
  String get systemTheme => 'System';

  @override
  String get mainCurrency => 'Main currency';

  @override
  String get updateRates => 'Refresh rates';

  @override
  String get automaticLock => 'Automatic lock';

  @override
  String get backupPortability => 'Backup and portability';

  @override
  String get encryptedBackupCaption => 'AES-256 encryption, CSV export and local restore';

  @override
  String get exportEncryptedBackup => 'Export encrypted backup';

  @override
  String get exportTransactionsCsv => 'Export transactions as CSV';

  @override
  String get importBackup => 'Import backup';

  @override
  String get safeMergeOrReplace => 'Safe merge or complete replacement';

  @override
  String get localSmartRules => 'Local smart rules';

  @override
  String get privateCategorization => 'Private categorization without sending data';

  @override
  String get noRules => 'No rules';

  @override
  String get noRulesHint => 'You can remember one while adding a transaction.';

  @override
  String get availableToSpend => 'Available to spend';

  @override
  String get budgets => 'Budgets';

  @override
  String get optionalMonthlyBudgets => 'Optional monthly budgets, editable at any time';

  @override
  String get noBudget => 'No budget';

  @override
  String get forecast90Days => '90-day forecast';

  @override
  String get noForecastMovements => 'No recurring transactions forecast.';

  @override
  String get savingsGoals => 'Savings goals';

  @override
  String get manage => 'Manage';

  @override
  String get createGoalHint => 'Create a goal and track your progress.';

  @override
  String get newGoal => 'New goal';

  @override
  String get noGoals => 'No goals';

  @override
  String get rememberCategory => 'Remember this category';

  @override
  String get rememberCategoryHint => 'Suggest it for similar descriptions, only on this device.';

  @override
  String get addReceipt => 'Add receipt';

  @override
  String get receiptAttached => 'Receipt attached';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get chooseLibrary => 'Choose from library';

  @override
  String get repeatEvery => 'Repeat every';

  @override
  String get endDate => 'End date';

  @override
  String get none => 'None';

  @override
  String get undo => 'Undo';

  @override
  String get recurrenceDeleted => 'Recurrence deleted';

  @override
  String get availableThisMonth => 'Available this month';

  @override
  String get availableAllTime => 'Overall available';

  @override
  String get availableForPeriod => 'Available in period';

  @override
  String get availableFormula => 'Income − expenses − reserved savings − scheduled recurring payments';

  @override
  String get reservedSavings => 'Reserved';

  @override
  String get scheduledUpcoming => 'Upcoming transactions';

  @override
  String get categoryLimits => 'Category limits';

  @override
  String activeBudgets(Object count) {
    return '$count active';
  }

  @override
  String remainingBudget(Object amount) {
    return '$amount remaining';
  }

  @override
  String budgetExceededBy(Object amount) {
    return 'Exceeded by $amount';
  }

  @override
  String get setOptionalLimit => 'Set an optional limit';

  @override
  String budgetForCategory(Object category) {
    return 'Monthly budget · $category';
  }

  @override
  String amountInCurrency(Object currency) {
    return 'Amount in $currency';
  }

  @override
  String get enterPositiveAmount => 'Enter an amount greater than zero.';

  @override
  String get budgetDeleted => 'Budget deleted';

  @override
  String get budgetPeriodHint => 'Monthly limits are prorated to the selected interval.';

  @override
  String get forecastRecurring => 'Recurring forecast';

  @override
  String get forecastExplanation => 'Estimate from the current balance using scheduled recurring transactions only.';

  @override
  String get currentBalance => 'Current balance';

  @override
  String forecastAfter(Object duration) {
    return 'In $duration';
  }

  @override
  String recurringIncluded(Object count) {
    return '$count recurring transactions included in the calculation.';
  }

  @override
  String get oneMonth => '1 month';

  @override
  String monthsCount(Object count) {
    return '$count months';
  }

  @override
  String get oneYear => '1 year';

  @override
  String yearsCount(Object count) {
    return '$count years';
  }

  @override
  String get savingsReservedHint => 'Reserved amounts reduce what is available to spend, while remaining part of your balance.';

  @override
  String allocatedInSelection(Object amount) {
    return 'Reserved in this period: $amount';
  }

  @override
  String get reserveFunds => 'Reserve';

  @override
  String get releaseFunds => 'Release funds';

  @override
  String get addSavings => 'Add savings';

  @override
  String get releaseSavings => 'Release savings';

  @override
  String get goalName => 'Name';

  @override
  String goalTarget(Object name) {
    return 'Goal · $name';
  }

  @override
  String get deleteGoal => 'Delete this goal?';

  @override
  String get deleteGoalReleasesFunds => 'Reserved funds will become available again. History is preserved and transactions are not changed.';

  @override
  String get goalDeleted => 'Goal deleted';

  @override
  String maximumAmount(Object amount) {
    return 'Maximum $amount';
  }

  @override
  String get receiptOptional => 'Optional receipt';

  @override
  String get receiptPurpose => 'Reads amount, date, merchant and category directly on your device.';

  @override
  String get receiptStoredLocally => 'Private on-device scan, with review before saving.';

  @override
  String get receiptLinked => 'Attached to this transaction';

  @override
  String get receiptPermissionDenied => 'Permission denied. Enable photos and camera in Settings.';

  @override
  String get cameraUnavailable => 'Camera unavailable on this device.';

  @override
  String get libraryUnavailable => 'Photo library unavailable on this device.';

  @override
  String get receiptAttachFailed => 'Unable to attach the receipt.';

  @override
  String convertedToMainCurrency(Object amount) {
    return '≈ $amount in the main currency';
  }

  @override
  String get conversionOnSave => 'The exchange rate will be calculated when saving.';

  @override
  String get ecbRefreshNeeded => 'ECB conversion · update required';

  @override
  String ecbRatesDate(Object date) {
    return 'ECB rates from $date';
  }

  @override
  String get rateApp => 'Rate app';

  @override
  String get shareApp => 'Share app';

  @override
  String get protectBackup => 'Protect backup';

  @override
  String get unlockBackup => 'Unlock backup';

  @override
  String get continueAction => 'Continue';

  @override
  String get exportCanceled => 'Export canceled.';

  @override
  String get backupReady => 'Backup ready to save or share.';

  @override
  String get csvReady => 'CSV ready to save or share.';

  @override
  String get importMode => 'Import mode';

  @override
  String get importModeExplanation => 'Merge keeps current data and updates items with the same identifier. Replace first deletes all local financial data.';

  @override
  String get merge => 'Merge';

  @override
  String get replace => 'Replace';

  @override
  String get backupRestored => 'Backup restored successfully.';

  @override
  String get minimumPassword => 'Use at least 8 characters.';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match.';

  @override
  String get minimumEightCharacters => 'At least 8 characters';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get changeCurrency => 'Change currency';

  @override
  String recursEvery(Object frequency, Object interval) {
    return 'Every $interval $frequency';
  }

  @override
  String get savingsUpdateFailed => 'Unable to update the savings goal.';

  @override
  String get hideAmounts => 'Hide amounts';

  @override
  String get showAmounts => 'Show amounts';

  @override
  String get scanReceipt => 'Scan receipt';

  @override
  String get receiptScanHint => 'Take or choose a receipt photo to fill the expense automatically.';

  @override
  String get scanWithCamera => 'Scan with camera';

  @override
  String get scanFromLibrary => 'Scan a photo';

  @override
  String get cameraFlash => 'Flash';

  @override
  String get receiptScanReview => 'Review scan';

  @override
  String get receiptScanCheckData => 'We found these details. Review and edit them before continuing.';

  @override
  String get receiptScanNoData => 'We could not read reliable details. Enter them manually or attach the photo only.';

  @override
  String get receiptMerchant => 'Merchant';

  @override
  String get receiptScanPrivate => 'OCR and analysis happen entirely on this device.';

  @override
  String get attachOnly => 'Attach only';

  @override
  String get useDetectedData => 'Use details';

  @override
  String get receiptScanApplied => 'Receipt details applied. Review and save the transaction.';

  @override
  String get receiptScanning => 'Analyzing receipt…';

  @override
  String get dataTemporarilyUnavailable => 'Data temporarily unavailable.';

  @override
  String get retry => 'Try again';

  @override
  String get yourMonth => 'Your month';

  @override
  String get byCategory => 'By category';

  @override
  String get statsOverview => 'Overview';

  @override
  String get statsCategories => 'Categories';

  @override
  String get statsComparisons => 'Compare';

  @override
  String get statsTrend => 'Cumulative trend';

  @override
  String get statsBreakdown => 'Where your money goes';

  @override
  String get statsWhatChanged => 'What changed';

  @override
  String get statsChangeDrivers => 'What explains the change';

  @override
  String get statsPreviousMonth => 'Previous month';

  @override
  String get statsChooseMonth => 'Choose a month';

  @override
  String get statsYearAverage => 'Average of earlier months this year';

  @override
  String get statsCompareWith => 'Compare with';

  @override
  String get statsComparisonPeriod => 'Comparison period';

  @override
  String get statsPrimaryMonth => 'Month to analyse';

  @override
  String get statsReferenceMonth => 'Reference month';

  @override
  String get statsElapsedDays => 'Align elapsed days';

  @override
  String get statsElapsedHint => 'For the current month, compare the same days in each reference month.';

  @override
  String statsThroughDay(int day) {
    return 'Days 1–$day in each month';
  }

  @override
  String get statsWholeMonths => 'Entire selected months';

  @override
  String statsAverageBasis(int count) {
    return 'Average of $count months, including months with no transactions.';
  }

  @override
  String get statsNoEarlierMonths => 'January has no earlier months in the same year. Choose a different comparison.';

  @override
  String get statsZeroReference => 'Percentage unavailable: the reference amount is zero.';

  @override
  String get statsNet => 'Income − expenses';

  @override
  String get statsShowTransactions => 'View transactions';

  @override
  String get statsDragHint => 'Drag across the chart to explore';

  @override
  String get statsForecastToday => 'Recurring forecast from today';

  @override
  String get statsCompareHint => 'Choose the months to compare here.';

  @override
  String get statsRecordedOnly => 'Recorded transactions';

  @override
  String get statsMonthTitle => 'Select month';

  @override
  String get statsCategoryChange => 'Change by category';

  @override
  String get statsCurrent => 'Selected month';

  @override
  String get statsReference => 'Reference';

  @override
  String get statsHiddenChart => 'Chart hidden while amount privacy is enabled.';

  @override
  String get statsAllTime => 'All recorded dates';

  @override
  String get statsComparisonUnavailable => 'No reference period';

  @override
  String statsTransactionCount(int count) {
    return '$count transactions';
  }

  @override
  String statsPercentage(String value) {
    return '$value%';
  }

  @override
  String statsVersus(String period) {
    return 'Compared with $period';
  }

  @override
  String get statsAverageLabel => 'Average';

  @override
  String get statsMonthlyExpenses => 'Monthly spending';

  @override
  String get statsMonthlyIncome => 'Monthly income';

  @override
  String get statsPeriodExpenses => 'Period spending';

  @override
  String get statsPeriodIncome => 'Period income';

  @override
  String get statsTotalExpenses => 'Total spending';

  @override
  String get statsTotalIncome => 'Total income';

  @override
  String get statsPreviousPeriod => 'previous period';

  @override
  String statsRangeCaption(Object period) {
    return 'Comparison: $period';
  }

  @override
  String statsSpentLess(Object amount) {
    return '$amount less spent';
  }

  @override
  String statsSpentMore(Object amount) {
    return '$amount more spent';
  }

  @override
  String statsIncomeLess(Object amount) {
    return '$amount less income';
  }

  @override
  String statsIncomeMore(Object amount) {
    return '$amount more income';
  }

  @override
  String statsMainVariation(Object category) {
    return '$category is the main change';
  }

  @override
  String statsExplainsDrop(Object category) {
    return '$category explains the decrease';
  }

  @override
  String statsExplainsRise(Object category) {
    return '$category explains the increase';
  }

  @override
  String get statsOpenCategoryHint => 'Open the category to see transactions';

  @override
  String statsExpenseVersus(Object period) {
    return 'in spending compared with $period';
  }

  @override
  String statsIncomeVersus(Object period) {
    return 'in income compared with $period';
  }
}
