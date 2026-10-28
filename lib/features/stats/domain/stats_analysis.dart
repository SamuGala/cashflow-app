import 'dart:math' as math;

import '../../../core/providers/time_filter_provider.dart';
import '../../transactions/domain/transaction.dart';

/// Read-only projections of existing transactions, already in the main currency.
/// No original amounts, exchange rates, recurring records or IDs are changed.
class StatsSummary {
  final List<TransactionModel> transactions;
  final int income;
  final int expense;

  const StatsSummary(this.transactions, this.income, this.expense);

  int get net => income - expense;
  int amount(bool isIncome) => isIncome ? income : expense;

  Map<String, int> categories(bool isIncome) {
    final result = <String, int>{};
    for (final item in transactions.where((tx) => tx.isIncome == isIncome)) {
      result.update(
        item.categoryId,
        (v) => v + item.amountCents,
        ifAbsent: () => item.amountCents,
      );
    }
    return result;
  }
}

StatsSummary summarizeStats(
  Iterable<TransactionModel> transactions,
  TimeWindow? window,
) {
  final items =
      transactions
          .where(
            (tx) =>
                window == null ||
                (!tx.date.isBefore(window.start) &&
                    !tx.date.isAfter(window.end)),
          )
          .toList()
        ..sort((a, b) {
          final date = a.date.compareTo(b.date);
          return date != 0 ? date : a.id.compareTo(b.id);
        });
  var income = 0;
  var expense = 0;
  for (final tx in items) {
    if (tx.isIncome) {
      income += tx.amountCents;
    } else {
      expense += tx.amountCents;
    }
  }
  return StatsSummary(List.unmodifiable(items), income, expense);
}

enum StatsBucketSize { day, month, year }

class StatsPoint {
  final DateTime date;
  final int amountMinor;
  const StatsPoint(this.date, this.amountMinor);
}

class StatsSeries {
  final List<StatsPoint> points;
  final StatsBucketSize bucketSize;
  const StatsSeries(this.points, this.bucketSize);
}

int _calendarDay(DateTime date) =>
    DateTime.utc(date.year, date.month, date.day).millisecondsSinceEpoch ~/
    Duration.millisecondsPerDay;

StatsSeries cumulativeStatsSeries(
  StatsSummary summary,
  TimeWindow? window, {
  required bool isIncome,
}) {
  if (summary.transactions.isEmpty && window == null) {
    return const StatsSeries([], StatsBucketSize.day);
  }
  final start = startOfDay(window?.start ?? summary.transactions.first.date);
  final end = startOfDay(window?.end ?? summary.transactions.last.date);
  final days = _calendarDay(end) - _calendarDay(start) + 1;
  final months = (end.year - start.year) * 12 + end.month - start.month + 1;
  final size = days <= 93
      ? StatsBucketSize.day
      : months <= 120
      ? StatsBucketSize.month
      : StatsBucketSize.year;
  DateTime bucket(DateTime d) => switch (size) {
    StatsBucketSize.day => DateTime(d.year, d.month, d.day),
    StatsBucketSize.month => DateTime(d.year, d.month),
    StatsBucketSize.year => DateTime(d.year),
  };
  DateTime next(DateTime d) => switch (size) {
    StatsBucketSize.day => DateTime(d.year, d.month, d.day + 1),
    StatsBucketSize.month => DateTime(d.year, d.month + 1),
    StatsBucketSize.year => DateTime(d.year + 1),
  };
  final amounts = <DateTime, int>{};
  for (final tx in summary.transactions.where(
    (tx) => tx.isIncome == isIncome,
  )) {
    amounts.update(
      bucket(tx.date),
      (v) => v + tx.amountCents,
      ifAbsent: () => tx.amountCents,
    );
  }
  var running = 0;
  final points = <StatsPoint>[];
  for (
    var date = bucket(start);
    !date.isAfter(bucket(end));
    date = next(date)
  ) {
    running += amounts[date] ?? 0;
    points.add(StatsPoint(date, running));
  }
  return StatsSeries(List.unmodifiable(points), size);
}

enum StatsComparisonMode { previousMonth, month, yearAverage }

