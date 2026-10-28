import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pocket_vault/core/currency/currency_metadata.dart';
import 'package:pocket_vault/core/database/app_database.dart';
import 'package:pocket_vault/core/database/database_provider.dart';
import 'package:pocket_vault/core/providers/balance_visibility_provider.dart';
import 'package:pocket_vault/core/providers/time_filter_provider.dart';
import 'package:pocket_vault/core/security/auth_provider.dart';
import 'package:pocket_vault/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'native app aggregates, masks and refreshes upcoming transactions',
    (tester) async {
      final now = DateTime.now();
      final month = DateTime(now.year, now.month + 1);
      SharedPreferences.setMockInitialValues({
        'locale': 'it',
        'base_currency_v1': 'EUR',
        'currency_rates_ecb_v1': jsonEncode({
          'rates': {'EUR': 1.0},
          'publishedAt': now.toIso8601String(),
          'fetchedAt': now.toIso8601String(),
        }),
      });
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(database)],
      );
      addTearDown(() async {
        container.dispose();
        await database.close();
      });

      for (final entry in [
        ('salary', 200000, true),
        ('extra', 50000, true),
        ('rent', 40000, false),
        ('subscription', 3000, false),
      ]) {
        await database
            .into(database.recurringTransactions)
            .insert(
              RecurringTransaction(
                id: entry.$1,
                amountCents: entry.$2,
                isIncome: entry.$3,
                categoryId: entry.$3 ? 'salary' : 'rent',
                dayOfMonth: 20,
                startDate: month,
                active: true,
                frequency: 'monthly',
                interval: 1,
              ),
            );
      }
      container.read(authProvider.notifier).unlock();
      container.read(timeFilterProvider.notifier).setMonth(month);
      container.read(balanceVisibilityProvider.notifier).show();
      await tester.pumpWidget(
        UncontrolledProviderScope(container: container, child: const RootApp()),
      );
      await tester.pumpAndSettle();

      const incomeKey = ValueKey('upcoming-income-total');
      const expenseKey = ValueKey('upcoming-expense-total');
      expect(find.text('Transazioni in arrivo'), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(incomeKey)).data,
        '+${formatMoney(250000, 'EUR', 'it')}',
      );
      expect(
        tester.widget<Text>(find.byKey(expenseKey)).data,
        '-${formatMoney(43000, 'EUR', 'it')}',
      );
      await tester.tap(find.byTooltip('Nascondi importi'));
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(find.byKey(incomeKey)).data, '••••');
      expect(tester.widget<Text>(find.byKey(expenseKey)).data, '••••');
      await tester.tap(find.byTooltip('Mostra importi'));
      await tester.pumpAndSettle();

      Future<void> tab(String label) async {
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text(label),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      await tab('Movimenti');
      await tester.tap(find.text('Ricorrenti'));
      await tester.pumpAndSettle();
      final salary = find.byKey(const ValueKey('salary'));
      await tester.drag(salary, const Offset(300, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Metti in pausa'));
      await tester.pumpAndSettle();
      // Let the floating confirmation leave before opening the next action
      // sheet, whose bottom row occupies the same area on a real device.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await tab('Home');
      expect(
        tester.widget<Text>(find.byKey(incomeKey)).data,
        '+${formatMoney(50000, 'EUR', 'it')}',
      );

      await tab('Movimenti');
      await tester.drag(salary, const Offset(300, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Riattiva'));
      await tester.pumpAndSettle();
      await tab('Statistiche');
      await tab('Impostazioni');
      await tab('Home');
      expect(
        tester.widget<Text>(find.byKey(incomeKey)).data,
        '+${formatMoney(250000, 'EUR', 'it')}',
      );
      expect(
        tester.widget<Text>(find.byKey(expenseKey)).data,
        '-${formatMoney(43000, 'EUR', 'it')}',
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );
}
