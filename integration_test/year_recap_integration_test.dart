import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pocket_vault/core/database/app_database.dart';
import 'package:pocket_vault/core/database/database_provider.dart';
import 'package:pocket_vault/core/providers/balance_visibility_provider.dart';
import 'package:pocket_vault/core/security/auth_provider.dart';
import 'package:pocket_vault/features/recap/presentation/year_recap_page.dart';
import 'package:pocket_vault/features/settings/presentation/providers/theme_provider.dart';
import 'package:pocket_vault/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const capture = bool.fromEnvironment('CAPTURE_REDESIGN');

  testWidgets('year recap from the Home banner and from Statistics', (
    tester,
  ) async {
    final now = DateTime.now();
    final year = now.year;
    // The recap season: late December of the current year.
    final december = DateTime(year, 12, 28, 10);
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
      overrides: [
        databaseProvider.overrideWithValue(database),
        recapClockProvider.overrideWithValue(() => december),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await database.close();
    });
    var serial = 0;
    Future<void> add(
      String category,
      int amount,
      DateTime date, {
      bool income = false,
      String? note,
      String? source,
    }) => database.insertTransaction(
      TransactionsCompanion.insert(
        id: 'y${serial++}',
        categoryId: category,
        amountCents: amount,
        isIncome: income,
        date: date,
        note: Value(note),
        recurringSourceId: Value(source),
        recurringOccurrenceKey: Value(
          source == null ? null : '$source:${date.toIso8601String()}',
        ),
      ),
    );
    const groceries = [
      28400, 26100, 30200, 27500, 29800, 31200, //
      24500, 38900, 27100, 29900, 28800, 35200,
    ];
    for (var month = 1; month <= 12; month++) {
      await add('salary', 215000, DateTime(year, month, 27), income: true);
      await add('rent', 75000, DateTime(year, month, 1), source: 'rent');
      await add(
        'entertainment',
        1399,
        DateTime(year, month, 12),
        source: 'netflix',
      );
      await add('bills', 6200 + month * 150, DateTime(year, month, 18));
      await add('groceries', groceries[month - 1], DateTime(year, month, 8));
      await add('food', 2400 + month * 90, DateTime(year, month, 15));
      await add('transport', 3500, DateTime(year, month, 3));
      if (month.isEven) {
        await add('shopping', 4900 + month * 600, DateTime(year, month, 21));
      }
    }
    await add('travel', 84500, DateTime(year, 8, 4), note: 'Volo per Tokyo');
    await add('gift', 30000, DateTime(year, 12, 20), income: true);
    for (var month = 1; month <= 12; month++) {
      await add('groceries', 39000, DateTime(year - 1, month, 8));
      await add('rent', 75000, DateTime(year - 1, month, 1));
      await add('salary', 200000, DateTime(year - 1, month, 27), income: true);
    }
    for (final (id, amount, category, note) in [
      ('rent', 75000, 'rent', 'Affitto'),
      ('netflix', 1399, 'entertainment', 'Netflix'),
    ]) {
      await database
          .into(database.recurringTransactions)
          .insert(
            RecurringTransaction(
              id: id,
              amountCents: amount,
              isIncome: false,
              categoryId: category,
              dayOfMonth: id == 'rent' ? 1 : 12,
              startDate: DateTime(year, 1, 1),
              note: note,
              active: true,
              frequency: 'monthly',
              interval: 1,
            ),
          );
    }
    for (final (id, name, target, saved, color) in [
      ('japan', 'Viaggio in Giappone', 300000, 300000, 0xFF2F6BDE),
      ('fund', 'Fondo emergenze', 500000, 310000, 0xFF17734E),
      ('bike', 'Bici nuova', 120000, 42000, 0xFFE29A12),
    ]) {
      await database
          .into(database.savingsGoals)
          .insert(
            SavingsGoalsCompanion.insert(
              id: id,
              name: name,
              targetAmountMinor: target,
              targetEurMicros: target * 10000,
              savedAmountMinor: Value(saved),
              currencyCode: 'EUR',
              icon: 0xe57f,
              color: color,
              createdAt: DateTime(year, 1, 10),
              updatedAt: DateTime(year, 1, 10),
            ),
          );
    }

    container.read(authProvider.notifier).unlock();
    container.read(balanceVisibilityProvider.notifier).show();
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const RootApp()),
    );
    await tester.pumpAndSettle();
    if (capture) {
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
    }
    Future<void> shot(String name) async {
      await tester.pumpAndSettle();
      if (capture) await binding.takeScreenshot('recap-$name');
    }

    Finder byKey(String key) => find.byKey(ValueKey(key));

    // Home banner in season.
    expect(byKey('year-recap-banner'), findsOneWidget);
    await shot('00-home-banner');
    await tester.tap(byKey('year-recap-banner'));
    await tester.pump(const Duration(milliseconds: 500));
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // Each card, captured once its numbers have counted up.
    // The story timer never settles, so draw frames until the card's
    // count-up and bars have finished.
    Future<void> settleCard() async {
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 40));
      }
    }

    Future<void> nextCard() async {
      final stories = tester.getRect(byKey('recap-stories'));
      await tester.tapAt(Offset(stories.right - 24, stories.center.dy));
      await tester.pump(const Duration(milliseconds: 400));
      await settleCard();
    }

    await settleCard();
    final titles = [
      'Nel $year hai guadagnato',
      'Mese per mese',
      'Dove sono andati',
      'La spesa più grande',
      'Il tuo ritmo',
      'Le tue ricorrenze',
      'I tuoi obiettivi',
      'Rispetto al ${year - 1}',
    ];
    for (final (index, title) in titles.indexed) {
      if (index > 0) await nextCard();
      expect(find.text(title), findsOneWidget, reason: title);
      if (capture) {
        await binding.takeScreenshot(
          'recap-${(index + 1).toString().padLeft(2, '0')}',
        );
      }
    }
    expect(find.text('Volo per Tokyo'), findsNothing);
    expect(tester.takeException(), isNull);

    // Share sheet, with and without amounts. Auto-advance is paused.
    await tester.tap(byKey('recap-share'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Condividi il tuo anno'), findsOneWidget);
    if (capture) await binding.takeScreenshot('recap-09-share');
    await tester.tap(byKey('recap-hide-amounts'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.textContaining('vs ${year - 1}'), findsOneWidget);
    if (capture) await binding.takeScreenshot('recap-10-share-hidden');
    await tester.tapAt(const Offset(20, 60));
    await tester.pump(const Duration(milliseconds: 600));

    // Dark theme: go back to the categories card.
    await container.read(themeProvider.notifier).setTheme(AppThemeMode.dark);
    final stories = tester.getRect(byKey('recap-stories'));
    for (var i = 0; i < 5; i++) {
      await tester.tapAt(Offset(stories.left + 24, stories.center.dy));
      await tester.pump(const Duration(milliseconds: 400));
    }
    await settleCard();
    expect(find.text('Dove sono andati'), findsOneWidget);
    if (capture) await binding.takeScreenshot('recap-11-dark');
    await tester.tap(byKey('recap-close'));
    await tester.pump(const Duration(milliseconds: 600));
    await container.read(themeProvider.notifier).setTheme(AppThemeMode.light);
    await tester.pumpAndSettle();

    // Also reachable from Statistics, all year round.
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Statistiche'),
      ),
    );
    await tester.pumpAndSettle();
    expect(byKey('stats-year-recap'), findsOneWidget);
    await shot('12-stats-entry');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
