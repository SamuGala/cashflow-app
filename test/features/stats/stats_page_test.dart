import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_vault/core/database/app_database.dart';
import 'package:pocket_vault/core/database/database_provider.dart';
import 'package:pocket_vault/features/forecast/presentation/cashflow_forecast_card.dart';
import 'package:pocket_vault/features/stats/presentation/stats_page.dart';
import 'package:pocket_vault/features/stats/widgets/category_donut_chart.dart';
import 'package:pocket_vault/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('recurring forecast is below the category donut chart', (
    tester,
  ) async {
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
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const MaterialApp(
          locale: Locale('it'),
          supportedLocales: [Locale('en'), Locale('it'), Locale('es')],
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: StatsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final donut = find.byType(CategoryDonutChart);
    final forecast = find.byType(CashflowForecastCard);
    expect(donut, findsOneWidget);
    expect(forecast, findsOneWidget);
    expect(
      tester.getTopLeft(forecast).dy,
      greaterThan(tester.getTopLeft(donut).dy),
    );
    expect(tester.takeException(), isNull);
  });
}
