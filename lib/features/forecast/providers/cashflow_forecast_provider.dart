import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../transactions/domain/recurrence_calculator.dart';
import '../../transactions/domain/transaction.dart';
import '../../transactions/providers/recurring_provider.dart';
import '../../transactions/providers/transaction_provider.dart';

class ForecastOccurrence {
  final DateTime date;
  final int amountMinor;
  final bool isIncome;
  final String categoryId;
  final String? note;

  const ForecastOccurrence({
    required this.date,
    required this.amountMinor,
    required this.isIncome,
    required this.categoryId,
    this.note,
  });
}

class CashflowForecast {
  final int currentBalanceMinor;
  final int projectedBalanceMinor;
  final List<ForecastOccurrence> occurrences;
  final DateTime through;

  const CashflowForecast({
    required this.currentBalanceMinor,
    required this.projectedBalanceMinor,
    required this.occurrences,
    required this.through,
  });
}

enum ForecastHorizon {
  oneMonth(1),
  twoMonths(2),
  threeMonths(3),
  sixMonths(6),
  oneYear(12),
  twoYears(24),
  fiveYears(60);

  final int months;

  const ForecastHorizon(this.months);
}

class ForecastHorizonNotifier extends Notifier<ForecastHorizon> {
  @override
  ForecastHorizon build() => ForecastHorizon.threeMonths;

  void setHorizon(ForecastHorizon horizon) => state = horizon;
}

final forecastHorizonProvider =
    NotifierProvider<ForecastHorizonNotifier, ForecastHorizon>(
      ForecastHorizonNotifier.new,
    );

CashflowForecast buildCashflowForecast({
  required Iterable<TransactionModel> transactions,
  required Iterable<RecurringTransaction> recurringTransactions,
  required DateTime now,
  required DateTime through,
}) {
  if (!through.isAfter(now)) {
    throw ArgumentError.value(through, 'through');
  }
  final currentBalance = transactions.fold<int>(
    0,
    (total, tx) => total + (tx.isIncome ? tx.amountCents : -tx.amountCents),
  );
  final occurrences = <ForecastOccurrence>[];
  for (final row in recurringTransactions.where((row) => row.active)) {
    final schedule = RecurrenceSchedule(
      startDate: row.startDate,
      frequency: recurrenceFrequencyFromName(row.frequency),
      interval: row.interval,
      dayOfMonth: row.dayOfMonth,
      dayOfWeek: row.dayOfWeek,
      monthOfYear: row.monthOfYear,
      endDate: row.endDate,
    );
    for (final date in recurringOccurrences(
      schedule: schedule,
      after: now,
      through: through,
    )) {
      occurrences.add(
        ForecastOccurrence(
          date: date,
          amountMinor: row.amountCents,
          isIncome: row.isIncome,
          categoryId: row.categoryId,
          note: row.note,
        ),
      );
    }
  }
  occurrences.sort((first, second) => first.date.compareTo(second.date));
  final projected = occurrences.fold<int>(
    currentBalance,
    (total, item) =>
        total + (item.isIncome ? item.amountMinor : -item.amountMinor),
  );
  return CashflowForecast(
    currentBalanceMinor: currentBalance,
    projectedBalanceMinor: projected,
    occurrences: occurrences,
    through: through,
  );
}

DateTime forecastEndDate(DateTime from, ForecastHorizon horizon) {
  final targetMonth = DateTime(from.year, from.month + horizon.months);
  final lastDay = DateTime(targetMonth.year, targetMonth.month + 1, 0).day;
  return DateTime(
    targetMonth.year,
    targetMonth.month,
    from.day.clamp(1, lastDay),
    from.hour,
    from.minute,
    from.second,
    from.millisecond,
    from.microsecond,
  );
}

final cashflowForecastProvider = Provider<AsyncValue<CashflowForecast>>((ref) {
  final transactions = ref.watch(transactionProvider);
  final recurring = ref.watch(recurringProvider);
  final horizon = ref.watch(forecastHorizonProvider);
  if (transactions.isLoading || recurring.isLoading) {
    return const AsyncLoading();
  }
  final error = transactions.error ?? recurring.error;
  if (error != null) return AsyncError(error, StackTrace.current);

  final now = DateTime.now();
  return AsyncData(
    buildCashflowForecast(
      transactions: transactions.requireValue,
      recurringTransactions: recurring.requireValue,
      now: now,
      through: forecastEndDate(now, horizon),
    ),
  );
});
