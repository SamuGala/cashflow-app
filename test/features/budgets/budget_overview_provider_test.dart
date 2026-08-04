import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_vault/core/database/app_database.dart';
import 'package:pocket_vault/core/providers/time_filter_provider.dart';
import 'package:pocket_vault/features/budgets/providers/budget_provider.dart';
import 'package:pocket_vault/features/transactions/domain/transaction.dart';

void main() {
  final july = DateTime(2026, 7, 1);
  final transactions = [
    TransactionModel(
      id: 'july-income',
      amountCents: 200000,
      isIncome: true,
      categoryId: 'salary',
      date: DateTime(2026, 7, 2),
    ),
    TransactionModel(
      id: 'july-food',
      amountCents: 50000,
      isIncome: false,
      categoryId: 'food',
      date: DateTime(2026, 7, 8),
    ),
    TransactionModel(
      id: 'june-income',
      amountCents: 100000,
      isIncome: true,
      categoryId: 'salary',
      date: DateTime(2026, 6, 2),
    ),
  ];
  final recurring = [
    RecurringTransaction(
      id: 'rent',
      amountCents: 40000,
      isIncome: false,
      categoryId: 'rent',
      dayOfMonth: 20,
      startDate: july,
      active: true,
      frequency: 'monthly',
      interval: 1,
    ),
  ];
  final budgets = [
    BudgetRow(
      id: 'food-budget',
      categoryId: 'food',
      amountMinor: 100000,
      eurAmountMicros: 1000000000,
      periodType: 'monthly',
      rollover: false,
      active: true,
      createdAt: july,
      updatedAt: july,
    ),
  ];
  final contributions = [
    SavingsGoalContributionRow(
      id: 'reserve-july',
      goalId: 'holiday',
      amountMinor: 30000,
      eurAmountMicros: 300000000,
      currencyCode: 'EUR',
      createdAt: DateTime(2026, 7, 4),
    ),
    SavingsGoalContributionRow(
      id: 'release-july',
      goalId: 'holiday',
      amountMinor: -5000,
      eurAmountMicros: -50000000,
      currencyCode: 'EUR',
      createdAt: DateTime(2026, 7, 10),
    ),
    SavingsGoalContributionRow(
      id: 'reserve-june',
      goalId: 'holiday',
      amountMinor: 10000,
      eurAmountMicros: 100000000,
      currencyCode: 'EUR',
      createdAt: DateTime(2026, 6, 4),
    ),
  ];

  test('month overview applies every selected financial component', () {
    final overview = buildBudgetOverview(
      transactions: transactions,
      recurringTransactions: recurring,
      budgets: budgets,
      contributions: contributions,
      timeState: TimeFilterState(filter: TimeFilter.month, month: july),
      now: DateTime(2026, 7, 15, 12),
    );

    expect(overview.incomeMinor, 200000);
    expect(overview.expenseMinor, 50000);
    expect(overview.reservedSavingsMinor, 25000);
    expect(overview.upcomingRecurringExpensesMinor, 40000);
    expect(overview.availableToSpendMinor, 85000);
    expect(overview.budgets.single.spentMinor, 50000);
    expect(overview.budgets.single.limitMinor, 100000);
  });

  test(
    'total overview uses all actual movements and no unbounded forecast',
    () {
      final overview = buildBudgetOverview(
        transactions: transactions,
        recurringTransactions: recurring,
        budgets: budgets,
        contributions: contributions,
        timeState: TimeFilterState(filter: TimeFilter.total, month: july),
        now: DateTime(2026, 7, 31, 12),
      );

      expect(overview.incomeMinor, 300000);
      expect(overview.expenseMinor, 50000);
      expect(overview.reservedSavingsMinor, 35000);
      expect(overview.upcomingRecurringExpensesMinor, 0);
      expect(overview.availableToSpendMinor, 215000);
    },
  );

  test('custom period prorates monthly limits and future recurrences', () {
    final overview = buildBudgetOverview(
      transactions: transactions,
      recurringTransactions: recurring,
      budgets: budgets,
      contributions: contributions,
      timeState: TimeFilterState(
        filter: TimeFilter.period,
        month: july,
        start: DateTime(2026, 7, 1),
        end: DateTime(2026, 8, 31),
      ),
      now: DateTime(2026, 7, 15, 12),
    );

    expect(overview.upcomingRecurringExpensesMinor, 80000);
    expect(overview.budgets.single.limitMinor, 200000);
    expect(overview.availableToSpendMinor, 45000);
  });

  test('monthly factor handles full and partial calendar months', () {
    expect(monthlyBudgetFactor(DateTime(2026, 7, 1), DateTime(2026, 7, 31)), 1);
    expect(monthlyBudgetFactor(DateTime(2026, 7, 1), DateTime(2026, 8, 31)), 2);
    expect(
      monthlyBudgetFactor(DateTime(2026, 2, 1), DateTime(2026, 2, 14)),
      closeTo(.5, .00001),
    );
  });
}
