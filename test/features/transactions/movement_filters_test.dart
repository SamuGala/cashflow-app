import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_vault/app/theme/app_theme.dart';
import 'package:pocket_vault/core/database/app_database.dart';
import 'package:pocket_vault/core/database/database_provider.dart';
import 'package:pocket_vault/core/providers/balance_visibility_provider.dart';
import 'package:pocket_vault/core/providers/time_filter_provider.dart';
import 'package:pocket_vault/features/transactions/domain/movement_filters.dart';
import 'package:pocket_vault/features/transactions/domain/transaction.dart';
import 'package:pocket_vault/features/transactions/presentation/transactions_page.dart';
import 'package:pocket_vault/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TransactionModel tx(
    String category,
    int amount, {
    bool income = false,
    String currency = 'EUR',
    String? receipt,
  }) => TransactionModel(
    id: '$category-$amount',
    amountCents: amount,
    isIncome: income,
    categoryId: category,
    date: DateTime(2026, 3, 3),
    originalCurrency: currency,
    receiptPath: receipt,
  );

  group('MovementFilters.matches', () {
    final rows = [
      tx('food', 3250),
      tx('food', 900, receipt: '/r.jpg'),
      tx('transport', 1500, currency: 'USD'),
      tx('salary', 250000, income: true),
    ];
    List<String> ids(MovementFilters f) => [
      for (final row in rows.where(f.matches)) row.id,
    ];

    test('no filters keep everything', () {
      expect(ids(MovementFilters.none), hasLength(4));
      expect(MovementFilters.none.activeCount, 0);
    });

    test('each filter narrows, and they combine', () {
      expect(ids(const MovementFilters(flow: FlowFilter.income)), [
        'salary-250000',
      ]);
      expect(ids(const MovementFilters(categoryIds: {'food'})), [
        'food-3250',
        'food-900',
      ]);
      expect(ids(const MovementFilters(minAmount: 1000, maxAmount: 5000)), [
        'food-3250',
        'transport-1500',
      ]);
      expect(ids(const MovementFilters(currencies: {'USD'})), [
        'transport-1500',
      ]);
      expect(ids(const MovementFilters(receipt: ReceiptFilter.withReceipt)), [
        'food-900',
      ]);
      const combined = MovementFilters(
        flow: FlowFilter.expense,
        categoryIds: {'food'},
        receipt: ReceiptFilter.withoutReceipt,
      );
      expect(ids(combined), ['food-3250']);
      expect(combined.activeCount, 3);
      expect(combined.copyWith(categoryIds: const {}).activeCount, 2);
      expect(
        const MovementFilters(minAmount: 1).withoutAmount().isEmpty,
        isTrue,
      );
    });
  });

  group('Movements filter panel', () {
    final month = DateTime(2026, 3);
    late AppDatabase database;
    late ProviderContainer container;

    setUp(() async {
      final now = DateTime.now();
      SharedPreferences.setMockInitialValues({
        'base_currency_v1': 'EUR',
        'currency_rates_ecb_v1': jsonEncode({
          'rates': {'EUR': 1.0, 'USD': 1.1},
          'publishedAt': now.toIso8601String(),
          'fetchedAt': now.toIso8601String(),
        }),
      });
      database = AppDatabase.forTesting(NativeDatabase.memory());
      for (final entry in [
        ('salary', 'salary', 250000, true, null, null),
        ('pizza', 'food', 3250, false, null, 'Pizza'),
        ('coffee', 'food', 250, false, null, 'Caffè'),
        ('bus', 'transport', 1500, false, 'USD', 'Bus'),
      ]) {
        await database.insertTransaction(
          TransactionsCompanion.insert(
            id: entry.$1,
            categoryId: entry.$2,
            amountCents: entry.$3,
            isIncome: entry.$4,
            date: DateTime(month.year, month.month, 3, 12),
            originalCurrency: Value(entry.$5),
            originalAmountMinor: Value(entry.$5 == null ? null : 1650),
            note: Value(entry.$6),
          ),
        );
      }
      container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(database)],
      );
      container.read(timeFilterProvider.notifier).setMonth(month);
      container.read(balanceVisibilityProvider.notifier).show();
    });

    tearDown(() async {
      container.dispose();
      await database.close();
    });

    Future<void> pump(WidgetTester tester, {bool dark = false}) async {
      tester.view.physicalSize = const Size(390, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            locale: const Locale('it'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
            home: const TransactionsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    Finder byKey(String key) => find.byKey(ValueKey(key));
    // Movement rows shown in the list (each is a Dismissible).
    int rows() => find.byType(Dismissible).evaluate().length;

    testWidgets('live count, chips, removal and clear on empty results', (
      tester,
    ) async {
      await pump(tester);
      expect(rows(), 4);
      await tester.tap(byKey('movements-filter-button'));
      await tester.pumpAndSettle();
      expect(find.text('Mostra 4 movimenti'), findsOneWidget);
      // Currency appears because the period mixes EUR and USD.
      expect(byKey('filter-currency-USD'), findsOneWidget);

      await tester.tap(byKey('filter-flow-1')); // Uscite
      await tester.pumpAndSettle();
      expect(find.text('Mostra 3 movimenti'), findsOneWidget);
      // Income categories disappear with the expense flow.
      expect(byKey('filter-category-salary'), findsNothing);
      await tester.tap(byKey('filter-category-food'));
      await tester.pumpAndSettle();
      expect(find.text('Mostra 2 movimenti'), findsOneWidget);
      await tester.tap(byKey('filter-apply'));
      await tester.pumpAndSettle();

      expect(rows(), 2);
      expect(find.text('Pizza'), findsOneWidget);
      expect(find.text('Bus'), findsNothing);
      expect(
        find.descendant(
          of: byKey('movements-filter-count'),
          matching: find.text('2'),
        ),
        findsOneWidget,
      );
      expect(byKey('movement-filter-chip-flow'), findsOneWidget);
      expect(
        find.descendant(
          of: byKey('movement-filter-chip-categories'),
          matching: find.text('Cibo'),
        ),
        findsOneWidget,
      );

      // Removing the category chip widens back to every expense.
      await tester.tap(byKey('movement-filter-chip-categories'));
      await tester.pumpAndSettle();
      expect(rows(), 3);

      // A search plus filters with no match offers to clear the filters.
      await tester.enterText(find.byType(TextField), 'stipendio');
      await tester.pumpAndSettle();
      expect(find.text('Nessun movimento con questi filtri.'), findsOneWidget);
      await tester.tap(byKey('movement-filters-clear'));
      await tester.pumpAndSettle();
      expect(byKey('movement-filter-chip-flow'), findsNothing);
      expect(rows(), 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('receipt and currency filters, reset, dark theme', (
      tester,
    ) async {
      await pump(tester, dark: true);
      await tester.tap(byKey('movements-filter-button'));
      await tester.pumpAndSettle();
      await tester.tap(byKey('filter-currency-USD'));
      await tester.pumpAndSettle();
      expect(find.text('Mostra 1 movimento'), findsOneWidget);
      await tester.ensureVisible(byKey('filter-receipt-1'));
      await tester.tap(byKey('filter-receipt-1')); // Con ricevuta
      await tester.pumpAndSettle();
      expect(find.text('Nessun movimento'), findsOneWidget);
      await tester.tap(byKey('filter-reset'));
      await tester.pumpAndSettle();
      expect(find.text('Mostra 4 movimenti'), findsOneWidget);
      // Dragging the amount range narrows the count.
      final slider = byKey('filter-amount');
      await tester.ensureVisible(slider);
      final rect = tester.getRect(slider);
      await tester.dragFrom(
        Offset(rect.right - 26, rect.center.dy),
        Offset(-rect.width * .9, 0),
      );
      await tester.pumpAndSettle();
      expect(find.text('Mostra 4 movimenti'), findsNothing);
      await tester.tap(byKey('filter-apply'));
      await tester.pumpAndSettle();
      expect(byKey('movement-filter-chip-amount'), findsOneWidget);
      expect(find.text('Stipendio'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
