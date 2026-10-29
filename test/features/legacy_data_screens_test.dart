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
import 'package:pocket_vault/features/dashboard/presentation/dashboard_page.dart';
import 'package:pocket_vault/features/stats/presentation/stats_page.dart';
import 'package:pocket_vault/features/transactions/domain/category.dart';
import 'package:pocket_vault/features/transactions/presentation/quick_add_transaction_sheet.dart';
import 'package:pocket_vault/features/transactions/presentation/transactions_page.dart';
import 'package:pocket_vault/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Archives written by earlier releases must render on the redesigned screens
/// without being rewritten.
void main() {
  final month = DateTime(2026, 3);

  Future<(AppDatabase, ProviderContainer, List<Object>)> seed() async {
    final now = DateTime.now();
    SharedPreferences.setMockInitialValues({
      'base_currency_v1': 'EUR',
      'currency_rates_ecb_v1': jsonEncode({
        'rates': {'EUR': 1.0, 'USD': 1.1},
        'publishedAt': now.toIso8601String(),
        'fetchedAt': now.toIso8601String(),
      }),
    });
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    // A custom category saved with a legacy Material code point and an
    // opaque legacy color, plus one with an icon this build does not know.
    await database.insertCategory(
      const Category(
        id: 'legacy-cart',
        name: 'Mercato',
        isIncome: false,
        icon: 0xe8cc,
        color: 0xFF009688,
        isDefault: false,
      ),
    );
    await database.insertCategory(
      const Category(
        id: 'unknown-icon',
        name: 'Hobby',
        isIncome: false,
        icon: 0x1234,
        color: 0x00000000,
        isDefault: false,
      ),
    );
    for (final entry in [
      ('a', 'legacy-cart', 4200, false, null, null),
      ('b', 'unknown-icon', 1800, false, null, null),
      // A movement whose category was removed in an old release.
      ('c', 'deleted-category', 900, false, null, null),
      // A foreign-currency movement stored with its original amount.
      ('d', 'food', 2000, false, 'USD', 2200),
      ('e', 'salary', 150000, true, null, null),
    ]) {
      await database.insertTransaction(
        TransactionsCompanion.insert(
          id: entry.$1,
          categoryId: entry.$2,
          amountCents: entry.$3,
          isIncome: entry.$4,
          date: DateTime(month.year, month.month, 5, 12),
          originalCurrency: Value(entry.$5),
          originalAmountMinor: Value(entry.$6),
        ),
      );
    }
    final snapshot = <Object>[
      for (final row in await database.getAllTransactions()) row.toJson(),
      for (final row in await database.select(database.categories).get())
        row.toJson(),
    ];
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    container.read(timeFilterProvider.notifier).setMonth(month);
    container.read(balanceVisibilityProvider.notifier).show();
    return (database, container, snapshot);
  }

  for (final dark in [false, true]) {
    testWidgets(
      'legacy archive renders on every redesigned screen (dark=$dark)',
      (tester) async {
        final (database, container, snapshot) = await seed();
        addTearDown(() async {
          container.dispose();
          await database.close();
        });
        for (final page in <Widget>[
          const DashboardPage(),
          const TransactionsPage(),
          const StatsPage(),
          const Scaffold(body: QuickAddTransactionSheet()),
        ]) {
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: MaterialApp(
                locale: const Locale('it'),
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
                home: page,
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: '${page.runtimeType}');
          if (page is StatsPage) {
            await tester.tap(find.byKey(const ValueKey('stats-tab-1')));
            await tester.pumpAndSettle();
            expect(
              find.byKey(const ValueKey('stats-category-donut')),
              findsOneWidget,
            );
            // Selecting the movement of a removed category must not throw.
            final row = find.byKey(
              const ValueKey('stats-category-deleted-category'),
            );
            await tester.ensureVisible(row);
            await tester.tap(row);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          }
        }
        expect(find.text('Mercato'), findsWidgets);
        await tester.pumpWidget(const SizedBox.shrink());
        final after = <Object>[
          for (final row in await database.getAllTransactions()) row.toJson(),
          for (final row in await database.select(database.categories).get())
            row.toJson(),
        ];
        expect(jsonEncode(after), jsonEncode(snapshot));
      },
    );
  }
}
