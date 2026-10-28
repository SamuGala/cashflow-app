import 'dart:async';
import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_vault/core/currency/currency_provider.dart';
import 'package:pocket_vault/core/database/app_database.dart';
import 'package:pocket_vault/core/database/database_provider.dart';
import 'package:pocket_vault/core/providers/time_filter_provider.dart';
import 'package:pocket_vault/features/budgets/providers/budget_provider.dart';
import 'package:pocket_vault/features/transactions/domain/transaction.dart';
import 'package:pocket_vault/features/transactions/providers/recurring_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase database;
  late ProviderContainer container;
  late DateTime month;

  setUp(() async {
    final now = DateTime.now();
    month = DateTime(now.year, now.month + 1);
    SharedPreferences.setMockInitialValues({
      'base_currency_v1': 'EUR',
      'currency_rates_ecb_v1': jsonEncode({
        'rates': {'EUR': 1.0, 'USD': 2.0, 'JPY': 160.0},
        'publishedAt': now.toIso8601String(),
        'fetchedAt': now.toIso8601String(),
      }),
    });
    database = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    container.read(timeFilterProvider.notifier).setMonth(month);
    for (final entry in [
      ('salary', 200000, true),
      ('other-income', 100000, true),
      ('rent', 40000, false),
    ]) {
      await database
          .into(database.recurringTransactions)
          .insert(
            RecurringTransaction(
              id: entry.$1,
              amountCents: entry.$2,
              isIncome: entry.$3,
              categoryId: entry.$3 ? 'salary' : 'rent',
              dayOfMonth: 20,
              startDate: month,
              active: true,
              frequency: 'monthly',
              interval: 1,
              eurAmountMicros: entry.$2 * 10000,
            ),
          );
    }
    container.listen(budgetOverviewProvider, (_, _) {});
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  Future<BudgetOverview> overview() async {
    await container.pump();
    final ready = Completer<BudgetOverview>();
    final subscription = container.listen(budgetOverviewProvider, (_, next) {
      if (next.isLoading || ready.isCompleted) return;
      next.when(
        data: ready.complete,
        error: ready.completeError,
        loading: () {},
      );
    }, fireImmediately: true);
    try {
      return await ready.future.timeout(const Duration(seconds: 10));
    } finally {
      subscription.close();
    }
  }

  test(
    'totals react to pause, resume, delete, undo and amount edits',
    () async {
      expect((await overview()).upcomingRecurringIncomeMinor, 300000);
      expect((await overview()).upcomingRecurringExpensesMinor, 40000);
      final notifier = container.read(recurringProvider.notifier);
      await notifier.toggleActive('salary', false);
      expect((await overview()).upcomingRecurringIncomeMinor, 100000);
      await notifier.toggleActive('salary', true);
      expect((await overview()).upcomingRecurringIncomeMinor, 300000);
      final rent = (await container.read(
        recurringProvider.future,
      )).singleWhere((r) => r.id == 'rent');
      await notifier.deleteRecurring('rent');
      expect((await overview()).upcomingRecurringExpensesMinor, 0);
      await notifier.restoreRecurring(rent);
      expect((await overview()).upcomingRecurringExpensesMinor, 40000);
      await notifier.updateRecurring(
        id: 'salary',
        amountCents: 60000,
        currencyCode: 'USD',
        categoryId: 'salary',
        dayOfMonth: 20,
      );
      expect((await overview()).upcomingRecurringIncomeMinor, 130000);
      expect((await overview()).incomeMinor, 0);
    },
  );

  test(
    'changing base currency revalues both totals, including zero decimals',
    () async {
      await overview();
      await container.read(currencyProvider.notifier).setBaseCurrency('USD');
      var value = await overview();
      expect(value.upcomingRecurringIncomeMinor, 600000);
      expect(value.upcomingRecurringExpensesMinor, 80000);
      await container.read(currencyProvider.notifier).setBaseCurrency('JPY');
      value = await overview();
      expect(value.upcomingRecurringIncomeMinor, 480000);
      expect(value.upcomingRecurringExpensesMinor, 64000);
    },
  );

  test(
    'switching month, total and single-day period refreshes totals',
    () async {
      await overview();
      final filter = container.read(timeFilterProvider.notifier);
      filter.setFilter(TimeFilter.total);
      expect((await overview()).upcomingRecurringIncomeMinor, 0);
      expect((await overview()).upcomingRecurringExpensesMinor, 0);
      filter.setPeriod(
        DateTime(month.year, month.month, 20),
        DateTime(month.year, month.month, 20),
      );
      expect((await overview()).upcomingRecurringIncomeMinor, 300000);
      expect((await overview()).upcomingRecurringExpensesMinor, 40000);
      filter.setPeriod(
        DateTime(month.year, month.month, 21),
        DateTime(month.year, month.month, 21),
      );
      expect((await overview()).upcomingRecurringIncomeMinor, 0);
    },
  );

  test(
    'generated movements replace upcoming amounts without double counting',
    () async {
      // Use fixed dates to verify the boundary independently of the system clock.
      await database.clearAllData();
      for (final isIncome in [true, false]) {
        await database
            .into(database.recurringTransactions)
            .insert(
              RecurringTransaction(
                id: 'due-$isIncome',
                amountCents: isIncome ? 50000 : 40000,
                isIncome: isIncome,
                categoryId: isIncome ? 'salary' : 'rent',
                dayOfMonth: 20,
                startDate: DateTime(2026, 7, 1),
                active: true,
                frequency: 'monthly',
                interval: 1,
              ),
            );
      }
      Future<BudgetOverview> at(DateTime date) async => buildBudgetOverview(
        transactions: (await database.getAllTransactions()).map(
          (row) => TransactionModel(
            id: row.id,
            amountCents: row.amountCents,
            isIncome: row.isIncome,
            categoryId: row.categoryId,
            date: row.date,
          ),
        ),
        recurringTransactions: await database
            .select(database.recurringTransactions)
            .get(),
        budgets: const [],
        contributions: const [],
        timeState: TimeFilterState(
          filter: TimeFilter.month,
          month: DateTime(2026, 7),
        ),
        now: date,
      );
      final before = await at(DateTime(2026, 7, 19));
      expect(before.upcomingRecurringIncomeMinor, 50000);
      expect(before.upcomingRecurringExpensesMinor, 40000);
      await database.generateRecurringTransactions(asOf: DateTime(2026, 7, 20));
      await database.generateRecurringTransactions(asOf: DateTime(2026, 7, 20));
      final after = await at(DateTime(2026, 7, 20));
      expect(after.upcomingRecurringIncomeMinor, 0);
      expect(after.upcomingRecurringExpensesMinor, 0);
      expect(after.incomeMinor, 50000);
      expect(after.expenseMinor, 40000);
      expect(after.availableToSpendMinor, 10000);
      expect(await database.getAllTransactions(), hasLength(2));
    },
  );
}
