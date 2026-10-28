import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_vault/core/database/app_database.dart';
import 'package:pocket_vault/core/providers/time_filter_provider.dart';
import 'package:pocket_vault/features/budgets/providers/budget_provider.dart';

void main() {
  final cases =
      <
        ({
          String name,
          String frequency,
          DateTime start,
          DateTime from,
          DateTime through,
          int day,
          int interval,
          int count,
        })
      >[
        (
          name: 'daily in leap February',
          frequency: 'daily',
          start: DateTime(2028, 2, 1),
          from: DateTime(2028, 2, 1),
          through: DateTime(2028, 2, 29),
          day: 1,
          interval: 1,
          count: 29,
        ),
        (
          name: 'daily every three days',
          frequency: 'daily',
          start: DateTime(2028, 2, 1),
          from: DateTime(2028, 2, 1),
          through: DateTime(2028, 2, 29),
          day: 1,
          interval: 3,
          count: 10,
        ),
        (
          name: 'weekly five occurrences',
          frequency: 'weekly',
          start: DateTime(2026, 7, 1),
          from: DateTime(2026, 7, 1),
          through: DateTime(2026, 7, 31),
          day: 1,
          interval: 1,
          count: 5,
        ),
        (
          name: 'fortnightly three occurrences',
          frequency: 'weekly',
          start: DateTime(2026, 7, 1),
          from: DateTime(2026, 7, 1),
          through: DateTime(2026, 7, 31),
          day: 1,
          interval: 2,
          count: 3,
        ),
        (
          name: 'monthly day 31 clamps February',
          frequency: 'monthly',
          start: DateTime(2026, 1, 31),
          from: DateTime(2026, 1, 31),
          through: DateTime(2026, 3, 31),
          day: 31,
          interval: 1,
          count: 3,
        ),
        (
          name: 'monthly leap February',
          frequency: 'monthly',
          start: DateTime(2028, 1, 31),
          from: DateTime(2028, 1, 31),
          through: DateTime(2028, 2, 29),
          day: 31,
          interval: 1,
          count: 2,
        ),
        (
          name: 'every two months',
          frequency: 'monthly',
          start: DateTime(2026, 1, 31),
          from: DateTime(2026, 1, 31),
          through: DateTime(2026, 5, 31),
          day: 31,
          interval: 2,
          count: 3,
        ),
        (
          name: 'yearly leap-day interval',
          frequency: 'yearly',
          start: DateTime(2024, 2, 29),
          from: DateTime(2024, 2, 29),
          through: DateTime(2028, 2, 29),
          day: 29,
          interval: 2,
          count: 3,
        ),
        (
          name: 'crossing December to January',
          frequency: 'monthly',
          start: DateTime(2026, 12, 31),
          from: DateTime(2026, 12, 31),
          through: DateTime(2027, 1, 31),
          day: 31,
          interval: 1,
          count: 2,
        ),
        (
          name: 'single-day period',
          frequency: 'monthly',
          start: DateTime(2026, 7, 1),
          from: DateTime(2026, 7, 15),
          through: DateTime(2026, 7, 15),
          day: 15,
          interval: 1,
          count: 1,
        ),
        (
          name: 'period starts after first occurrence',
          frequency: 'monthly',
          start: DateTime(2026, 7, 1),
          from: DateTime(2026, 7, 16),
          through: DateTime(2026, 8, 15),
          day: 15,
          interval: 1,
          count: 1,
        ),
        (
          name: 'schedule starts after period',
          frequency: 'monthly',
          start: DateTime(2026, 8, 1),
          from: DateTime(2026, 7, 1),
          through: DateTime(2026, 7, 31),
          day: 15,
          interval: 1,
          count: 0,
        ),
      ];

  for (final item in cases) {
    for (final isIncome in [true, false]) {
      test('${item.name}: ${isIncome ? 'income' : 'expense'}', () {
        final row = RecurringTransaction(
          id: 'scheduled',
          amountCents: 12345,
          isIncome: isIncome,
          categoryId: isIncome ? 'salary' : 'food',
          dayOfMonth: item.day,
          startDate: item.start,
          active: true,
          frequency: item.frequency,
          interval: item.interval,
          dayOfWeek: item.start.weekday,
          monthOfYear: item.start.month,
        );
        final overview = buildBudgetOverview(
          transactions: const [],
          recurringTransactions: [row],
          budgets: const [],
          contributions: const [],
          timeState: TimeFilterState(
            filter: TimeFilter.period,
            month: item.from,
            start: item.from,
            end: item.through,
          ),
          now: DateTime(item.from.year, item.from.month, item.from.day - 1),
        );
        final expected = item.count * 12345;
        expect(overview.upcomingRecurringIncomeMinor, isIncome ? expected : 0);
        expect(
          overview.upcomingRecurringExpensesMinor,
          isIncome ? 0 : expected,
        );
        expect(overview.incomeMinor, 0);
        expect(overview.expenseMinor, 0);
      });
    }
  }

  test('equal incoming and outgoing amounts do not cancel each other', () {
    final overview = buildBudgetOverview(
      transactions: const [],
      budgets: const [],
      contributions: const [],
      recurringTransactions: [
        for (final isIncome in [true, false])
          RecurringTransaction(
            id: '$isIncome',
            amountCents: 900000001,
            isIncome: isIncome,
            categoryId: isIncome ? 'salary' : 'food',
            dayOfMonth: 20,
            startDate: DateTime(2026, 7, 1),
            active: true,
            frequency: 'monthly',
            interval: 1,
          ),
      ],
      timeState: TimeFilterState(
        filter: TimeFilter.month,
        month: DateTime(2026, 7),
      ),
      now: DateTime(2026, 7, 1),
    );
    expect(overview.upcomingRecurringIncomeMinor, 900000001);
    expect(overview.upcomingRecurringExpensesMinor, 900000001);
  });
}
