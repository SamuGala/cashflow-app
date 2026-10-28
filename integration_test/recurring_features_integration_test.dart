import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pocket_vault/app/router.dart';
import 'package:pocket_vault/core/currency/currency_metadata.dart';
import 'package:pocket_vault/core/database/app_database.dart';
import 'package:pocket_vault/core/database/database_provider.dart';
import 'package:pocket_vault/core/providers/balance_visibility_provider.dart';
import 'package:pocket_vault/core/providers/time_filter_provider.dart';
import 'package:pocket_vault/core/security/auth_provider.dart';
import 'package:pocket_vault/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const capture = bool.fromEnvironment('CAPTURE_RELEASE');
  const prefix = String.fromEnvironment('SHOT_PREFIX', defaultValue: 'app');

  testWidgets('recurring schedules: labels, actions, generation and totals', (
    tester,
  ) async {
    final now = DateTime.now();
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

    // November 2030 is a fixed future month, so every occurrence in it is
    // still "upcoming" whatever today is. Weekly schedules start before the
    // 27 October 2030 daylight-saving change on purpose.
    Future<void> schedule(
      String id,
      int cents,
      bool income,
      String frequency,
      DateTime start, {
      int interval = 1,
      int? dayOfWeek,
      int? monthOfYear,
      DateTime? end,
      bool active = true,
    }) => database
        .into(database.recurringTransactions)
        .insert(
          RecurringTransaction(
            id: id,
            amountCents: cents,
            isIncome: income,
            categoryId: income ? 'salary' : 'bills',
            dayOfMonth: start.day,
            startDate: start,
            active: active,
            frequency: frequency,
            interval: interval,
            dayOfWeek: dayOfWeek,
            monthOfYear: monthOfYear,
            endDate: end,
          ),
        );
    await schedule('salary', 200000, true, 'monthly', DateTime(2030, 9, 27));
    await schedule(
      'freelance',
      10000,
      true,
      'weekly',
      DateTime(2030, 10, 1),
      interval: 2,
      dayOfWeek: DateTime.friday,
    );
    await schedule(
      'gym',
      1500,
      false,
      'weekly',
      DateTime(2030, 10, 1),
      dayOfWeek: DateTime.monday,
    );
    await schedule(
      'insurance',
      30000,
      false,
      'yearly',
      DateTime(2029, 11, 15),
      monthOfYear: 11,
    );
    await schedule(
      'water',
      5000,
      false,
      'monthly',
      DateTime(2030, 9, 10),
      interval: 2,
    );
    await schedule(
      'coffee',
      150,
      false,
      'daily',
      DateTime(2030, 11, 20),
      end: DateTime(2030, 11, 25),
    );
    await schedule(
      'paused',
      99900,
      false,
      'monthly',
      DateTime(2030, 1, 5),
      active: false,
    );
    await schedule(
      'ended',
      77700,
      false,
      'monthly',
      DateTime(2030, 1, 5),
      end: DateTime(2030, 10, 31),
    );
    // A past schedule the app must catch up on at startup, once per month.
    final rentStart = DateTime(now.year, now.month - 2, 1);
    await schedule(
      'rent',
      85000,
      false,
      'monthly',
      rentStart,
      end: DateTime(now.year, now.month + 1, 0),
    );

    container.read(authProvider.notifier).unlock();
    container.read(balanceVisibilityProvider.notifier).show();
    container.read(timeFilterProvider.notifier).setMonth(DateTime(2030, 11));
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const RootApp()),
    );
    await tester.pumpAndSettle();
    if (capture) {
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
    }

    final rent = (await database.getAllTransactions())
        .where((t) => t.recurringSourceId == 'rent')
        .map((t) => t.date)
        .toList();
    expect(rent, hasLength(3));
    expect(rent.toSet(), {
      for (var i = 0; i < 3; i++) DateTime(now.year, now.month - 2 + i, 1),
    });

    const incomeKey = ValueKey('upcoming-income-total');
    const expenseKey = ValueKey('upcoming-expense-total');
    String? shown(ValueKey<String> key) =>
        tester.widget<Text>(find.byKey(key)).data;
    String money(int cents) => formatMoney(cents, 'EUR', 'it');
    // Income: salary 2.000 + freelance on 1, 15 and 29 November.
    // Expenses: gym on 4 Mondays (60), insurance (300), water (50),
    // coffee 20–25 November (9). Paused and ended schedules are excluded.
    expect(shown(incomeKey), '+${money(230000)}');
    expect(shown(expenseKey), '-${money(41900)}');
    if (capture) await binding.takeScreenshot('$prefix-r1-home-upcoming');

    Future<void> openRecurring() async {
      appRouter.go('/transactions');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ricorrenti'));
      await tester.pumpAndSettle();
    }

    await openRecurring();
    for (final label in [
      'Ogni mese · 27',
      'Ogni 2 settimane · venerdì',
      'Ogni settimana · lunedì',
      'Ogni anno · 15 nov',
      'Ogni 2 mesi · 10',
      'Ogni giorno',
    ]) {
      await tester.scrollUntilVisible(
        find.text(label),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text(label), findsOneWidget, reason: label);
    }
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('salary')),
      -400,
      scrollable: find.byType(Scrollable).last,
    );
    if (capture) await binding.takeScreenshot('$prefix-r2-recurring-list');

    Future<void> swipe(String id, Offset offset) async {
      final row = find.byKey(ValueKey(id));
      await tester.scrollUntilVisible(
        row,
        200,
        scrollable: find.byType(Scrollable).last,
      );
      // Dismiss thresholds scale with the row, which is wide on tablets.
      await tester.drag(row, offset * (tester.getSize(row).width / 500));
      await tester.pumpAndSettle();
    }

    Future<void> settleSnackBar() async {
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    }

    // Pause and resume.
    await swipe('gym', const Offset(300, 0));
    await tester.tap(find.text('Metti in pausa'));
    await tester.pumpAndSettle();
    await settleSnackBar();
    appRouter.go('/dashboard');
    await tester.pumpAndSettle();
    expect(shown(expenseKey), '-${money(35900)}');
    await openRecurring();
    await swipe('gym', const Offset(300, 0));
    await tester.tap(find.text('Riattiva'));
    await tester.pumpAndSettle();
    await settleSnackBar();

    // Delete, then undo.
    await swipe('insurance', const Offset(-300, 0));
    await tester.tap(find.text('Elimina'));
    await tester.pumpAndSettle();
    expect(
      (await database.select(database.recurringTransactions).get()).map(
        (r) => r.id,
      ),
      isNot(contains('insurance')),
    );
    appRouter.go('/dashboard');
    await tester.pumpAndSettle();
    expect(shown(expenseKey), '-${money(11900)}');
    await openRecurring();
    await tester.tap(find.text('Annulla'));
    await tester.pumpAndSettle();
    await settleSnackBar();
    appRouter.go('/dashboard');
    await tester.pumpAndSettle();
    expect(shown(expenseKey), '-${money(41900)}');

    // Create a monthly expense through the quick-add sheet.
    await tester.tap(find.byKey(const ValueKey('add-transaction-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('0,00'));
    await tester.pumpAndSettle();
    for (final key in ['1', '2', '00']) {
      final button = find.byKey(ValueKey('quick-amount-key-$key'));
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pump();
    }
    await tester.tap(find.text('Conferma'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ActionChip, 'Bollette'));
    await tester.pumpAndSettle();
    final toggle = find.byType(Switch).last;
    await tester.ensureVisible(toggle);
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Spotify');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    if (capture) await binding.takeScreenshot('$prefix-r3-quick-add-recurring');
    final save = find.text('Salva movimento');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    await settleSnackBar();
    final created =
        (await database.select(database.recurringTransactions).get())
            .where((r) => r.note == 'Spotify')
            .single;
    expect(created.frequency, 'monthly');
    expect(created.amountCents, 1200);
    expect(created.dayOfMonth, now.day);
    expect(shown(expenseKey), '-${money(43100)}');

    // The current month shows only what is still due after today.
    container
        .read(timeFilterProvider.notifier)
        .setMonth(DateTime(now.year, now.month));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    if (capture) await binding.takeScreenshot('$prefix-r4-home-current-month');

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
