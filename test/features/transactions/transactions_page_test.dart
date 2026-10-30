import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_vault/app/theme/app_theme.dart';
import 'package:pocket_vault/core/currency/currency_metadata.dart';
import 'package:pocket_vault/core/database/app_database.dart';
import 'package:pocket_vault/core/database/database_provider.dart';
import 'package:pocket_vault/core/providers/balance_visibility_provider.dart';
import 'package:pocket_vault/core/providers/time_filter_provider.dart';
import 'package:pocket_vault/features/dashboard/presentation/dashboard_page.dart';
import 'package:pocket_vault/features/transactions/presentation/add_transaction_page.dart';
import 'package:pocket_vault/features/transactions/presentation/transactions_page.dart';
import 'package:pocket_vault/features/transactions/providers/transaction_provider.dart';
import 'package:pocket_vault/l10n/app_localizations.dart';
import 'package:pocket_vault/shared/widgets/vault_style.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<(AppDatabase, ProviderContainer)> seed(DateTime month) async {
  final now = DateTime.now();
  SharedPreferences.setMockInitialValues({
    'base_currency_v1': 'EUR',
    'currency_rates_ecb_v1': jsonEncode({
      'rates': {'EUR': 1.0},
      'publishedAt': now.toIso8601String(),
      'fetchedAt': now.toIso8601String(),
    }),
  });
  final database = AppDatabase.forTesting(NativeDatabase.memory());
  for (final entry in [
    ('salary', 'salary', 250000, true, 1),
    ('pizza', 'food', 3250, false, 3),
    ('bus', 'transport', 1500, false, 3),
  ]) {
    await database.insertTransaction(
      TransactionsCompanion.insert(
        id: entry.$1,
        categoryId: entry.$2,
        amountCents: entry.$3,
        isIncome: entry.$4,
        date: DateTime(month.year, month.month, entry.$5, 12),
      ),
    );
  }
  final container = ProviderContainer(
    overrides: [databaseProvider.overrideWithValue(database)],
  );
  container.read(timeFilterProvider.notifier).setMonth(month);
  container.read(balanceVisibilityProvider.notifier).show();
  return (database, container);
}

Widget app(ProviderContainer container, Widget home, {bool dark = false}) =>
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: const Locale('it'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
        home: home,
      ),
    );

String eur(int minor) => formatMoney(minor, 'EUR', 'it');

void main() {
  final month = DateTime(2026, 3);

  testWidgets('movement list, swipe delete with confirmation and undo', (
    tester,
  ) async {
    final (database, container) = await seed(month);
    addTearDown(() async {
      container.dispose();
      await database.close();
    });
    await tester.pumpWidget(app(container, const TransactionsPage()));
    await tester.pumpAndSettle();

    // No totals card any more: the list starts with the first day.
    expect(find.byKey(const ValueKey('movements-income-total')), findsNothing);
    for (final id in ['salary', 'pizza', 'bus']) {
      expect(find.byKey(ValueKey(id)), findsOneWidget);
    }

    // Expense amounts keep the shared semantic red.
    final context = tester.element(find.byType(TransactionsPage));
    final pizzaAmount = tester.widget<Text>(find.text('−${eur(3250)}'));
    expect(pizzaAmount.style?.color, VaultColors.expense(context));

    await tester.drag(
      find.byKey(const ValueKey('pizza')),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();
    expect(find.text('Eliminare il movimento?'), findsOneWidget);
    await tester.tap(find.text('Elimina'));
    await tester.pumpAndSettle();
    expect(
      (await database.getAllTransactions()).map((row) => row.id),
      isNot(contains('pizza')),
    );
    expect(find.byKey(const ValueKey('pizza')), findsNothing);

    await tester.tap(find.text('Annulla'));
    await tester.pumpAndSettle();
    expect(
      (await database.getAllTransactions()).map((row) => row.id),
      contains('pizza'),
    );

    // Cancelling the confirmation keeps the row.
    await tester.drag(find.byKey(const ValueKey('bus')), const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Annulla'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('bus')), findsOneWidget);

    await tester.tap(find.text('Ricorrenti'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('stats-global-period')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('edit page deletes the movement after confirmation', (
    tester,
  ) async {
    final (database, container) = await seed(month);
    addTearDown(() async {
      container.dispose();
      await database.close();
    });
    final transactions = await container.read(transactionProvider.future);
    final pizza = transactions.singleWhere((tx) => tx.id == 'pizza');
    await tester.pumpWidget(
      app(
        container,
        Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => AddTransactionPage(transaction: pizza),
                  ),
                ),
                child: const Text('open'),
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Modifica movimento'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('edit-transaction-delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Elimina'));
    await tester.pumpAndSettle();
    expect(find.byType(AddTransactionPage), findsNothing);
    expect(
      (await database.getAllTransactions()).map((row) => row.id),
      isNot(contains('pizza')),
    );
    expect(find.text('Annulla'), findsOneWidget);
  });

  for (final dark in [false, true]) {
    testWidgets(
      'home overview colors income, expenses and savings (dark=$dark)',
      (tester) async {
        final (database, container) = await seed(month);
        addTearDown(() async {
          container.dispose();
          await database.close();
        });
        await tester.pumpWidget(
          app(container, const DashboardPage(), dark: dark),
        );
        await tester.pumpAndSettle();
        final context = tester.element(find.byType(DashboardPage));
        Color? valueColor(String key) => tester
            .widget<Text>(
              find
                  .descendant(
                    of: find.byKey(ValueKey(key)),
                    matching: find.byType(Text),
                  )
                  .last,
            )
            .style
            ?.color;
        expect(valueColor('budget-metric-income'), VaultColors.income(context));
        expect(
          valueColor('budget-metric-expense'),
          VaultColors.expense(context),
        );
        expect(
          valueColor('budget-metric-savings'),
          VaultColors.savings(context),
        );
        // The period control of Statistics replaces the old selectors.
        expect(
          find.byKey(const ValueKey('stats-global-period')),
          findsOneWidget,
        );
        expect(find.text('Home'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
