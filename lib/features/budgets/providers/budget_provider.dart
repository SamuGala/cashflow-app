import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/currency/currency_provider.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/providers/time_filter_provider.dart';
import '../../goals/providers/savings_goals_provider.dart';
import '../../transactions/domain/recurrence_calculator.dart';
import '../../transactions/domain/transaction.dart';
import '../../transactions/providers/recurring_provider.dart';
import '../../transactions/providers/transaction_provider.dart';

final budgetProvider = AsyncNotifierProvider<BudgetNotifier, List<BudgetRow>>(
  BudgetNotifier.new,
);

class BudgetNotifier extends AsyncNotifier<List<BudgetRow>> {
  final _uuid = const Uuid();

  @override
  Future<List<BudgetRow>> build() async {
    ref.watch(currencyProvider.select((value) => value.value?.baseCurrency));
    final db = ref.read(databaseProvider);
    return (db.select(db.budgets)
          ..where((row) => row.active.equals(true))
          ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]))
        .get();
  }

  Future<void> setMonthlyBudget({
    required String categoryId,
    required int amountMinor,
    bool rollover = false,
  }) async {
    final conversion = await ref
        .read(currencyProvider.notifier)
        .convert(
          amountMinor: amountMinor,
          sourceCurrency:
              ref.read(currencyProvider).value?.baseCurrency ?? 'EUR',
        );
    final db = ref.read(databaseProvider);
    final existing = await (db.select(
      db.budgets,
    )..where((row) => row.categoryId.equals(categoryId))).getSingleOrNull();
    final now = DateTime.now();
    await db
        .into(db.budgets)
        .insertOnConflictUpdate(
          BudgetRow(
            id: existing?.id ?? _uuid.v4(),
            categoryId: categoryId,
            amountMinor: amountMinor,
            eurAmountMicros: conversion.eurAmountMicros,
            periodType: 'monthly',
            rollover: rollover,
            active: true,
            createdAt: existing?.createdAt ?? now,
            updatedAt: now,
          ),
        );
    ref.invalidateSelf();
  }

  Future<void> removeBudget(String id) async {
    final db = ref.read(databaseProvider);
    await (db.delete(db.budgets)..where((row) => row.id.equals(id))).go();
    ref.invalidateSelf();
  }

  Future<void> restoreBudget(BudgetRow budget) async {
    final db = ref.read(databaseProvider);
    await db.into(db.budgets).insertOnConflictUpdate(budget);
    ref.invalidateSelf();
  }
}

class BudgetProgress {
  final BudgetRow budget;
  final int spentMinor;
  final int limitMinor;

  const BudgetProgress({
    required this.budget,
    required this.spentMinor,
    required this.limitMinor,
  });

  int get remainingMinor => limitMinor - spentMinor;
  double get ratio =>
      limitMinor <= 0 ? 0 : (spentMinor / limitMinor).clamp(0, 1.5);
}

class BudgetOverview {
  final int incomeMinor;
  final int expenseMinor;
  final int upcomingRecurringExpensesMinor;
  final int reservedSavingsMinor;
  final List<BudgetProgress> budgets;

  const BudgetOverview({
    required this.incomeMinor,
    required this.expenseMinor,
    required this.upcomingRecurringExpensesMinor,
    required this.reservedSavingsMinor,
    required this.budgets,
  });

  int get availableToSpendMinor =>
      incomeMinor -
      expenseMinor -
      upcomingRecurringExpensesMinor -
      reservedSavingsMinor;
}

final budgetOverviewProvider = Provider<AsyncValue<BudgetOverview>>((ref) {
  final transactions = ref.watch(transactionProvider);
  final recurring = ref.watch(recurringProvider);
  final budgets = ref.watch(budgetProvider);
  final contributions = ref.watch(savingsGoalContributionsProvider);
  final timeState = ref.watch(timeFilterProvider);
  if (transactions.isLoading ||
      recurring.isLoading ||
      budgets.isLoading ||
      contributions.isLoading) {
    return const AsyncLoading();
  }
  final error =
      transactions.error ??
      recurring.error ??
      budgets.error ??
      contributions.error;
  if (error != null) return AsyncError(error, StackTrace.current);

  return AsyncData(
    buildBudgetOverview(
      transactions: transactions.requireValue,
      recurringTransactions: recurring.requireValue,
      budgets: budgets.requireValue,
      contributions: contributions.requireValue,
      timeState: timeState,
      now: DateTime.now(),
    ),
  );
});

