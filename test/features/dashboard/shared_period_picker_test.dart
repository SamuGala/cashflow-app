import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_vault/core/database/app_database.dart';
import 'package:pocket_vault/core/database/database_provider.dart';
import 'package:pocket_vault/core/providers/time_filter_provider.dart';
import 'package:pocket_vault/features/dashboard/presentation/dashboard_page.dart'
    as dashboard;
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
  for (final year in [2010, DateTime.now().year + 5]) {
    testWidgets(
      'Home reopens a shared period from year $year without calendar bounds errors',
      (tester) async {
        final start = DateTime(year, 2);
        final end = DateTime(year, 2, 15);
        await tester.pumpWidget(
          app(
            dashboard.PeriodSelector(
              start: start,
              end: end,
              onChanged: (_, _) {},
            ),
          ),
        );
        await tester.tap(find.byType(dashboard.PeriodSelector));
        await tester.pumpAndSettle();
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
        await tester.tap(find.byIcon(Icons.calendar_month).first);
        await tester.pumpAndSettle();
        expect(find.byType(DateRangePickerDialog), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
