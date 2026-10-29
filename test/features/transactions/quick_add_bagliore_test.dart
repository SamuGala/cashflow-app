import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_vault/app/theme/app_theme.dart';
import 'package:pocket_vault/core/database/app_database.dart';
import 'package:pocket_vault/core/database/database_provider.dart';
import 'package:pocket_vault/features/transactions/presentation/quick_add_transaction_sheet.dart';
import 'package:pocket_vault/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase database;

  Future<void> pumpSheet(WidgetTester tester, {bool dark = false}) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
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
    addTearDown(database.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          locale: const Locale('it'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: FilledButton(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => const QuickAddTransactionSheet(),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> typeAmount(WidgetTester tester, List<String> keys) async {
    for (final key in keys) {
      final button = find.byKey(ValueKey('quick-amount-key-$key'));
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  Future<void> tapKey(WidgetTester tester, String key) async {
    final target = find.byKey(ValueKey(key));
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  testWidgets('carousel scrolls every category and ends with New category', (
    tester,
  ) async {
    await pumpSheet(tester);
    final expenses = (await database.select(database.categories).get())
        .where((row) => !row.isIncome)
        .toList();
    final carousel = find.byKey(const ValueKey('quick-category-carousel'));
    expect(carousel, findsOneWidget);
    // Every category is reachable by swiping, and the New tile comes last.
    final seen = <String>{};
    final newTile = find.byKey(const ValueKey('quick-category-new'));
    for (var i = 0; i < 40 && newTile.evaluate().isEmpty; i++) {
      for (final element
          in find
              .byWidgetPredicate(
                (w) =>
                    w.key is ValueKey<String> &&
                    (w.key! as ValueKey<String>).value.startsWith(
                      'quick-category-',
                    ),
              )
              .evaluate()) {
        seen.add((element.widget.key! as ValueKey<String>).value);
      }
      await tester.drag(carousel, const Offset(-120, 0));
      await tester.pumpAndSettle();
    }
    expect(newTile, findsOneWidget);
    for (final element
        in find
            .byWidgetPredicate(
              (w) =>
                  w.key is ValueKey<String> &&
                  (w.key! as ValueKey<String>).value.startsWith(
                    'quick-category-',
                  ),
            )
            .evaluate()) {
      seen.add((element.widget.key! as ValueKey<String>).value);
    }
    expect(
      seen,
      containsAll([for (final row in expenses) 'quick-category-${row.id}']),
    );
    // Nothing follows the New tile.
    await tester.drag(carousel, const Offset(-600, 0));
    await tester.pumpAndSettle();
    final carouselRect = tester.getRect(carousel);
    expect(
      tester.getRect(newTile).right,
      lessThanOrEqualTo(carouselRect.right + 1),
    );

    // Creating a category from the last tile selects it, as before.
    await tester.tap(find.byKey(const ValueKey('quick-category-new')));
    await tester.pumpAndSettle();
    expect(find.text('Nuova categoria'), findsWidgets);
    await tester.enterText(find.byType(TextField).last, 'Palestra');
    await tester.tap(find.text('Salva categoria'));
    await tester.pumpAndSettle();
    final created = (await database.select(database.categories).get())
        .singleWhere((row) => row.name == 'Palestra');
    // The new category is selected and scrolled into view.
    final createdTile = find.byKey(ValueKey('quick-category-${created.id}'));
    expect(createdTile, findsOneWidget);
    final view = tester.getRect(carousel);
    final tile = tester.getRect(createdTile);
    expect(
      tile.left >= view.left - 4 && tile.right <= view.right + 4,
      isTrue,
      reason: "$tile in $view",
    );
    await typeAmount(tester, ['4', '5', '0', '0']);
    await tapKey(tester, 'quick-save');
    final rows = await database.getAllTransactions();
    expect(rows.single.categoryId, created.id);
    expect(rows.single.amountCents, 4500);
    expect(tester.takeException(), isNull);
  });

  testWidgets('note and date pills edit the movement', (tester) async {
    await pumpSheet(tester);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('quick-date')),
        matching: find.text('Oggi'),
      ),
      findsOneWidget,
    );
    await tapKey(tester, 'quick-note');
    await tester.enterText(
      find.byKey(const ValueKey('quick-note-field')),
      'Cena da Gino',
    );
    await tester.tap(find.byKey(const ValueKey('quick-note-done')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('quick-note')),
        matching: find.text('Cena da Gino'),
      ),
      findsOneWidget,
    );

    await tapKey(tester, 'quick-date');
    expect(find.byType(DatePickerDialog), findsOneWidget);
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    if (yesterday.month == DateTime.now().month) {
      await tester.tap(find.text('${yesterday.day}').last);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('quick-date')),
          matching: find.text('Ieri'),
        ),
        findsOneWidget,
      );
    } else {
      await tester.tap(find.text('Annulla').last);
      await tester.pumpAndSettle();
    }

    await tapKey(tester, 'quick-category-food');
    await typeAmount(tester, ['1', '2', '5', '0']);
    await tapKey(tester, 'quick-save');
    final row = (await database.getAllTransactions()).single;
    expect(row.note, 'Cena da Gino');
    expect(row.amountCents, 1250);
    expect(row.categoryId, 'food');
    if (yesterday.month == DateTime.now().month) {
      expect(row.date.day, yesterday.day);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('repeat pill opens the recurrence options and saves them', (
    tester,
  ) async {
    await pumpSheet(tester, dark: true);
    await tapKey(tester, 'quick-repeat');
    expect(
      find.byKey(const ValueKey('quick-recurring-switch')),
      findsOneWidget,
    );
    // Options appear only once the recurrence is switched on.
    expect(
      find.byKey(const ValueKey('quick-recurring-interval')),
      findsNothing,
    );
    await tester.tap(find.byKey(const ValueKey('quick-recurring-switch')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('quick-recurring-interval')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('quick-recurring-frequency')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settimane').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('quick-recurring-done')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('quick-repeat')),
        matching: find.textContaining('2'),
      ),
      findsOneWidget,
    );

    // Reopening keeps the chosen values.
    await tapKey(tester, 'quick-repeat');
    expect(
      tester
          .widget<Switch>(find.byKey(const ValueKey('quick-recurring-switch')))
          .value,
      isTrue,
    );
    await tester.tap(find.byKey(const ValueKey('quick-recurring-done')));
    await tester.pumpAndSettle();

    await tapKey(tester, 'quick-category-bills');
    await typeAmount(tester, ['9', '9', '0']);
    await tapKey(tester, 'quick-save');
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    final recurring = await database
        .select(database.recurringTransactions)
        .get();
    expect(recurring.single.frequency, 'weekly');
    expect(recurring.single.interval, 2);
    expect(recurring.single.dayOfWeek, DateTime.now().weekday);
    expect(recurring.single.amountCents, 990);
    expect(tester.takeException(), isNull);
  });

  testWidgets('save without amount or category shakes and keeps the sheet', (
    tester,
  ) async {
    await pumpSheet(tester);
    await tapKey(tester, 'quick-save');
    expect(find.byType(QuickAddTransactionSheet), findsOneWidget);
    expect(await database.getAllTransactions(), isEmpty);
    await tapKey(tester, 'quick-add-close');
    expect(find.byType(QuickAddTransactionSheet), findsNothing);
  });
}
