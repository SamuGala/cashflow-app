import 'dart:convert';
import 'dart:math' as math;

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
import 'package:pocket_vault/features/transactions/providers/transaction_provider.dart';
import 'package:pocket_vault/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const capture = bool.fromEnvironment('CAPTURE_STATS');
  testWidgets(
    'native stats: shared filters, independent comparison, privacy and unchanged archive',
    (tester) async {
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
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(() async {
        container.dispose();
        await db.close();
      });
      final months = <DateTime>{
        DateTime(month.year, month.month - 1),
        for (var m = 1; m <= month.month; m++) DateTime(month.year, m),
      }.toList();
      for (final date in months) {
        final current = date == month;
        final previous = date == DateTime(month.year, month.month - 1);
        await db.insertTransaction(
          TransactionsCompanion.insert(
            id: '${date.year}-${date.month}-salary',
            categoryId: 'salary',
            amountCents: 280000,
            isIncome: true,
            date: DateTime(date.year, date.month, 1, 12),
          ),
        );
        final totals = [
          (
            'shopping',
            current
                ? 44000
                : previous
                ? 62000
                : 34000 + date.month * 600,
          ),
          ('groceries', current ? 35000 : 30000),
          ('transport', current ? 15000 : 18000),
        ];
        // Synthetic daily records make both the chart and its gesture inspectable.
        // They sum exactly to each category total, independently of month length.
        final lastDay = math.min(
          now.day,
          DateTime(date.year, date.month + 1, 0).day,
        );
        final days = [
          for (var day = lastDay > 1 ? 2 : 1; day <= lastDay; day++) day,
        ];
        for (
          var categoryIndex = 0;
          categoryIndex < totals.length;
          categoryIndex++
        ) {
          final entry = totals[categoryIndex];
          final weights = [
            for (final day in days) 2 + (day * 5 + categoryIndex * 3) % 7,
          ];
          final weightTotal = weights.fold<int>(0, (a, b) => a + b);
          var remaining = entry.$2;
          for (var i = 0; i < days.length; i++) {
            final amount = i == days.length - 1
                ? remaining
                : entry.$2 * weights[i] ~/ weightTotal;
            remaining -= amount;
            await db.insertTransaction(
              TransactionsCompanion.insert(
                id: '${date.year}-${date.month}-${entry.$1}-${days[i]}',
                categoryId: entry.$1,
                amountCents: amount,
                isIncome: false,
                date: DateTime(date.year, date.month, days[i], 12),
              ),
            );
          }
        }
      }
      container.read(authProvider.notifier).unlock();
      container.read(balanceVisibilityProvider.notifier).show();
      container.read(timeFilterProvider.notifier).setMonth(month);
      container.read(timeFilterProvider.notifier).setFilter(TimeFilter.total);
      await tester.pumpWidget(
        UncontrolledProviderScope(container: container, child: const RootApp()),
      );
      await tester.pumpAndSettle();
      await container.read(transactionProvider.future);
      final before = await db.exportSnapshot();
      appRouter.go('/stats');
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('stats-global-period')),
          matching: find.text('Totale'),
        ),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('stats-global-period')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('stats-filter-month')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(ValueKey('stats-picker-month-${month.month}')),
      );
      await tester.pumpAndSettle();
      expect(container.read(timeFilterProvider).filter, TimeFilter.month);
      appRouter.go('/dashboard');
      await tester.pumpAndSettle();
      expect(find.text('Disponibile questo mese'), findsOneWidget);
      appRouter.go('/stats');
      await tester.pumpAndSettle();
      if (capture) {
        await binding.convertFlutterSurfaceToImage();
        await tester.pumpAndSettle();
        await binding.takeScreenshot('stats-overview-light');
      }
      await tester.drag(
        find.byKey(const ValueKey('stats-trend-chart')),
        const Offset(80, 0),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('stats-chart-readout')))
            .data,
        isNot('Trascina sul grafico per esplorare'),
      );
      await container.read(themeProvider.notifier).setTheme(AppThemeMode.dark);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('stats-tab-1')));
      await tester.pumpAndSettle();
      if (capture) {
        await binding.takeScreenshot('stats-categories-dark');
        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('stats-category-transactions')),
          250,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.ensureVisible(
          find.byKey(const ValueKey('stats-category-transactions')),
        );
        await tester.pumpAndSettle();
        await binding.takeScreenshot('stats-category-detail-dark');
        await tester.drag(
          find.byKey(const PageStorageKey('stats-scroll')),
          const Offset(0, 3000),
        );
        await tester.pumpAndSettle();
      }
      await container.read(themeProvider.notifier).setTheme(AppThemeMode.light);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('stats-tab-2')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('stats-global-period')), findsNothing);
      expect(find.byKey(const ValueKey('stats-local-period')), findsOneWidget);
      if (capture) {
        await binding.takeScreenshot('stats-comparisons-light');
        await tester.drag(
          find.byKey(const PageStorageKey('stats-scroll')),
          const Offset(0, -650),
        );
        await tester.pumpAndSettle();
        await binding.takeScreenshot('stats-comparison-details-light');
        await tester.drag(
          find.byKey(const PageStorageKey('stats-scroll')),
          const Offset(0, 3000),
        );
        await tester.pumpAndSettle();
      }
      final global = container.read(timeFilterProvider);
      await tester.tap(find.byKey(const ValueKey('stats-local-period')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('stats-comparison-mode')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Media dei mesi precedenti dell’anno').last);
      await tester.pumpAndSettle();
      if (capture) await binding.takeScreenshot('stats-comparison-options');
      await tester.ensureVisible(
        find.byKey(const ValueKey('stats-apply-comparison')),
      );
      await tester.tap(find.byKey(const ValueKey('stats-apply-comparison')));
      await tester.pumpAndSettle();
      expect(container.read(timeFilterProvider), same(global));
      if (capture) await binding.takeScreenshot('stats-average-light');
      await tester.tap(find.byKey(const ValueKey('stats-privacy')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widgetList<Text>(find.byType(Text))
            .map((t) => t.data ?? '')
            .any((s) => s.contains('€') || s.contains('%')),
        isFalse,
      );
      if (capture) await binding.takeScreenshot('stats-private-light');
      expect(await db.exportSnapshot(), equals(before));
      container.read(timeFilterProvider.notifier).setPeriod(month, month);
      await tester.tap(find.byKey(const ValueKey('stats-tab-0')));
      await tester.pumpAndSettle();
      expect(container.read(timeFilterProvider).filter, TimeFilter.period);
      expect(find.byKey(const ValueKey('stats-global-period')), findsOneWidget);
      expect(tester.takeException(), isNull);
      appRouter.go('/dashboard');
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );
}
