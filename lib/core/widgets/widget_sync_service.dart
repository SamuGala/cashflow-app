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
  });

  factory WidgetSnapshot.build({
    required Iterable<TransactionModel> transactions,
    required String currencyCode,
    required AppLocalizations t,
    required String locale,
    required DateTime now,
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
  };
}

class WidgetSyncService {
  static const _channel = MethodChannel('pocket_vault/widget');

  Future<void> sync({
    required List<TransactionModel> transactions,
    required String currencyCode,
    required Locale locale,
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
