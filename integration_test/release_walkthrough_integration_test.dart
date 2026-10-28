import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pocket_vault/app/router.dart';
import 'package:pocket_vault/core/database/app_database.dart';
import 'package:pocket_vault/core/database/database_provider.dart';
import 'package:pocket_vault/core/providers/balance_visibility_provider.dart';
import 'package:pocket_vault/core/providers/time_filter_provider.dart';
import 'package:pocket_vault/core/security/auth_provider.dart';
import 'package:pocket_vault/features/settings/presentation/providers/theme_provider.dart';
import 'package:pocket_vault/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const capture = bool.fromEnvironment('CAPTURE_RELEASE');
  const prefix = String.fromEnvironment('SHOT_PREFIX', defaultValue: 'app');

  Future<void> shot(WidgetTester tester, String name) async {
    await tester.pumpAndSettle();
    if (capture) await binding.takeScreenshot('$prefix-$name');
  }

  testWidgets('release walkthrough: seeded data, UI entry, every screen', (
    tester,
  ) async {
    final now = DateTime.now();
    final month = DateTime(now.year, now.month);
    SharedPreferences.setMockInitialValues({
      'locale': 'it',
      'theme_mode_v1': 'light',
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

    // Three months of realistic history, kept before today so nothing is
    // treated as a future entry.
    final day = now.day > 1 ? now.day - 1 : 1;
    for (var back = 0; back < 3; back++) {
      final m = DateTime(month.year, month.month - back);
      final lastDay = back == 0 ? day : 28;
      DateTime on(int d) => DateTime(m.year, m.month, d.clamp(1, lastDay), 12);
      final entries = [
        ('salary', 245000, true, 1),
        ('bonus', back == 1 ? 30000 : 0, true, 15),
        ('rent', 85000, false, 2),
        ('groceries', 18450 + back * 2300, false, 5),
        ('groceries', 9620, false, 18),
        ('food', 4280 + back * 700, false, 8),
        ('transport', 6500, false, 10),
        ('bills', 12340, false, 12),
        ('shopping', 15990 - back * 3000, false, 20),
        ('entertainment', 2990, false, 22),
        ('health', back == 2 ? 6000 : 2500, false, 25),
      ];
      for (final (index, e) in entries.indexed) {
        if (e.$2 == 0) continue;
        await database.insertTransaction(
          TransactionsCompanion.insert(
            id: 'seed-$back-$index',
            categoryId: e.$1,
            amountCents: e.$2,
            isIncome: e.$3,
            date: on(e.$4),
          ),
        );
      }
    }
    await database
        .into(database.recurringTransactions)
        .insert(
          RecurringTransaction(
            id: 'netflix',
            amountCents: 1399,
            isIncome: false,
            categoryId: 'entertainment',
            dayOfMonth: 27,
            startDate: DateTime(month.year, month.month - 2, 27),
            active: true,
            frequency: 'monthly',
            interval: 1,
          ),
        );
    await database
        .into(database.budgets)
        .insert(
          BudgetRow(
            id: 'budget-groceries',
            categoryId: 'groceries',
            amountMinor: 35000,
            eurAmountMicros: 3500000000,
            periodType: 'monthly',
            rollover: false,
            active: true,
            createdAt: month,
            updatedAt: month,
          ),
        );
    await database
        .into(database.savingsGoals)
        .insert(
          SavingsGoalRow(
            id: 'trip',
            name: 'Viaggio in Giappone',
            targetAmountMinor: 300000,
            savedAmountMinor: 85000,
            targetEurMicros: 3000000000,
            savedEurMicros: 850000000,
            currencyCode: 'EUR',
            icon: Icons.flight_takeoff.codePoint,
            color: 0xFF5867D9,
            completed: false,
            archived: false,
            createdAt: month,
            updatedAt: month,
          ),
        );

    container.read(authProvider.notifier).unlock();
    container.read(timeFilterProvider.notifier).setMonth(month);
    container.read(balanceVisibilityProvider.notifier).show();
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const RootApp()),
    );
    await tester.pumpAndSettle();
    if (capture && Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
    }

    await shot(tester, '01-home');
    await tester.drag(find.byType(ListView).first, const Offset(0, -500));
    await shot(tester, '02-home-scrolled');
    await tester.drag(find.byType(ListView).first, const Offset(0, 500));
    await tester.pumpAndSettle();

    // Add an expense through the real quick-add sheet.
    await tester.tap(find.byKey(const ValueKey('add-transaction-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('0,00'));
    await tester.pumpAndSettle();
    for (final key in ['2', '7', '5', '0']) {
      final button = find.byKey(ValueKey('quick-amount-key-$key'));
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pump();
    }
    expect(find.text('27,50'), findsOneWidget);
    await shot(tester, '03-quick-add-keypad');
    await tester.tap(find.text('Conferma'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ActionChip, 'Cibo'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Pizza con amici');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await shot(tester, '04-quick-add-filled');
    final save = find.text('Salva movimento');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    final added = await database.select(database.transactions).get();
    expect(added.where((t) => t.amountCents == 2750 && t.categoryId == 'food'),
        hasLength(1));

    appRouter.go('/transactions');
    await tester.pumpAndSettle();
    expect(find.textContaining('Pizza con amici'), findsWidgets);
    await shot(tester, '05-transactions');

    appRouter.go('/stats');
    await shot(tester, '06-stats-overview');
    await tester.tap(find.byKey(const ValueKey('stats-tab-1')));
    await shot(tester, '07-stats-categories');
    await tester.tap(find.byKey(const ValueKey('stats-tab-2')));
    await shot(tester, '08-stats-comparisons');

    appRouter.go('/settings');
    await shot(tester, '09-settings');

    await container.read(themeProvider.notifier).setTheme(AppThemeMode.dark);
    appRouter.go('/dashboard');
    await shot(tester, '10-home-dark');
    appRouter.go('/stats');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('stats-tab-0')));
    await shot(tester, '11-stats-dark');

    container.read(balanceVisibilityProvider.notifier).hide();
    appRouter.go('/dashboard');
    await shot(tester, '12-home-private-dark');

    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
