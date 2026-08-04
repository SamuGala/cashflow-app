import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_vault/core/database/app_database.dart';
import 'package:pocket_vault/core/database/database_provider.dart';
import 'package:pocket_vault/features/budgets/presentation/budget_card.dart';
import 'package:pocket_vault/features/forecast/presentation/cashflow_forecast_card.dart';
import 'package:pocket_vault/features/goals/presentation/savings_goals_card.dart';
import 'package:pocket_vault/l10n/app_localizations.dart';
import 'package:pocket_vault/core/utils/category_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase database;

  setUp(() {
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
  });

  tearDown(() => database.close());

  Widget app(Widget child, {Locale locale = const Locale('it')}) {
    return ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: MaterialApp(
        locale: locale,
        supportedLocales: const [Locale('en'), Locale('it'), Locale('es')],
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(body: child),
      ),
    );
  }

  testWidgets('budget dialog survives cancel and creates a budget', (
    tester,
  ) async {
    await tester.pumpWidget(app(const BudgetManagerSheet()));
    await tester.pumpAndSettle();

    expect(find.byIcon(categoryIcon('food')), findsOneWidget);

    await tester.tap(find.text('Cibo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Annulla'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Cibo'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '100');
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();

    expect(await database.select(database.budgets).get(), hasLength(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('goal flow survives cancel and creates a savings goal', (
    tester,
  ) async {
    await tester.pumpWidget(app(const SavingsGoalsSheet()));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Nuovo obiettivo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Annulla'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.widgetWithText(FilledButton, 'Nuovo obiettivo'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'vacanza');
    await tester.tap(find.text('Continua'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '500');
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();

    final goals = await database.select(database.savingsGoals).get();
    expect(goals, hasLength(1));
    expect(goals.single.name, 'Vacanza');

    await tester.tap(find.text('Accantona'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '100');
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();

    var updatedGoal = await database.select(database.savingsGoals).getSingle();
    var contributions = await database
        .select(database.savingsGoalContributions)
        .get();
    expect(updatedGoal.savedAmountMinor, 10000);
    expect(contributions.single.amountMinor, 10000);

    await tester.tap(find.text('Sblocca fondi'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '50');
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();

    updatedGoal = await database.select(database.savingsGoals).getSingle();
    contributions = await database
        .select(database.savingsGoalContributions)
        .get();
    expect(updatedGoal.savedAmountMinor, 5000);
    expect(contributions, hasLength(2));
    expect(
      contributions.fold<int>(0, (sum, row) => sum + row.amountMinor),
      5000,
    );

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Elimina'));
    await tester.pumpAndSettle();

    updatedGoal = await database.select(database.savingsGoals).getSingle();
    contributions = await database
        .select(database.savingsGoalContributions)
        .get();
    expect(updatedGoal.archived, isTrue);
    expect(updatedGoal.savedAmountMinor, 0);
    expect(contributions, hasLength(3));
    expect(contributions.fold<int>(0, (sum, row) => sum + row.amountMinor), 0);

    await tester.tap(find.text('Annulla').last);
    await tester.pumpAndSettle();

    updatedGoal = await database.select(database.savingsGoals).getSingle();
    contributions = await database
        .select(database.savingsGoalContributions)
        .get();
    expect(updatedGoal.archived, isFalse);
    expect(updatedGoal.savedAmountMinor, 5000);
    expect(contributions, hasLength(2));
    expect(
      contributions.fold<int>(0, (sum, row) => sum + row.amountMinor),
      5000,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('new dashboard finance panels follow IT EN and ES locales', (
    tester,
  ) async {
    const expectations = {
      'it': ['Disponibile questo mese', 'Previsione ricorrenze'],
      'en': ['Available this month', 'Recurring forecast'],
      'es': ['Disponible este mes', 'Previsión de recurrencias'],
    };

    for (final entry in expectations.entries) {
      await tester.pumpWidget(
        app(
          ListView(children: const [BudgetCard(), CashflowForecastCard()]),
          locale: Locale(entry.key),
        ),
      );
      await tester.pumpAndSettle();

      for (final label in entry.value) {
        expect(find.text(label), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('forecast keeps four visible rows and scrolls every occurrence', (
    tester,
  ) async {
    final now = DateTime.now();
    await database
        .into(database.recurringTransactions)
        .insert(
          RecurringTransaction(
            id: 'weekly-expense',
            amountCents: 1200,
            isIncome: false,
            categoryId: 'food',
            dayOfMonth: now.day,
            startDate: now.subtract(const Duration(days: 30)),
            note: 'Weekly expense',
            active: true,
            frequency: 'weekly',
            interval: 1,
            dayOfWeek: now.weekday,
          ),
        );

    await tester.pumpWidget(app(const CashflowForecastCard()));
    await tester.pumpAndSettle();

    final scrollbarFinder = find.byType(Scrollbar);
    expect(scrollbarFinder, findsOneWidget);
    final scrollbar = tester.widget<Scrollbar>(scrollbarFinder);
    expect(scrollbar.thumbVisibility, isTrue);
    expect(tester.getSize(scrollbarFinder).height, 176);

    final scrollable = tester.state<ScrollableState>(
      find.descendant(of: scrollbarFinder, matching: find.byType(Scrollable)),
    );
    expect(scrollable.position.maxScrollExtent, greaterThan(0));
    await tester.drag(
      find.descendant(of: scrollbarFinder, matching: find.byType(ListView)),
      const Offset(0, -120),
    );
    await tester.pumpAndSettle();
    expect(scrollable.position.pixels, greaterThan(0));
    expect(tester.takeException(), isNull);
  });
}
