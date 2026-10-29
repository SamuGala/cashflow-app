import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_vault/core/database/app_database.dart';
import 'package:pocket_vault/core/database/database_provider.dart';
import 'package:pocket_vault/core/providers/time_filter_provider.dart';
import 'package:pocket_vault/features/stats/widgets/stats_period_controls.dart';
import 'package:pocket_vault/features/transactions/presentation/transactions_page.dart';
import 'package:pocket_vault/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget app(Widget body) => MaterialApp(
  locale: const Locale('it'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: Scaffold(body: body),
);

void main() {
  Future<void> openPeriodPicker(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('stats-global-period')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('stats-filter-period')));
    await tester.pumpAndSettle();
  }

  for (final year in [2010, DateTime.now().year + 5]) {
    testWidgets(
      'Home reopens a shared period from year $year without calendar bounds errors',
      (tester) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        container
            .read(timeFilterProvider.notifier)
            .setPeriod(DateTime(year, 2), DateTime(year, 2, 15));
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: app(const StatsGlobalPeriodButton(transactions: [])),
          ),
        );
        await openPeriodPicker(tester);
        expect(find.byType(DateRangePickerDialog), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final year in [2010, 2105]) {
    testWidgets(
      'Movements reopens a shared period from year $year without calendar bounds errors',
      (tester) async {
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
        final container = ProviderContainer(
          overrides: [databaseProvider.overrideWithValue(database)],
        );
        addTearDown(() async {
          container.dispose();
          await database.close();
        });
        container
            .read(timeFilterProvider.notifier)
            .setPeriod(DateTime(year, 2), DateTime(year, 2, 15));
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: app(const TransactionsPage()),
          ),
        );
        await tester.pumpAndSettle();
        await openPeriodPicker(tester);
        expect(find.byType(DateRangePickerDialog), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