class StatsComparisonSelection {
  final DateTime month;
  final DateTime referenceMonth;
  final StatsComparisonMode mode;
  final bool alignElapsedDays;

  const StatsComparisonSelection({
    required this.month,
    required this.referenceMonth,
    this.mode = StatsComparisonMode.previousMonth,
    this.alignElapsedDays = true,
  });

  factory StatsComparisonSelection.current(DateTime now) =>
      StatsComparisonSelection(
        month: DateTime(now.year, now.month),
        referenceMonth: DateTime(now.year, now.month - 1),
      );

  StatsComparisonSelection copyWith({
    DateTime? month,
    DateTime? referenceMonth,
    StatsComparisonMode? mode,
    bool? alignElapsedDays,
  }) => StatsComparisonSelection(
    month: month ?? this.month,
    referenceMonth: referenceMonth ?? this.referenceMonth,
    mode: mode ?? this.mode,
    alignElapsedDays: alignElapsedDays ?? this.alignElapsedDays,
  );
}

class StatsCategoryChange {
  final String categoryId;
  final int currentMinor;
  final int referenceMinor;
  const StatsCategoryChange(
    this.categoryId,
    this.currentMinor,
    this.referenceMinor,
  );
  int get delta => currentMinor - referenceMinor;
}

class StatsComparison {
  final StatsSummary current;
  final List<DateTime> referenceMonths;
  final List<TimeWindow> referenceWindows;
  final TimeWindow currentWindow;
  final Map<String, int> referenceCategories;
  final bool isIncome;
  final int? throughDay;
  final int referenceTransactionCount;

  const StatsComparison({
    required this.current,
    required this.referenceMonths,
    required this.referenceWindows,
    required this.currentWindow,
    required this.referenceCategories,
    required this.isIncome,
    required this.throughDay,
    required this.referenceTransactionCount,
  });

  bool get available => referenceMonths.isNotEmpty;
  int get referenceMinor => referenceCategories.values.fold(0, (a, b) => a + b);
  int get currentMinor => current.amount(isIncome);
  int get delta => currentMinor - referenceMinor;
  double? get percentage => available && referenceMinor != 0
      ? delta / referenceMinor.abs() * 100
      : null;

  List<StatsCategoryChange> get changes {
    final primary = current.categories(isIncome);
    final result =
        {...primary.keys, ...referenceCategories.keys}
            .map(
              (id) => StatsCategoryChange(
                id,
                primary[id] ?? 0,
                referenceCategories[id] ?? 0,
              ),
            )
            .toList()
          ..sort((a, b) {
            final delta = b.delta.abs().compareTo(a.delta.abs());
            return delta != 0 ? delta : a.categoryId.compareTo(b.categoryId);
          });
    return result;
  }
}

/// Rounds only at the display currency's minor unit, preserving the total.
Map<String, int> _averageCategories(Map<String, int> amounts, int count) {
  if (count == 0 || amounts.isEmpty) return {};
  int floorDivide(int value) =>
      value ~/ count - (value < 0 && value % count != 0 ? 1 : 0);
  final result = {for (final e in amounts.entries) e.key: floorDivide(e.value)};
  final total = amounts.values.fold(0, (a, b) => a + b);
  final target = ((total.abs() + count ~/ 2) ~/ count) * total.sign;
  final remainder = target - result.values.fold(0, (a, b) => a + b);
  final keys = amounts.keys.toList()
    ..sort((a, b) {
      final comparison = (amounts[b]! % count).compareTo(amounts[a]! % count);
      return comparison != 0 ? comparison : a.compareTo(b);
    });
  for (var i = 0; i < remainder; i++) {
    result[keys[i]] = result[keys[i]]! + 1;
  }
  return result;
}

