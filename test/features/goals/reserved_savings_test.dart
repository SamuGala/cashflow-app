import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_vault/core/database/app_database.dart';
import 'package:pocket_vault/core/database/database_provider.dart';
import 'package:pocket_vault/core/providers/time_filter_provider.dart';
import 'package:pocket_vault/features/budgets/providers/budget_provider.dart';
import 'package:pocket_vault/features/goals/providers/savings_goals_provider.dart';
import 'package:pocket_vault/features/transactions/providers/recurring_provider.dart';
import 'package:pocket_vault/features/transactions/providers/transaction_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// "Accantonati" after deleting a goal or releasing money reserved in an
/// earlier month: never negative, and a deleted goal no longer counts.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase database;
  late ProviderContainer container;
  final now = DateTime.now();
  final thisMonth = DateTime(now.year, now.month);
  final lastMonth = DateTime(now.year, now.month - 1, 10, 12);

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'base_currency_v1': 'EUR',
      'currency_rates_ecb_v1': jsonEncode({
        'rates': {'EUR': 1.0},
        'publishedAt': now.toIso8601String(),
        'fetchedAt': now.toIso8601String(),
      }),
    });
    database = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    // Keep the providers alive between reads, as the Home screen does.
    container.listen(budgetOverviewProvider, (_, _) {});
    container.listen(savingsGoalsProvider, (_, _) {});
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  Future<String> goalWithContribution(int amount, DateTime when) async {
    final goals = container.read(savingsGoalsProvider.notifier);
    await container.read(savingsGoalsProvider.future);
    await goals.addGoal(name: 'Vacanza', targetAmountMinor: 50000);
    final goal = (await container.read(savingsGoalsProvider.future)).single;
    await goals.contribute(goal.id, amount);
    // Move the contribution back to [when], as if made then.
    await database
        .update(database.savingsGoalContributions)
        .write(SavingsGoalContributionsCompanion(createdAt: Value(when)));
    container.invalidate(savingsGoalsProvider);
    return goal.id;
  }

  Future<int> reserved(TimeFilter filter) async {
    container.read(timeFilterProvider.notifier).setMonth(thisMonth);
    if (filter == TimeFilter.total) {
      container.read(timeFilterProvider.notifier).setFilter(TimeFilter.total);
    }
    await container.read(savingsGoalsProvider.future);
    await container.read(savingsGoalContributionsProvider.future);
    final overview = await _overview(container);
    return overview.reservedSavingsMinor;
  }

  test('deleting a goal funded last month leaves 0, not a negative', () async {
    final id = await goalWithContribution(2000, lastMonth);
    expect(await reserved(TimeFilter.month), 0);
    expect(await reserved(TimeFilter.total), 2000);

    final removal = await container
        .read(savingsGoalsProvider.notifier)
        .remove(id);
    expect(await reserved(TimeFilter.month), 0);
    expect(await reserved(TimeFilter.total), 0);

    // Undo brings the reservation back.
    await container.read(savingsGoalsProvider.notifier).restore(removal);
    expect(await reserved(TimeFilter.total), 2000);
    // The data itself is untouched by the new rule.
    expect(
      (await database.select(database.savingsGoalContributions).get()).length,
      1,
    );
  });

  test('a release of money set aside earlier does not go below 0', () async {
    final id = await goalWithContribution(5000, lastMonth);
    await container.read(savingsGoalsProvider.notifier).release(id, 2000);
    expect(await reserved(TimeFilter.month), 0);
    expect(await reserved(TimeFilter.total), 3000);
  });

  test('reservations made this month still count as before', () async {
    final id = await goalWithContribution(4000, DateTime.now());
    expect(await reserved(TimeFilter.month), 4000);
    await container.read(savingsGoalsProvider.notifier).release(id, 1500);
    expect(await reserved(TimeFilter.month), 2500);
  });

  test('reservedInSelection clamps only the period, not the history', () {
    final rows = [
      SavingsGoalContributionRow(
        id: 'a',
        goalId: 'g',
        amountMinor: 1000,
        eurAmountMicros: 10000000,
        currencyCode: 'EUR',
        createdAt: lastMonth,
      ),
      SavingsGoalContributionRow(
        id: 'b',
        goalId: 'g',
        amountMinor: -1000,
        eurAmountMicros: -10000000,
        currencyCode: 'EUR',
        createdAt: now,
      ),
    ];
    expect(
      reservedInSelection(
        rows,
        TimeFilterState(filter: TimeFilter.month, month: thisMonth),
      ),
      0,
    );
    expect(
      reservedInSelection(
        rows,
        TimeFilterState(filter: TimeFilter.total, month: thisMonth),
      ),
      0,
    );
  });
}

Future<BudgetOverview> _overview(ProviderContainer container) async {
  await container.read(transactionProvider.future);
  await container.read(recurringProvider.future);
  await container.read(budgetProvider.future);
  await container.read(savingsGoalContributionsProvider.future);
  for (var i = 0; i < 50; i++) {
    final value = container.read(budgetOverviewProvider);
    if (value.hasValue && !value.isLoading) return value.requireValue;
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
  return container.read(budgetOverviewProvider).requireValue;
}
