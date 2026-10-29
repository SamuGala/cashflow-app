import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_vault/app/theme/app_theme.dart';
import 'package:pocket_vault/core/currency/currency_metadata.dart';
import 'package:pocket_vault/core/database/app_database.dart';
import 'package:pocket_vault/core/database/database_provider.dart';
import 'package:pocket_vault/features/recap/domain/year_recap.dart';
import 'package:pocket_vault/features/recap/presentation/year_recap_entry.dart';
import 'package:pocket_vault/features/recap/presentation/year_recap_page.dart';
import 'package:pocket_vault/features/transactions/domain/transaction.dart';
import 'package:pocket_vault/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

TransactionModel tx(
  String id,
  String category,
  int amount,
  DateTime date, {
  bool income = false,
  String? note,
  String? source,
}) => TransactionModel(
  id: id,
  amountCents: amount,
  isIncome: income,
  categoryId: category,
  date: date,
  note: note,
  recurringSourceId: source,
);

RecurringTransaction rent() => RecurringTransaction(
  id: 'rent',
  amountCents: 75000,
  isIncome: false,
  categoryId: 'rent',
  dayOfMonth: 1,
  startDate: DateTime(2025, 1, 1),
  note: 'Affitto',
  active: true,
  frequency: 'monthly',
  interval: 1,
);