StatsComparison compareStats(
  Iterable<TransactionModel> transactions,
  StatsComparisonSelection selection, {
  required bool isIncome,
  required DateTime now,
}) {
  final month = DateTime(selection.month.year, selection.month.month);
  final throughDay =
      selection.alignElapsedDays &&
          month.year == now.year &&
          month.month == now.month
      ? now.day
      : null;
  TimeWindow window(DateTime month) {
    final last = DateTime(month.year, month.month + 1, 0);
    return TimeWindow(
      start: DateTime(month.year, month.month),
      end: endOfDay(
        DateTime(
          month.year,
          month.month,
          math.min(throughDay ?? last.day, last.day),
        ),
      ),
    );
  }

  final references = switch (selection.mode) {
    StatsComparisonMode.previousMonth => [
      DateTime(month.year, month.month - 1),
    ],
    StatsComparisonMode.month => [
      DateTime(selection.referenceMonth.year, selection.referenceMonth.month),
    ],
    StatsComparisonMode.yearAverage => [
      for (var i = 1; i < month.month; i++) DateTime(month.year, i),
    ],
  };
  final items = transactions.toList();
  final referenceWindows = references.map(window).toList();
  final categoryTotals = <String, int>{};
  var referenceCount = 0;
  for (final range in referenceWindows) {
    final summary = summarizeStats(items, range);
    referenceCount += summary.transactions
        .where((tx) => tx.isIncome == isIncome)
        .length;
    for (final e in summary.categories(isIncome).entries) {
      categoryTotals.update(e.key, (v) => v + e.value, ifAbsent: () => e.value);
    }
  }
  final range = window(month);
  return StatsComparison(
    current: summarizeStats(items, range),
    referenceMonths: List.unmodifiable(references),
    referenceWindows: List.unmodifiable(referenceWindows),
    currentWindow: range,
    referenceCategories: Map.unmodifiable(
      _averageCategories(categoryTotals, references.length),
    ),
    isIncome: isIncome,
    throughDay: throughDay,
    referenceTransactionCount: referenceCount,
  );
}

/// The overview follows the shared filter; comparisons keep their own selection.
/// Calendar arithmetic avoids losing a day when a period crosses a DST change.
TimeWindow? previousStatsWindow(
  TimeFilterState selection,
  TimeWindow? current,
) {
  if (current == null || selection.filter == TimeFilter.total) return null;
  if (selection.filter == TimeFilter.month) {
    final start = DateTime(current.start.year, current.start.month - 1);
    final last = DateTime(start.year, start.month + 1, 0);
    return TimeWindow(
      start: start,
      end: endOfDay(
        DateTime(start.year, start.month, math.min(current.end.day, last.day)),
      ),
    );
  }
  final days = _calendarDay(current.end) - _calendarDay(current.start) + 1;
  return TimeWindow(
    start: DateTime(
      current.start.year,
      current.start.month,
      current.start.day - days,
    ),
    end: endOfDay(
      DateTime(current.start.year, current.start.month, current.start.day - 1),
    ),
  );
}

/// Projects the reference onto the primary axis, including unequal month lengths.
/// Each point represents the same number of elapsed calendar days, never a ratio
/// of buckets (which would misalign February or multi-month custom ranges).
StatsSeries alignedStatsReference(
  StatsSeries primary,
  TimeWindow current,
  StatsSummary reference,
  TimeWindow referenceWindow, {
  required bool isIncome,
}) {
  final items = reference.transactions
      .where((tx) => tx.isIncome == isIncome)
      .toList();
  var index = 0;
  var running = 0;
  final points = <StatsPoint>[];
  for (final point in primary.points) {
    final bucketEnd = switch (primary.bucketSize) {
      StatsBucketSize.day => point.date,
      StatsBucketSize.month => DateTime(
        point.date.year,
        point.date.month + 1,
        0,
      ),
      StatsBucketSize.year => DateTime(point.date.year, 12, 31),
    };
    final currentEnd = bucketEnd.isAfter(current.end) ? current.end : bucketEnd;
    final elapsed = _calendarDay(currentEnd) - _calendarDay(current.start);
    final date = DateTime(
      referenceWindow.start.year,
      referenceWindow.start.month,
      referenceWindow.start.day + elapsed,
    );
    final end = endOfDay(
      date.isAfter(referenceWindow.end) ? referenceWindow.end : date,
    );
    while (index < items.length && !items[index].date.isAfter(end)) {
      running += items[index++].amountCents;
    }
    points.add(StatsPoint(point.date, running));
  }
  return StatsSeries(List.unmodifiable(points), primary.bucketSize);
}
