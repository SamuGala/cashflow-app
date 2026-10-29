import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pocket_vault/core/database/app_database.dart';
import 'package:pocket_vault/core/database/database_provider.dart';
import 'package:pocket_vault/core/providers/balance_visibility_provider.dart';
import 'package:pocket_vault/core/providers/time_filter_provider.dart';
import 'package:pocket_vault/core/security/auth_provider.dart';
import 'package:pocket_vault/features/settings/presentation/providers/theme_provider.dart';
import 'package:pocket_vault/main.dart';
import 'package:pocket_vault/shared/widgets/receipt_scan_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const capture = bool.fromEnvironment('CAPTURE_DASHBOARD');

  testWidgets(
    'approved dashboard design preserves actions and readable totals',
    (tester) async {
      final now = DateTime.now();
      final month = DateTime(now.year, now.month + 1);
      final date = DateTime(month.year, month.month, 2);
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
      for (final entry in [
        ('salary', 280000, true),
        ('shopping', 44000, false),
        ('food', 35000, false),
        ('transport', 15000, false),
      ]) {
        await database.insertTransaction(
          TransactionsCompanion.insert(
            id: entry.$1,
            categoryId: entry.$1,
            amountCents: entry.$2,
            isIncome: entry.$3,
            date: date,
          ),
        );
      }
      for (final income in [true, false]) {
        await database
            .into(database.recurringTransactions)
            .insert(
              RecurringTransaction(
                id: 'future-$income',
                amountCents: income ? 200000 : 40000,
                isIncome: income,
                categoryId: income ? 'salary' : 'rent',
                dayOfMonth: 20,
                startDate: month,
                active: true,
                frequency: 'monthly',
                interval: 1,
              ),
            );
      }
      await database
          .into(database.savingsGoals)
          .insert(
            SavingsGoalRow(
              id: 'trip',
              name: 'Viaggio',
              targetAmountMinor: 100000,
              savedAmountMinor: 20000,
              targetEurMicros: 1000000000,
              savedEurMicros: 200000000,
              currencyCode: 'EUR',
              icon: Icons.savings_outlined.codePoint,
              color: 0xFF5867D9,
              completed: false,
              archived: false,
              createdAt: date,
              updatedAt: date,
            ),
          );
      await database
          .into(database.savingsGoalContributions)
          .insert(
            SavingsGoalContributionRow(
              id: 'trip-deposit',
              goalId: 'trip',
              amountMinor: 20000,
              eurAmountMicros: 200000000,
              currencyCode: 'EUR',
              createdAt: date,
            ),
          );
      container.read(authProvider.notifier).unlock();
      container.read(timeFilterProvider.notifier).setMonth(month);
      container.read(balanceVisibilityProvider.notifier).show();
      await tester.pumpWidget(
        UncontrolledProviderScope(container: container, child: const RootApp()),
      );
      await tester.pumpAndSettle();
      if (capture) {
        await binding.convertFlutterSurfaceToImage();
        await tester.pumpAndSettle();
      }
      for (final mode in [AppThemeMode.light, AppThemeMode.dark]) {
        await container.read(themeProvider.notifier).setTheme(mode);
        await tester.pumpAndSettle();
        final scan = find.byKey(const ValueKey('scan-receipt-button'));
        final add = find.byKey(const ValueKey('add-transaction-button'));
        expect(
          find.descendant(of: scan, matching: find.byType(ReceiptScanIcon)),
          findsOneWidget,
        );
        expect(
          tester.getSize(
            find.descendant(of: scan, matching: find.byType(Material)).first,
          ),
          const Size(40, 40),
        );
        expect(tester.getSize(add), const Size(56, 56));
        expect(tester.getCenter(scan).dx, tester.getCenter(add).dx);
        expect(tester.getCenter(scan).dy, lessThan(tester.getCenter(add).dy));
        expect(
          find.byKey(const ValueKey('vault-navigation-capsule')),
          findsOneWidget,
        );
        expect(find.text('Transazioni in arrivo'), findsOneWidget);
        final floatingBounds = [tester.getRect(scan), tester.getRect(add)];
        for (final key in ['goal-period-allocation', 'goal-total-trip']) {
          // Shorter screens build these rows only once scrolled into view.
          await tester.scrollUntilVisible(
            find.byKey(ValueKey(key)),
            120,
            scrollable: find.byType(Scrollable).first,
          );
          final bounds = tester.getRect(find.byKey(ValueKey(key)));
          expect(floatingBounds.any(bounds.overlaps), isFalse);
        }
        await tester.drag(find.byType(ListView).first, const Offset(0, 2000));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (capture) {
          await binding.takeScreenshot('vault-essenziale-${mode.name}');
        }
      }
      await container.read(themeProvider.notifier).setTheme(AppThemeMode.light);
      await tester.pumpAndSettle();
      // Category rows span the full width; the list's bottom inset keeps them
      // clear of the floating actions once scrolled to the end.
      await tester.drag(find.byType(ListView).first, const Offset(0, -3000));
      await tester.pumpAndSettle();
      final actions = [
        tester.getRect(find.byKey(const ValueKey('scan-receipt-button'))),
        tester.getRect(find.byKey(const ValueKey('add-transaction-button'))),
      ];
      expect(
        actions.any(
          tester
              .getRect(find.byKey(const ValueKey('category-flow-toggle')))
              .overlaps,
        ),
        isFalse,
      );
      for (final id in ['shopping', 'food', 'transport']) {
        final amount = find.byKey(ValueKey('category-total-$id'));
        expect(amount, findsOneWidget);
        final box = tester.getRect(amount);
        expect(actions.any(box.overlaps), isFalse);
      }
      if (capture) await binding.takeScreenshot('vault-essenziale-categories');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );
}
