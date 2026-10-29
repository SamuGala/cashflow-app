import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_vault/app/theme/app_theme.dart';
import 'package:pocket_vault/core/database/app_database.dart';
import 'package:pocket_vault/core/database/database_provider.dart';
import 'package:pocket_vault/features/transactions/domain/quick_suggestions.dart';
import 'package:pocket_vault/features/transactions/domain/transaction.dart';
import 'package:pocket_vault/features/transactions/presentation/quick_add_transaction_sheet.dart';
import 'package:pocket_vault/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final now = DateTime(2026, 10, 29, 12);

  TransactionModel row(
    String id,
    String category,
    int amount, {
    String? note,
    int daysAgo = 1,
    bool income = false,
    String? recurringSourceId,
    String currency = 'EUR',
  }) => TransactionModel(
    id: id,
    amountCents: amount,
    isIncome: income,
    categoryId: category,
    date: now.subtract(Duration(days: daysAgo)),
    note: note,
    originalCurrency: currency,
    recurringSourceId: recurringSourceId,
  );

  group('quickSuggestions', () {
    test('ranks repeated movements by frequency and recency', () {
      final result = quickSuggestions(
        [
          for (var i = 0; i < 4; i++)
            row(
              's$i',
              'groceries',
              6840,
              note: 'Esselunga',
              daysAgo: 7 * i + 1,
            ),
          row('b1', 'transport', 3500, note: 'Bus', daysAgo: 2),
          row('b2', 'transport', 3500, note: 'bus ', daysAgo: 32),
          row('c1', 'food', 250, note: 'Caffè', daysAgo: 3),
        ],
        isIncome: false,
        now: now,
      );
      expect(result.map((s) => s.note), ['Esselunga', 'Bus']);
      expect(result.first.count, 4);
      expect(result.first.amountMinor, 6840);
      // The latest spelling of the note is kept.
      expect(result.last.note, 'Bus');
    });

    test('ignores single, old, future, income and recurring movements', () {
      final result = quickSuggestions(
        [
          row('a1', 'food', 900, note: 'Pranzo', daysAgo: 200),
          row('a2', 'food', 900, note: 'Pranzo', daysAgo: 210),
          row('f1', 'food', 900, note: 'Futuro', daysAgo: -3),
          row('f2', 'food', 900, note: 'Futuro', daysAgo: -10),
          row('i1', 'salary', 150000, income: true),
          row('i2', 'salary', 150000, income: true, daysAgo: 30),
          row('r1', 'bills', 1399, recurringSourceId: 'netflix'),
          row('r2', 'bills', 1399, recurringSourceId: 'netflix', daysAgo: 30),
        ],
        isIncome: false,
        now: now,
      );
      expect(result, isEmpty);
      expect(
        quickSuggestions(
          [
            row('i1', 'salary', 150000, income: true),
            row('i2', 'salary', 150000, income: true, daysAgo: 30),
          ],
          isIncome: true,
          now: now,
        ).single.categoryId,
        'salary',
      );
    });

    test('amount and currency are part of the identity, at most three', () {
      final result = quickSuggestions(
        [
          for (final (i, amount) in [100, 200, 300, 400].indexed) ...[
            row('x$i', 'food', amount, note: 'Bar'),
            row('y$i', 'food', amount, note: 'Bar', daysAgo: 2),
          ],
          row('u1', 'food', 100, note: 'Bar', currency: 'USD'),
        ],
        isIncome: false,
        now: now,
      );
      expect(result, hasLength(3));
      expect(result.map((s) => s.currency).toSet(), {'EUR'});
    });
  });

  group('quick add suggestions', () {
    late AppDatabase database;

    Future<void> pumpSheet(WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final today = DateTime.now();
      SharedPreferences.setMockInitialValues({
        'base_currency_v1': 'EUR',
        'currency_rates_ecb_v1': jsonEncode({
          'rates': {'EUR': 1.0},
          'publishedAt': today.toIso8601String(),
          'fetchedAt': today.toIso8601String(),
        }),
      });
      database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      for (var i = 0; i < 3; i++) {
        await database.insertTransaction(
          TransactionsCompanion.insert(
            id: 'g$i',
            categoryId: 'groceries',
            amountCents: 6840,
            isIncome: false,
            date: today.subtract(Duration(days: 7 * i + 1)),
            note: const Value('Esselunga'),
          ),
        );
      }
      for (var i = 0; i < 2; i++) {
        await database.insertTransaction(
          TransactionsCompanion.insert(
            id: 's$i',
            categoryId: 'salary',
            amountCents: 210000,
            isIncome: true,
            date: today.subtract(Duration(days: 30 * i + 2)),
            note: const Value('Stipendio'),
          ),
        );
      }
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(database)],
          child: MaterialApp(
            locale: const Locale('it'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: AppTheme.lightTheme,
            home: const Scaffold(body: QuickAddTransactionSheet()),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    Finder chip(int index) => find.byKey(ValueKey('quick-suggestion-$index'));

    testWidgets('one tap fills amount, category and note, then saves', (
      tester,
    ) async {
      await pumpSheet(tester);
      expect(find.text('Suggeriti'), findsOneWidget);
      expect(
        find.descendant(of: chip(0), matching: find.text('Esselunga')),
        findsOneWidget,
      );
      await tester.tap(chip(0));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('quick-note')),
          matching: find.text('Esselunga'),
        ),
        findsOneWidget,
      );
      // Still visible so the user can switch, until the amount is retyped.
      expect(chip(0), findsOneWidget);
      await tester.ensureVisible(find.byKey(const ValueKey('quick-save')));
      await tester.tap(find.byKey(const ValueKey('quick-save')));
      await tester.pumpAndSettle();
      final rows = await database.getAllTransactions();
      final added = rows.singleWhere(
        (r) => !r.id.startsWith(RegExp('[gs]\\d')),
      );
      expect(added.categoryId, 'groceries');
      expect(added.amountCents, 6840);
      expect(added.note, 'Esselunga');
      expect(tester.takeException(), isNull);
    });

    testWidgets('typing hides them; the income flow offers its own', (
      tester,
    ) async {
      await pumpSheet(tester);
      await tester.tap(find.byKey(const ValueKey('quick-amount-key-5')));
      await tester.pumpAndSettle();
      expect(find.text('Suggeriti'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('quick-amount-backspace')));
      await tester.pumpAndSettle();
      expect(find.text('Suggeriti'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('flow-switch-income')));
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: chip(0), matching: find.text('Stipendio')),
        findsOneWidget,
      );
      expect(find.text('Esselunga'), findsNothing);
      await tester.tap(chip(0));
      await tester.pumpAndSettle();
      // Switching flow drops a suggestion that was applied.
      await tester.tap(find.byKey(const ValueKey('flow-switch-expense')));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('quick-note')),
          matching: find.text('Stipendio'),
        ),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