BudgetOverview buildBudgetOverview({
  required Iterable<TransactionModel> transactions,
  required Iterable<RecurringTransaction> recurringTransactions,
  required Iterable<BudgetRow> budgets,
  required Iterable<SavingsGoalContributionRow> contributions,
  required TimeFilterState timeState,
  required DateTime now,
}) {
  final window = selectedTimeWindow(timeState);
  final selectedTransactions = transactions
      .where((tx) => isInSelectedTimeWindow(tx.date, timeState))
      .toList(growable: false);
  var income = 0;
  var expense = 0;
  for (final tx in selectedTransactions) {
    if (tx.isIncome) {
      income += tx.amountCents;
    } else {
      expense += tx.amountCents;
    }
  }

  final reserved = contributions
      .where((row) => isInSelectedTimeWindow(row.createdAt, timeState))
      .fold<int>(0, (total, row) => total + row.amountMinor);

  var upcoming = 0;
  if (window != null && !window.end.isBefore(startOfDay(now))) {
    final today = startOfDay(now);
    final after = window.start.isAfter(today)
        ? window.start.subtract(const Duration(days: 1))
        : today;
    for (final row in recurringTransactions.where(
      (row) => row.active && !row.isIncome,
    )) {
      final schedule = RecurrenceSchedule(
        startDate: row.startDate,
        frequency: RecurrenceFrequency.values.firstWhere(
          (value) => value.name == row.frequency,
          orElse: () => RecurrenceFrequency.monthly,
        ),
        interval: row.interval,
        dayOfMonth: row.dayOfMonth,
        dayOfWeek: row.dayOfWeek,
        monthOfYear: row.monthOfYear,
        endDate: row.endDate,
      );
      upcoming +=
          recurringOccurrences(
            schedule: schedule,
            after: after,
            through: window.end,
          ).length *
          row.amountCents;
    }
  }

  final progress = <BudgetProgress>[];
  for (final budget in budgets) {
    final activeFrom = DateTime(budget.createdAt.year, budget.createdAt.month);
    final start = window?.start ?? activeFrom;
    final end = window?.end ?? endOfDay(now);
    final effectiveStart = start.isAfter(activeFrom) ? start : activeFrom;
    if (end.isBefore(effectiveStart)) continue;
    final limit =
        (budget.amountMinor * monthlyBudgetFactor(effectiveStart, end)).round();
    if (limit <= 0) continue;
    final spent = selectedTransactions
        .where(
          (tx) =>
              !tx.isIncome &&
              tx.categoryId == budget.categoryId &&
              !tx.date.isBefore(activeFrom),
        )
        .fold<int>(0, (total, tx) => total + tx.amountCents);
    progress.add(
      BudgetProgress(budget: budget, spentMinor: spent, limitMinor: limit),
    );
  }

  return BudgetOverview(
    incomeMinor: income,
    expenseMinor: expense,
    upcomingRecurringExpensesMinor: upcoming,
    reservedSavingsMinor: reserved,
    budgets: progress,
  );
}

double monthlyBudgetFactor(DateTime start, DateTime end) {
  final first = startOfDay(start);
  final last = startOfDay(end);
  if (last.isBefore(first)) return 0;
  var cursor = DateTime(first.year, first.month);
  var factor = 0.0;
  while (!cursor.isAfter(DateTime(last.year, last.month))) {
    final monthStart = cursor;
    final monthEnd = DateTime(cursor.year, cursor.month + 1, 0);
    final overlapStart = first.isAfter(monthStart) ? first : monthStart;
    final overlapEnd = last.isBefore(monthEnd) ? last : monthEnd;
    if (!overlapEnd.isBefore(overlapStart)) {
      final includedDays = _calendarDays(overlapStart, overlapEnd) + 1;
      factor += includedDays / monthEnd.day;
    }
    cursor = DateTime(cursor.year, cursor.month + 1);
  }
  return factor;
}

int _calendarDays(DateTime first, DateTime last) {
  return DateTime.utc(
    last.year,
    last.month,
    last.day,
  ).difference(DateTime.utc(first.year, first.month, first.day)).inDays;
}
