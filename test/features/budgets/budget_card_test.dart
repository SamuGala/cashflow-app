import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_vault/app/theme/app_theme.dart';
import 'package:pocket_vault/core/currency/currency_metadata.dart';
import 'package:pocket_vault/core/database/app_database.dart';
import 'package:pocket_vault/core/database/database_provider.dart';
import 'package:pocket_vault/core/providers/balance_visibility_provider.dart';
import 'package:pocket_vault/features/budgets/presentation/budget_card.dart';
import 'package:pocket_vault/features/budgets/providers/budget_provider.dart';
import 'package:pocket_vault/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    final now = DateTime.now().toIso8601String();
    SharedPreferences.setMockInitialValues({
      'base_currency_v1': 'EUR',
      'currency_rates_ecb_v1': jsonEncode({
        'rates': {'EUR': 1.0},
        'publishedAt': now,
        'fetchedAt': now,
      }),
    });
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  Widget app({
    int income = 200000,
    int expenses = 40000,
    String locale = 'it',
    double textScale = 1,
    Brightness brightness = Brightness.light,
  }) => ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(database),
      budgetOverviewProvider.overrideWithValue(
        AsyncData(
          BudgetOverview(
            incomeMinor: 0,
            expenseMinor: 0,
            upcomingRecurringIncomeMinor: income,
            upcomingRecurringExpensesMinor: expenses,
            reservedSavingsMinor: 0,
            budgets: const [],
          ),
        ),
      ),
    ],
    child: MaterialApp(
      locale: Locale(locale),
      supportedLocales: const [Locale('en'), Locale('it'), Locale('es')],
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: brightness == Brightness.dark
          ? AppTheme.darkTheme
          : AppTheme.lightTheme,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: const Scaffold(
        body: SingleChildScrollView(
          child: Padding(padding: EdgeInsets.all(16), child: BudgetCard()),
        ),
      ),
    ),
  );

  const incomeKey = ValueKey('upcoming-income-total');
  const expenseKey = ValueKey('upcoming-expense-total');
  const summaryKey = ValueKey('upcoming-transactions-summary');

  testWidgets('shows signed totals together and hides amounts accessibly', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      expect(find.text('Transazioni in arrivo'), findsOneWidget);
      for (final key in [incomeKey, expenseKey]) {
        final text = tester.widget<Text>(find.byKey(key));
        expect(text.data, '••••');
        expect(text.semanticsLabel, endsWith('••••'));
      }

      await tester.tap(find.byTooltip('Mostra importi'));
      await tester.pumpAndSettle();

      final income = tester.widget<Text>(find.byKey(incomeKey));
      final expense = tester.widget<Text>(find.byKey(expenseKey));
      expect(income.data, '+${formatMoney(200000, 'EUR', 'it')}');
      expect(expense.data, '-${formatMoney(40000, 'EUR', 'it')}');
      expect(income.semanticsLabel, startsWith('Entrate:'));
      expect(expense.semanticsLabel, startsWith('Uscite:'));
      expect(
        tester.getTopRight(find.byKey(expenseKey)).dx,
        closeTo(tester.getTopRight(find.byKey(summaryKey)).dx, .01),
      );
      expect(
        find.descendant(
          of: find.byKey(summaryKey),
          matching: find.byType(Text),
        ),
        findsNWidgets(3),
      );

      final container = ProviderScope.containerOf(
        tester.element(find.byType(BudgetCard)),
      );
      expect(container.read(balanceVisibilityProvider), isTrue);
      await tester.tap(find.byTooltip('Nascondi importi'));
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(find.byKey(incomeKey)).data, '••••');
      expect(tester.widget<Text>(find.byKey(expenseKey)).data, '••••');
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('income-only recurrences are visible', (tester) async {
    await tester.pumpWidget(app(expenses: 0));
    await tester.pumpAndSettle();
    expect(find.byKey(summaryKey), findsOneWidget);
    expect(find.byKey(incomeKey), findsOneWidget);
    expect(find.byKey(expenseKey), findsNothing);
  });

  testWidgets('expense-only recurrences show a negative total', (tester) async {
    await tester.pumpWidget(app(income: 0));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Mostra importi'));
    await tester.pumpAndSettle();
    expect(find.byKey(incomeKey), findsNothing);
    expect(
      tester.widget<Text>(find.byKey(expenseKey)).data,
      '-${formatMoney(40000, 'EUR', 'it')}',
    );
  });

  testWidgets('no upcoming recurrences hides the summary', (tester) async {
    await tester.pumpWidget(app(income: 0, expenses: 0));
    await tester.pumpAndSettle();
    expect(find.byKey(summaryKey), findsNothing);
  });

  testWidgets('summary fits compact screens in every locale and theme', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const labels = {
      'it': 'Transazioni in arrivo',
      'en': 'Upcoming transactions',
      'es': 'Próximas transacciones',
    };
    for (final entry in labels.entries) {
      for (final brightness in Brightness.values) {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpWidget(
          app(
            income: 123456789,
            expenses: 98765432,
            locale: entry.key,
            textScale: 1.5,
            brightness: brightness,
          ),
        );
        await tester.pumpAndSettle();
        final container = ProviderScope.containerOf(
          tester.element(find.byType(BudgetCard)),
        );
        container.read(balanceVisibilityProvider.notifier).show();
        await tester.pumpAndSettle();

        expect(find.text(entry.value), findsOneWidget);
        expect(find.byKey(incomeKey), findsOneWidget);
        expect(find.byKey(expenseKey), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    }
  });
}
