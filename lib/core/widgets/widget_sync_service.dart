import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../../features/transactions/domain/transaction.dart';
import '../../l10n/app_localizations.dart';
import '../currency/currency_metadata.dart';

/// Month summary shown by the home-screen widget, already formatted and
/// localized so the native side only lays it out.
class WidgetSnapshot {
  final String month;
  final String balanceLabel;
  final String balance;
  final bool balanceNegative;
  final String incomeLabel;
  final String income;
  final String expenseLabel;
  final String expense;
  final String addExpenseLabel;
  final String addIncomeLabel;
  final String receiptLabel;

  /// Small widget: month name, "Disponibile" as on Home (rounded) and the
  /// share of the month's income already spent, or -1 without income.
  final String monthName;
  final String availableLabel;
  final String available;
  final bool availableNegative;
  final int spentPercent;
  final String spentCaption;

  const WidgetSnapshot({
    required this.month,
    required this.balanceLabel,
    required this.balance,
    required this.balanceNegative,
    required this.incomeLabel,
    required this.income,
    required this.expenseLabel,
    required this.expense,
    required this.addExpenseLabel,
    required this.addIncomeLabel,
    required this.receiptLabel,
    required this.monthName,
    required this.availableLabel,
    required this.available,
    required this.availableNegative,
    required this.spentPercent,
    required this.spentCaption,
  });

  /// [availableMinor] is the Home "Disponibile" of the current month.
  factory WidgetSnapshot.build({
    required Iterable<TransactionModel> transactions,
    required String currencyCode,
    required AppLocalizations t,
    required String locale,
    required DateTime now,
    required int availableMinor,
  }) {
    var income = 0;
    var expense = 0;
    for (final tx in transactions) {
      if (tx.date.year != now.year || tx.date.month != now.month) continue;
      if (tx.isIncome) {
        income += tx.amountCents;
      } else {
        expense += tx.amountCents;
      }
    }
    final net = income - expense;
    String money(int minor) => formatMoney(minor, currencyCode, locale);
    final rounded = NumberFormat.simpleCurrency(
      locale: locale,
      name: currencyCode,
      decimalDigits: 0,
    ).format(minorToMajor(availableMinor.abs(), currencyCode));
    return WidgetSnapshot(
      month: toBeginningOfSentenceCase(
        DateFormat.yMMMM(locale).format(now),
        locale,
      ),
      balanceLabel: t.widgetMonthBalance,
      balance: '${net < 0 ? '−' : ''}${money(net.abs())}',
      balanceNegative: net < 0,
      incomeLabel: t.incomes,
      income: money(income),
      expenseLabel: t.expenses,
      expense: money(expense),
      addExpenseLabel: t.expense,
      addIncomeLabel: t.income,
      receiptLabel: t.widgetReceipt,
      monthName: toBeginningOfSentenceCase(
        DateFormat.MMMM(locale).format(now),
        locale,
      ),
      availableLabel: t.widgetAvailable,
      available: '${availableMinor < 0 ? '−' : ''}$rounded',
      availableNegative: availableMinor < 0,
      spentPercent: income <= 0 ? -1 : (expense * 100 / income).round(),
      spentCaption: income <= 0 ? t.widgetNoIncome : t.widgetIncomeSpent,
    );
  }

  Map<String, Object> toMap() => {
    'month': month,
    'balanceLabel': balanceLabel,
    'balance': balance,
    'balanceNegative': balanceNegative,
    'incomeLabel': incomeLabel,
    'income': income,
    'expenseLabel': expenseLabel,
    'expense': expense,
    'addExpenseLabel': addExpenseLabel,
    'addIncomeLabel': addIncomeLabel,
    'receiptLabel': receiptLabel,
    'monthName': monthName,
    'availableLabel': availableLabel,
    'available': available,
    'availableNegative': availableNegative,
    'spentPercent': spentPercent,
    'spentCaption': spentCaption,
  };
}

class WidgetSyncService {
  static const _channel = MethodChannel('pocket_vault/widget');

  Future<void> sync({
    required List<TransactionModel> transactions,
    required String currencyCode,
    required Locale locale,
    required int availableMinor,
  }) async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }
    // Sync can run before the app's localizations load the date symbols.
    await initializeDateFormatting(locale.toString());
    final snapshot = WidgetSnapshot.build(
      transactions: transactions,
      currencyCode: currencyCode,
      t: lookupAppLocalizations(locale),
      locale: locale.toString(),
      now: DateTime.now(),
      availableMinor: availableMinor,
    );
    try {
      await _channel.invokeMethod<void>('sync', snapshot.toMap());
    } on MissingPluginException {
      // No widget host in tests or on builds without the extension.
    } on PlatformException catch (error) {
      debugPrint('Widget sync failed: ${error.message}');
    }
  }
}