void main() {
  group('buildYearRecap', () {
    final now = DateTime(2026, 12, 28);
    final rows = [
      tx('s1', 'salary', 200000, DateTime(2026, 3, 27), income: true),
      tx('s2', 'salary', 200000, DateTime(2026, 8, 27), income: true),
      tx('r3', 'rent', 75000, DateTime(2026, 3, 1), source: 'rent'),
      tx('r8', 'rent', 75000, DateTime(2026, 8, 1), source: 'rent'),
      tx('f1', 'food', 2500, DateTime(2026, 3, 4)), // Wednesday
      tx('f2', 'food', 3000, DateTime(2026, 3, 11)), // Wednesday
      tx('t1', 'travel', 42000, DateTime(2026, 8, 10), note: 'Volo Tokyo'),
      tx('o1', 'food', 99999, DateTime(2025, 6, 1)),
      tx('future', 'food', 5000, DateTime(2027, 1, 2)),
    ];

    YearRecap build({Iterable<TransactionModel>? movements}) => buildYearRecap(
      year: 2026,
      transactions: movements ?? rows,
      recurring: [rent()],
      goals: const [],
      budgets: const [],
      now: now,
    );

    test('totals, months, categories and the one-off biggest expense', () {
      final recap = build();
      expect(recap.incomeMinor, 400000);
      expect(recap.spentMinor, 197500);
      expect(recap.netMinor, 202500);
      expect(recap.savedPercent, 51);
      expect(recap.movementCount, 7);
      expect(recap.activeMonths, [3, 8]);
      expect(recap.priciestMonth, 8);
      expect(recap.lightestMonth, 3);
      expect(recap.topCategories.first.key, 'rent');
      expect(recap.categoryCount, 3);
      // Rent is larger but recurring; the flight is the real one-off.
      expect(recap.biggestExpense!.id, 't1');
      expect(recap.busiestWeekday, DateTime.wednesday);
      expect(recap.recurring.single.occurrences, 2);
      expect(recap.recurringYearlyMinor, 150000);
      expect(recap.previousSpentMinor, 99999);
      expect(recap.spentChangePercent, 98);
      expect(recap.firstMovement, DateTime(2026, 3, 1));
    });

    test('a single active month has no priciest or lightest month', () {
      final recap = build(
        movements: [tx('a', 'food', 100, DateTime(2026, 5, 1))],
      );
      expect(recap.priciestMonth, isNull);
      expect(recap.savedPercent, isNull);
      expect(recap.hasPrevious, isFalse);
      expect(build(movements: const []).isEmpty, isTrue);
    });

    test('budget months kept, counted only for elapsed months', () {
      final budget = BudgetRow(
        id: 'b',
        categoryId: 'food',
        amountMinor: 2800,
        eurAmountMicros: 28000000,
        periodType: 'monthly',
        rollover: false,
        active: true,
        createdAt: DateTime(2026, 10, 5),
        updatedAt: DateTime(2026, 10, 5),
      );
      final recap = buildYearRecap(
        year: 2026,
        transactions: [
          tx('a', 'food', 3000, DateTime(2026, 10, 3)),
          tx('b', 'food', 1000, DateTime(2026, 11, 3)),
        ],
        recurring: const [],
        goals: const [],
        budgets: [budget],
        now: DateTime(2026, 11, 20),
      );
      expect(recap.budgetMonths, 2);
      expect(recap.budgetMonthsKept, 1);
    });

    test('season and default year', () {
      expect(isRecapSeason(DateTime(2026, 12, 19)), isFalse);
      expect(isRecapSeason(DateTime(2026, 12, 20)), isTrue);
      expect(isRecapSeason(DateTime(2027, 1, 31)), isTrue);
      expect(isRecapSeason(DateTime(2027, 2, 1)), isFalse);
      expect(defaultRecapYear(DateTime(2027, 1, 10)), 2026);
      expect(defaultRecapYear(DateTime(2026, 12, 21)), 2026);
    });
  });

  group('recap screens', () {
    late AppDatabase database;
    final december = DateTime(2026, 12, 28, 10);

    Future<void> seed({bool previousYear = true}) async {
      final now = DateTime.now();
      SharedPreferences.setMockInitialValues({
        'base_currency_v1': 'EUR',
        'currency_rates_ecb_v1': jsonEncode({
          'rates': {'EUR': 1.0},
          'publishedAt': now.toIso8601String(),
          'fetchedAt': now.toIso8601String(),
        }),
      });
      database = AppDatabase.forTesting(NativeDatabase.memory());
      var id = 0;
      Future<void> add(
        String category,
        int amount,
        DateTime date, {
        bool income = false,
        String? note,
      }) => database.insertTransaction(
        TransactionsCompanion.insert(
          id: 'm${id++}',
          categoryId: category,
          amountCents: amount,
          isIncome: income,
          date: date,
          note: Value(note),
        ),
      );
      for (var month = 2; month <= 12; month++) {
        await add('salary', 210000, DateTime(2026, month, 27), income: true);
        await add('groceries', 30000 + month * 1000, DateTime(2026, month, 6));
        await add('food', 4000, DateTime(2026, month, 14));
      }
      await add('travel', 64000, DateTime(2026, 8, 3), note: 'Volo Tokyo');
      if (previousYear) {
        await add('groceries', 500000, DateTime(2025, 5, 6));
      }
      await database
          .into(database.savingsGoals)
          .insert(
            SavingsGoalsCompanion.insert(
              id: 'trip',
              name: 'Giappone',
              targetAmountMinor: 300000,
              targetEurMicros: 3000000000,
              currencyCode: 'EUR',
              icon: 0xe57f,
              savedAmountMinor: const Value(300000),
              color: 0xFF2F6BDE,
              createdAt: DateTime(2026, 2, 1),
              updatedAt: DateTime(2026, 2, 1),
            ),
          );
    }

    Widget app(Widget home, {bool dark = false, double scale = 1}) =>
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
            recapClockProvider.overrideWithValue(() => december),
          ],
          child: MaterialApp(
            locale: const Locale('it'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: home,
          ),
        );

    Future<void> size(WidgetTester tester, Size value) async {
      tester.view.physicalSize = value;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    Finder byKey(String key) => find.byKey(ValueKey(key));

    Future<void> next(WidgetTester tester) async {
      final stories = tester.getRect(byKey('recap-stories'));
      await tester.tapAt(Offset(stories.right - 20, stories.center.dy));
      await tester.pumpAndSettle();
    }

    testWidgets('every card renders, in order, and tapping left goes back', (
      tester,
    ) async {
      await seed();
      addTearDown(database.close);
      await size(tester, const Size(390, 844));
      await tester.pumpWidget(
        app(const YearRecapPage(year: 2026, autoAdvance: false)),
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Il tuo 2026', findRichText: true),
        findsOneWidget,
      );
      expect(find.text('Nel 2026 hai guadagnato'), findsOneWidget);
      expect(find.text(formatMoney(2310000, 'EUR', 'it')), findsOneWidget);

      final expected = [
        'Mese per mese',
        'Dove sono andati',
        'La spesa più grande',
        'Il tuo ritmo',
        'I tuoi obiettivi',
        'Rispetto al 2025',
      ];
      for (final title in expected) {
        await next(tester);
        expect(find.text(title), findsOneWidget, reason: title);
        expect(tester.takeException(), isNull, reason: title);
      }
      expect(find.text('Volo Tokyo'), findsNothing);
      // The last card stays put.
      await next(tester);
      expect(find.text('Rispetto al 2025'), findsOneWidget);
      final stories = tester.getRect(byKey('recap-stories'));
      await tester.tapAt(Offset(stories.left + 20, stories.center.dy));
      await tester.pumpAndSettle();
      expect(find.text('I tuoi obiettivi'), findsOneWidget);
      expect(find.text('1 raggiunto su 1'), findsOneWidget);
    });

    testWidgets('first year, dark theme, 320px and 150% text', (tester) async {
      await seed(previousYear: false);
      addTearDown(database.close);
      await size(tester, const Size(320, 640));
      await tester.pumpWidget(
        app(
          const YearRecapPage(year: 2026, autoAdvance: false),
          dark: true,
          scale: 1.5,
        ),
      );
      await tester.pumpAndSettle();
      for (var i = 0; i < 8; i++) {
        expect(tester.takeException(), isNull, reason: 'card $i');
        await next(tester);
      }
      expect(find.text('Il tuo primo anno'), findsOneWidget);
      expect(
        find.text('Hai iniziato a febbraio e non ti sei più fermato'),
        findsOneWidget,
      );
    });

    testWidgets('auto advance moves on and long press pauses', (tester) async {
      await seed();
      addTearDown(database.close);
      await size(tester, const Size(390, 844));
      await tester.pumpWidget(app(const YearRecapPage(year: 2026)));
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Nel 2026 hai guadagnato'), findsOneWidget);
      await tester.pump(YearRecapPage.cardDuration);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Mese per mese'), findsOneWidget);
      final gesture = await tester.startGesture(
        tester.getCenter(byKey('recap-stories')),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(YearRecapPage.cardDuration * 2);
      expect(find.text('Mese per mese'), findsOneWidget);
      await gesture.up();
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('share sheet hides amounts and copies the text', (
      tester,
    ) async {
      await seed();
      addTearDown(database.close);
      await size(tester, const Size(390, 900));
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String;
          }
          return null;
        },
      );
      await tester.pumpWidget(
        app(const YearRecapPage(year: 2026, autoAdvance: false)),
      );
      await tester.pumpAndSettle();
      await tester.tap(byKey('recap-share'));
      await tester.pumpAndSettle();
      expect(find.text('Condividi il tuo anno'), findsOneWidget);
      await tester.tap(byKey('recap-copy-text'));
      await tester.pumpAndSettle();
      expect(copied, contains('Il mio 2026 con Pockets Vault'));
      expect(copied, contains('€'));

      await tester.tap(byKey('recap-hide-amounts'));
      await tester.pumpAndSettle();
      expect(find.textContaining('vs 2025'), findsOneWidget);
      await tester.tap(byKey('recap-copy-text'));
      await tester.pumpAndSettle();
      expect(copied, contains('delle entrate'));
      expect(copied, isNot(contains('€')));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Home banner in season, dismissed per year; Stats entry', (
      tester,
    ) async {
      await seed();
      addTearDown(database.close);
      await size(tester, const Size(390, 844));
      await tester.pumpWidget(
        app(
          const Scaffold(
            body: Column(children: [YearRecapBanner(), YearRecapEntry()]),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(byKey('year-recap-banner'), findsOneWidget);
      expect(find.text('Il tuo 2026 in Pockets Vault'), findsOneWidget);
      expect(find.text('Rivivi l\'anno in 7 schede'), findsOneWidget);
      expect(byKey('stats-year-recap'), findsOneWidget);

      await tester.tap(byKey('year-recap-banner'));
      await tester.pumpAndSettle();
      expect(find.byType(YearRecapPage), findsOneWidget);
      await tester.tap(byKey('recap-close'));
      await tester.pumpAndSettle();

      await tester.tap(byKey('year-recap-banner-close'));
      await tester.pumpAndSettle();
      expect(byKey('year-recap-banner'), findsNothing);
      expect(
        (await SharedPreferences.getInstance()).getInt(recapBannerDismissedKey),
        2026,
      );
      // Still reachable from Statistics.
      expect(byKey('stats-year-recap'), findsOneWidget);
    });
  });
}
