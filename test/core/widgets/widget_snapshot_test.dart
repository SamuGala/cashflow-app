import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pocket_vault/core/widgets/widget_sync_service.dart';
import 'package:pocket_vault/features/transactions/domain/transaction.dart';
import 'package:pocket_vault/l10n/app_localizations.dart';

void main() {
  final now = DateTime(2026, 10, 15);
  final t = lookupAppLocalizations(const Locale('it'));
  setUpAll(() => initializeDateFormatting('it'));

  TransactionModel tx(int amount, {bool income = false, int month = 10}) =>
      TransactionModel(
        id: '$amount-$income-$month',
        amountCents: amount,
        isIncome: income,
        categoryId: income ? 'salary' : 'food',
        date: DateTime(2026, month, 3),
      );

  WidgetSnapshot build(List<TransactionModel> rows, int available) =>
      WidgetSnapshot.build(
        transactions: rows,
        currencyCode: 'EUR',
        t: t,
        locale: 'it',
        now: now,
        availableMinor: available,
      );

  test(
    'small widget: month, rounded Disponibile and share of income spent',
    () {
      final snapshot = build([
        tx(200000, income: true),
        tx(92000),
        tx(50000, month: 9), // last month: ignored
      ], 83301);
      expect(snapshot.monthName, 'Ottobre');
      expect(snapshot.availableLabel, 'Disponibile');
      expect(snapshot.available, '833 €');
      expect(snapshot.availableNegative, isFalse);
      expect(snapshot.spentPercent, 46);
      expect(snapshot.spentCaption, 'delle entrate già spese');
      expect(snapshot.toMap()['spentPercent'], 46);
    },
  );

  test('negative Disponibile and a month without income', () {
    final snapshot = build([tx(4000)], -12050);
    expect(snapshot.available, '−121 €');
    expect(snapshot.availableNegative, isTrue);
    expect(snapshot.spentPercent, -1);
    expect(snapshot.spentCaption, 'nessuna entrata nel mese');
  });
}
