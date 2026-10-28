import 'dart:convert';

import 'package:drift/native.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_vault/app/theme/app_theme.dart';
import 'package:pocket_vault/core/currency/currency_metadata.dart';
import 'package:pocket_vault/core/currency/currency_provider.dart';
import 'package:pocket_vault/core/database/app_database.dart';
import 'package:pocket_vault/core/database/database_provider.dart';
import 'package:pocket_vault/core/providers/balance_visibility_provider.dart';
import 'package:pocket_vault/core/providers/time_filter_provider.dart';
import 'package:pocket_vault/features/forecast/presentation/cashflow_forecast_card.dart';
import 'package:pocket_vault/features/stats/presentation/stats_page.dart';
import 'package:pocket_vault/features/stats/widgets/stats_visuals.dart';
import 'package:pocket_vault/features/transactions/providers/transaction_provider.dart';
import 'package:pocket_vault/features/transactions/providers/category_provider.dart';
import 'package:pocket_vault/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase database;
  late ProviderContainer container;
  final now = DateTime.now();
  final month = DateTime(now.year, now.month);

  Future<void> seed() async {
    for (final entry in [
      ('salary', 280000, true, 0),
      ('shopping', 44000, false, 0),
      ('food', 35000, false, 0),
      ('transport', 15000, false, 0),
      ('shopping', 62000, false, -1),
      ('food', 30000, false, -1),
      ('transport', 18000, false, -1),
    ]) {
      await database.insertTransaction(
        TransactionsCompanion.insert(
          id: '${entry.$1}:${entry.$4}',
          categoryId: entry.$1,
          amountCents: entry.$2,
          isIncome: entry.$3,
          date: DateTime(month.year, month.month + entry.$4, 1, 14),
        ),
      );
    }
    await container.read(transactionProvider.future);
    await container.read(categoryProvider.future);
  }

  Widget app({String language = 'it', bool dark = false, double scale = 1}) =>
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: Locale(language),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: const StatsPage(),
        ),
      );
  Finder key(String value) => find.byKey(ValueKey(value));
  late WidgetTester currentTester;
  String testerText(Finder finder) => currentTester
      .widgetList<Text>(
        find.descendant(of: finder, matching: find.byType(Text)),
      )
      .map((e) => e.data ?? '')
      .join();
  String amount(String value) => testerText(key(value));

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'base_currency_v1': 'EUR',
      'currency_rates_ecb_v1': jsonEncode({
        'rates': {'EUR': 1.0, 'JPY': 160.0},
        'publishedAt': now.toIso8601String(),
        'fetchedAt': now.toIso8601String(),
      }),
    });
    database = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    container.read(timeFilterProvider.notifier).setMonth(month);
    container.read(balanceVisibilityProvider.notifier).show();
  });
  tearDown(() async {
    container.dispose();
    await database.close();
  });

  test('compact labels preserve cents and currency precision', () {
    expect(statsCompactMoney(199, 'EUR', 'it'), formatMoney(199, 'EUR', 'it'));
    expect(
      statsCompactMoney(1000001, 'EUR', 'it'),
      formatMoney(1000001, 'EUR', 'it'),
    );
    expect(statsCompactMoney(123, 'JPY', 'it'), formatMoney(123, 'JPY', 'it'));
    expect(statsCompactMoney(44000, 'EUR', 'it'), '440 €');
  });

  testWidgets(
    'overview insight opens the category in its shared historical period',
    (tester) async {
      await seed();
      final historical = DateTime(month.year, month.month - 1);
      container.read(timeFilterProvider.notifier).setMonth(historical);
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      final original = container.read(timeFilterProvider);
      await tester.ensureVisible(key('stats-overview-insight'));
      await tester.pumpAndSettle();
      await tester.tap(key('stats-overview-insight'));
      await tester.pumpAndSettle();
      expect(container.read(timeFilterProvider), same(original));
      expect(key('stats-category-donut'), findsOneWidget);
      expect(key('stats-local-period'), findsNothing);
      expect(key('stats-category-transactions'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'overview reference follows the shared period and disappears in total',
    (tester) async {
      await seed();
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      var lines = tester
          .widget<LineChart>(key('stats-trend-chart'))
          .data
          .lineBarsData;
      expect(lines.length, 2);
      expect(lines[0].spots.last.y, 110000);
      expect(lines[1].spots.last.y, 94000);
      container.read(timeFilterProvider.notifier).setFilter(TimeFilter.total);
      await tester.pumpAndSettle();
      lines = tester
          .widget<LineChart>(key('stats-trend-chart'))
          .data
          .lineBarsData;
      expect(lines.length, 1);
      expect(lines.single.spots.last.y, 204000);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'main currency changes update statistics with correct zero-decimal formatting',
    (tester) async {
      currentTester = tester;
      await seed();
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      await container.read(currencyProvider.notifier).setBaseCurrency('JPY');
      await tester.pumpAndSettle();
      expect(amount('stats-selected-total'), formatMoney(150400, 'JPY', 'it'));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('custom reference month and year stay local to comparisons', (
    tester,
  ) async {
    await seed();
    final original = container.read(timeFilterProvider);
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(key('stats-tab-2'));
    await tester.pumpAndSettle();
    await tester.tap(key('stats-local-period'));
    await tester.pumpAndSettle();
    await tester.tap(key('stats-comparison-mode'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Scegli un mese').last);
    await tester.pumpAndSettle();
    await tester.tap(key('stats-comparison-reference'));
    await tester.pumpAndSettle();
    await tester.tap(key('stats-picker-year'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('${now.year - 1}').last);
    await tester.pumpAndSettle();
    await tester.tap(key('stats-picker-month-2'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(key('stats-apply-comparison'));
    await tester.tap(key('stats-apply-comparison'));
    await tester.pumpAndSettle();
    expect(container.read(timeFilterProvider), same(original));
    final label = tester
        .widgetList<Text>(
          find.descendant(
            of: key('stats-local-period'),
            matching: find.byType(Text),
          ),
        )
        .map((t) => t.data ?? '')
        .join();
    expect(label, contains('${(now.year - 1) % 100}'));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'date-range selection updates the shared period instead of a private copy',
    (tester) async {
      await seed();
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      final saveLabel = MaterialLocalizations.of(
        tester.element(key('stats-global-period')),
      ).saveButtonLabel;
      await tester.tap(key('stats-global-period'));
      await tester.pumpAndSettle();
      await tester.tap(key('stats-filter-period'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(saveLabel));
      await tester.pumpAndSettle();
      final state = container.read(timeFilterProvider);
      expect(state.filter, TimeFilter.period);
      expect(state.start, month);
      expect(state.end, DateTime(month.year, month.month + 1, 0));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'shared total/month/period filter changes all overview amounts inclusively',
    (tester) async {
      currentTester = tester;
      await seed();
      container.read(timeFilterProvider.notifier).setFilter(TimeFilter.total);
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(amount('stats-selected-total'), formatMoney(204000, 'EUR', 'it'));
      expect(
        find.descendant(
          of: key('stats-global-period'),
          matching: find.text('Totale'),
        ),
        findsOneWidget,
      );
      container.read(timeFilterProvider.notifier).setFilter(TimeFilter.month);
      await tester.pumpAndSettle();
      expect(amount('stats-selected-total'), formatMoney(94000, 'EUR', 'it'));
      container.read(timeFilterProvider.notifier).setPeriod(month, month);
      await tester.pumpAndSettle();
      expect(amount('stats-selected-total'), formatMoney(94000, 'EUR', 'it'));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'comparison has its own defaults and never changes the shared filter',
    (tester) async {
      currentTester = tester;
      await seed();
      container.read(timeFilterProvider.notifier).setFilter(TimeFilter.total);
      final original = container.read(timeFilterProvider);
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      await tester.tap(key('stats-tab-2'));
      await tester.pumpAndSettle();
      expect(key('stats-global-period'), findsNothing);
      expect(key('stats-local-period'), findsOneWidget);
      expect(
        amount('stats-comparison-delta'),
        '−${formatMoney(16000, 'EUR', 'it')}',
      );
      await tester.tap(key('stats-local-period'));
      await tester.pumpAndSettle();
      await tester.tap(key('stats-comparison-mode'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Media dei mesi precedenti dell’anno').last);
      await tester.pumpAndSettle();
      await tester.tap(key('stats-apply-comparison'));
      await tester.pumpAndSettle();
      expect(container.read(timeFilterProvider), same(original));
      await tester.tap(key('stats-tab-0'));
      await tester.pumpAndSettle();
      expect(amount('stats-selected-total'), formatMoney(204000, 'EUR', 'it'));
      expect(key('stats-global-period'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'shared selector supports total and month picker cancellation without changing state',
    (tester) async {
      currentTester = tester;
      await seed();
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      await tester.tap(key('stats-global-period'));
      await tester.pumpAndSettle();
      await tester.tap(key('stats-filter-total'));
      await tester.pumpAndSettle();
      expect(container.read(timeFilterProvider).filter, TimeFilter.total);
      await tester.tap(key('stats-global-period'));
      await tester.pumpAndSettle();
      await tester.tap(key('stats-filter-month'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Annulla'));
      await tester.pumpAndSettle();
      expect(container.read(timeFilterProvider).filter, TimeFilter.total);
      await tester.tap(key('stats-global-period'));
      await tester.pumpAndSettle();
      await tester.tap(key('stats-filter-month'));
      await tester.pumpAndSettle();
      await tester.tap(key('stats-picker-month-${month.month}'));
      await tester.pumpAndSettle();
      expect(container.read(timeFilterProvider).filter, TimeFilter.month);
      expect(amount('stats-selected-total'), formatMoney(94000, 'EUR', 'it'));
    },
  );

  testWidgets('dragging the line graph exposes a dated amount', (tester) async {
    await seed();
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    final chart = key('stats-trend-chart');
    expect(chart, findsOneWidget);
    await tester.dragFrom(tester.getCenter(chart), const Offset(60, 0));
    await tester.pumpAndSettle();
    final text = tester.widget<Text>(key('stats-chart-readout')).data!;
    expect(text, isNot('Trascina sul grafico per esplorare'));
    expect(text, contains('€'));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'privacy removes amounts, percentages, axes and touch details in every tab',
    (tester) async {
      currentTester = tester;
      await seed();
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      await tester.tap(key('stats-privacy'));
      await tester.pump();
      for (var tab = 0; tab < 3; tab++) {
        if (tab != 0) {
          await tester.tap(key('stats-tab-$tab'));
          await tester.pumpAndSettle();
        }
        expect(find.byType(LineChart), findsNothing);
        expect(find.byType(PieChart), findsNothing);
        for (final widget in tester.widgetList<Text>(find.byType(Text))) {
          expect(widget.data ?? '', isNot(contains('€')));
          expect(widget.data ?? '', isNot(contains('%')));
        }
        expect(tester.takeException(), isNull);
      }
      semantics.dispose();
    },
  );

  testWidgets(
    'category detail retains privacy even while its transaction sheet is open',
    (tester) async {
      await seed();
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      await tester.tap(key('stats-tab-1'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        key('stats-category-transactions'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(key('stats-category-transactions'));
      await tester.pumpAndSettle();
      await tester.tap(key('stats-category-transactions'));
      await tester.pumpAndSettle();
      expect(find.text('−${formatMoney(44000, 'EUR', 'it')}'), findsOneWidget);
      await container.read(currencyProvider.notifier).setBaseCurrency('JPY');
      await tester.pumpAndSettle();
      expect(find.text('−${formatMoney(70400, 'JPY', 'it')}'), findsOneWidget);
      container.read(balanceVisibilityProvider.notifier).hide();
      await tester.pump();
      expect(find.text('−${formatMoney(44000, 'EUR', 'it')}'), findsNothing);
      expect(find.text('−${formatMoney(70400, 'JPY', 'it')}'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'statistics, category drilldown and comparisons never write financial records',
    (tester) async {
      await seed();
      final before = await database.exportSnapshot();
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      for (final tab in [1, 2, 0]) {
        await tester.tap(key('stats-tab-$tab'));
        await tester.pumpAndSettle();
      }
      await tester.tap(key('stats-flow-menu'));
      await tester.pumpAndSettle();
      await tester.tap(key('stats-flow-true'));
      await tester.pumpAndSettle();
      expect(await database.exportSnapshot(), equals(before));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'existing recurring forecast stays reachable with its own explicit horizon',
    (tester) async {
      await seed();
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        key('stats-forecast'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(key('stats-forecast'));
      await tester.pumpAndSettle();
      await tester.tap(key('stats-forecast'));
      await tester.pumpAndSettle();
      expect(find.byType(CashflowForecastCard), findsOneWidget);
      expect(find.text('Previsione ricorrenze da oggi'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'empty archive renders all tabs without a NaN chart or exceptions',
    (tester) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      for (final tab in [0, 1, 2]) {
        await tester.tap(key('stats-tab-$tab'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets(
    '320px layout supports all languages, both themes and 150% text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await seed();
      for (final language in ['it', 'en', 'es']) {
        for (final dark in [false, true]) {
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
          await tester.pumpWidget(
            app(language: language, dark: dark, scale: 1.5),
          );
          await tester.pumpAndSettle();
          for (final tab in [0, 1, 2]) {
            await tester.tap(key('stats-tab-$tab'));
            await tester.pumpAndSettle();
            for (var i = 0; i < 4; i++) {
              await tester.drag(
                find.byKey(const PageStorageKey('stats-scroll')),
                const Offset(0, -450),
              );
              await tester.pumpAndSettle();
              expect(
                tester.takeException(),
                isNull,
                reason: '$language/$dark/tab$tab',
              );
            }
            await tester.drag(
              find.byKey(const PageStorageKey('stats-scroll')),
              const Offset(0, 5000),
            );
            await tester.pumpAndSettle();
          }
          await tester.tap(key('stats-local-period'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final t = AppLocalizations.of(
            tester.element(key('stats-apply-comparison')),
          )!;
          await tester.tap(key('stats-comparison-mode'));
          await tester.pumpAndSettle();
          await tester.tap(find.text(t.statsYearAverage).last);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.ensureVisible(key('stats-apply-comparison'));
          await tester.tap(key('stats-apply-comparison'));
          await tester.pumpAndSettle();
        }
      }
    },
  );
}
