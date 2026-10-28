import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_vault/core/providers/time_filter_provider.dart';
import 'package:pocket_vault/features/stats/domain/stats_analysis.dart';
import 'package:pocket_vault/features/transactions/domain/transaction.dart';

TransactionModel tx(
  String id,
  DateTime date,
  int amount, {
  String category = 'food',
  bool income = false,
}) => TransactionModel(
  id: id,
  amountCents: amount,
  isIncome: income,
  categoryId: category,
  date: date,
);

void main() {
  test(
    'overview reference aligns February to the first 28 days of January',
    () {
      final selection = TimeFilterState(
        filter: TimeFilter.month,
        month: DateTime(2026, 2),
      );
      final current = selectedTimeWindow(selection)!;
      final previous = previousStatsWindow(selection, current)!;
      expect(previous.start, DateTime(2026, 1));
      expect(previous.end, endOfDay(DateTime(2026, 1, 28)));
      final reference = summarizeStats([
        tx('included', DateTime(2026, 1, 28, 23, 59), 700),
        tx('excluded', DateTime(2026, 1, 29), 900),
      ], previous);
      final primary = cumulativeStatsSeries(
        summarizeStats([], current),
        current,
        isIncome: false,
      );
      final aligned = alignedStatsReference(
        primary,
        current,
        reference,
        previous,
        isIncome: false,
      );
      expect(aligned.points.length, 28);
      expect(aligned.points[26].amountMinor, 0);
      expect(aligned.points.last.amountMinor, 700);
    },
  );

  test(
    'overview reference clamps a shorter month and carries its final value',
    () {
      final selection = TimeFilterState(
        filter: TimeFilter.month,
        month: DateTime(2024, 3),
      );
      final current = selectedTimeWindow(selection)!;
      final previous = previousStatsWindow(selection, current)!;
      expect(previous.end, endOfDay(DateTime(2024, 2, 29)));
      final reference = summarizeStats([
        tx('leap', DateTime(2024, 2, 29), 500),
      ], previous);
      final primary = cumulativeStatsSeries(
        summarizeStats([], current),
        current,
        isIncome: false,
      );
      final aligned = alignedStatsReference(
        primary,
        current,
        reference,
        previous,
        isIncome: false,
      );
      expect(aligned.points.length, 31);
      expect(aligned.points[27].amountMinor, 0);
      expect(aligned.points[28].amountMinor, 500);
      expect(aligned.points.last.amountMinor, 500);
    },
  );

  test('custom overview reference uses inclusive calendar days across DST', () {
    final selection = TimeFilterState(
      filter: TimeFilter.period,
      month: DateTime(2026, 10),
      start: DateTime(2026, 10, 24),
      end: DateTime(2026, 10, 26),
    );
    final current = selectedTimeWindow(selection)!;
    final previous = previousStatsWindow(selection, current)!;
    expect(previous.start, DateTime(2026, 10, 21));
    expect(previous.end, endOfDay(DateTime(2026, 10, 23)));
    final reference = summarizeStats([
      tx('first', DateTime(2026, 10, 21), 100),
      tx('last', DateTime(2026, 10, 23, 23, 59), 200),
      tx('income', DateTime(2026, 10, 22), 999, income: true),
    ], previous);
    final primary = cumulativeStatsSeries(
      summarizeStats([], current),
      current,
      isIncome: false,
    );
    expect(
      alignedStatsReference(
        primary,
        current,
        reference,
        previous,
        isIncome: false,
      ).points.map((p) => p.amountMinor),
      [100, 100, 300],
    );
    expect(
      previousStatsWindow(
        TimeFilterState(filter: TimeFilter.total, month: DateTime(2026)),
        null,
      ),
      isNull,
    );
  });

  test(
    'multi-month reference aligns elapsed days rather than bucket indexes',
    () {
      final selection = TimeFilterState(
        filter: TimeFilter.period,
        month: DateTime(2026, 4),
        start: DateTime(2026, 4, 15),
        end: DateTime(2026, 8, 15),
      );
      final current = selectedTimeWindow(selection)!;
      final previous = previousStatsWindow(selection, current)!;
      final reference = summarizeStats([
        tx(
          'early',
          DateTime(
            previous.start.year,
            previous.start.month,
            previous.start.day + 15,
          ),
          100,
        ),
        tx(
          'next',
          DateTime(
            previous.start.year,
            previous.start.month,
            previous.start.day + 16,
          ),
          200,
        ),
        tx('last', previous.end, 400),
      ], previous);
      final primary = cumulativeStatsSeries(
        summarizeStats([], current),
        current,
        isIncome: false,
      );
      final aligned = alignedStatsReference(
        primary,
        current,
        reference,
        previous,
        isIncome: false,
      );
      expect(primary.bucketSize, StatsBucketSize.month);
      expect(aligned.points.first.amountMinor, 100);
      expect(aligned.points.last.amountMinor, 700);
    },
  );

  test(
    'averages retain integer precision above the double exact-integer range',
    () {
      final result = compareStats(
        [
          tx('a', DateTime(2026, 1, 2), 9007199254740993, category: 'a'),
          tx('b', DateTime(2026, 2, 2), 9007199254740995, category: 'b'),
        ],
        StatsComparisonSelection(
          month: DateTime(2026, 3),
          referenceMonth: DateTime(2026, 2),
          mode: StatsComparisonMode.yearAverage,
        ),
        isIncome: false,
        now: DateTime(2026, 10, 28),
      );
      expect(result.referenceMinor, 9007199254740994);
      expect(result.changes.fold<int>(0, (v, c) => v + c.delta), result.delta);
    },
  );

  test(
    'legacy signed values remain intact and their averages conserve the total',
    () {
      final result = compareStats(
        [
          tx('a', DateTime(2026, 1, 2), -1, category: 'a'),
          tx('b', DateTime(2026, 2, 2), -1, category: 'b'),
        ],
        StatsComparisonSelection(
          month: DateTime(2026, 4),
          referenceMonth: DateTime(2026, 3),
          mode: StatsComparisonMode.yearAverage,
        ),
        isIncome: false,
        now: DateTime(2026, 10, 28),
      );
      expect(result.referenceMinor, -1);
      expect(result.changes.fold<int>(0, (v, c) => v + c.delta), result.delta);
    },
  );
  test(
    'period includes the entire final day and excludes neighbouring days',
    () {
      final state = TimeFilterState(
        filter: TimeFilter.period,
        month: DateTime(2026, 10),
        start: DateTime(2026, 10, 2),
        end: DateTime(2026, 10, 3),
      );
      final result = summarizeStats([
        tx('before', DateTime(2026, 10, 1, 23, 59), 100),
        tx('first', DateTime(2026, 10, 2), 200),
        tx('last', DateTime(2026, 10, 3, 23, 59, 59, 999, 999), 300),
        tx('after', DateTime(2026, 10, 4), 400),
      ], selectedTimeWindow(state));
      expect(result.expense, 500);
      expect(result.transactions.map((e) => e.id), ['first', 'last']);
    },
  );

  test('total preserves actual main-currency amounts and income direction', () {
    final items = [
      tx('expense', DateTime(2025), 450),
      tx('income', DateTime(2026), 1200, income: true),
    ];
    final result = summarizeStats(items, null);
    expect(result.income, 1200);
    expect(result.expense, 450);
    expect(result.net, 750);
    expect(result.categories(false), {'food': 450});
    expect(items.map((e) => e.amountCents), [450, 1200]);
  });

  test(
    'monthly selection includes leap day and ignores the same month of other years',
    () {
      final result = summarizeStats(
        [
          tx('old', DateTime(2023, 2, 20), 100),
          tx('leap', DateTime(2024, 2, 29, 23, 50), 200),
          tx('march', DateTime(2024, 3), 400),
        ],
        selectedTimeWindow(
          TimeFilterState(filter: TimeFilter.month, month: DateTime(2024, 2)),
        ),
      );
      expect(result.expense, 200);
    },
  );

  test(
    'cumulative daily points include empty days and retain the final total',
    () {
      final range = TimeWindow(
        start: DateTime(2026, 10, 1),
        end: endOfDay(DateTime(2026, 10, 4)),
      );
      final summary = summarizeStats([
        tx('a', DateTime(2026, 10, 1), 100),
        tx('b', DateTime(2026, 10, 3), 250),
        tx('income', DateTime(2026, 10, 2), 900, income: true),
      ], range);
      final series = cumulativeStatsSeries(summary, range, isIncome: false);
      expect(series.bucketSize, StatsBucketSize.day);
      expect(series.points.map((e) => e.amountMinor), [100, 100, 350, 350]);
      expect(
        cumulativeStatsSeries(
          summary,
          range,
          isIncome: true,
        ).points.last.amountMinor,
        900,
      );
    },
  );

  test('series never merges January across different years', () {
    final summary = summarizeStats([
      tx('a', DateTime(2025, 1), 100),
      tx('b', DateTime(2026, 1), 200),
    ], null);
    final series = cumulativeStatsSeries(summary, null, isIncome: false);
    expect(series.bucketSize, StatsBucketSize.month);
    expect(series.points, hasLength(13));
    expect(series.points.first.amountMinor, 100);
    expect(series.points.last.amountMinor, 300);
    expect(series.points.last.date, DateTime(2026, 1));
  });

  test('very long history uses years and retains all totals', () {
    final summary = summarizeStats([
      tx('a', DateTime(1990), 100),
      tx('b', DateTime(2026), 200),
    ], null);
    final series = cumulativeStatsSeries(summary, null, isIncome: false);
    expect(series.bucketSize, StatsBucketSize.year);
    expect(series.points, hasLength(37));
    expect(series.points.last.amountMinor, 300);
  });

  test('DST transition counts calendar days without losing a point', () {
    final range = TimeWindow(
      start: DateTime(2026, 10, 24),
      end: endOfDay(DateTime(2026, 10, 27)),
    );
    expect(
      cumulativeStatsSeries(
        const StatsSummary([], 0, 0),
        range,
        isIncome: false,
      ).points.map((p) => p.date.day),
      [24, 25, 26, 27],
    );
  });

  test('empty all-time series is empty and empty bounded series is zero', () {
    const empty = StatsSummary([], 0, 0);
    expect(cumulativeStatsSeries(empty, null, isIncome: false).points, isEmpty);
    final range = TimeWindow(
      start: DateTime(2026, 2),
      end: endOfDay(DateTime(2026, 2, 28)),
    );
    final points = cumulativeStatsSeries(empty, range, isIncome: false).points;
    expect(points, hasLength(28));
    expect(points.every((e) => e.amountMinor == 0), isTrue);
  });

  test(
    'default comparison is current calendar month versus previous month, across years',
    () {
      final selection = StatsComparisonSelection.current(DateTime(2026, 1, 15));
      final result = compareStats(
        [],
        selection,
        isIncome: false,
        now: DateTime(2026, 1, 15),
      );
      expect(selection.month, DateTime(2026, 1));
      expect(result.referenceMonths, [DateTime(2025, 12)]);
      expect(result.currentWindow.end, endOfDay(DateTime(2026, 1, 15)));
      expect(
        result.referenceWindows.single.end,
        endOfDay(DateTime(2025, 12, 15)),
      );
    },
  );

  test('current month aligns days and does not count later transactions', () {
    final result = compareStats(
      [
        tx('oct', DateTime(2026, 10, 15, 23, 59), 94000),
        tx('later', DateTime(2026, 10, 16), 500),
        tx('sep', DateTime(2026, 9, 15, 20), 110000),
        tx('later-sep', DateTime(2026, 9, 16), 999),
      ],
      StatsComparisonSelection.current(DateTime(2026, 10, 15)),
      isIncome: false,
      now: DateTime(2026, 10, 15),
    );
    expect(result.currentMinor, 94000);
    expect(result.referenceMinor, 110000);
    expect(result.delta, -16000);
    expect(result.percentage, closeTo(-14.54545, .0001));
  });

  test('alignment can be disabled to include the entire chosen months', () {
    final selection = StatsComparisonSelection.current(
      DateTime(2026, 10, 15),
    ).copyWith(alignElapsedDays: false);
    final result = compareStats(
      [tx('future-date', DateTime(2026, 10, 31, 23, 59), 123)],
      selection,
      isIncome: false,
      now: DateTime(2026, 10, 15),
    );
    expect(result.throughDay, isNull);
    expect(result.currentMinor, 123);
    expect(result.referenceWindows.single.end, endOfDay(DateTime(2026, 9, 30)));
  });

  for (final year in [2024, 2025]) {
    test('31st alignment clamps February correctly in $year', () {
      final selection = StatsComparisonSelection(
        month: DateTime(year, 3),
        referenceMonth: DateTime(year, 2),
        mode: StatsComparisonMode.month,
      );
      final result = compareStats(
        [],
        selection,
        isIncome: false,
        now: DateTime(year, 3, 31),
      );
      expect(
        result.referenceWindows.single.end,
        endOfDay(DateTime(year, 3, 0)),
      );
    });
  }

  test(
    'custom historical months use their full ranges and the explicit reference year',
    () {
      final selection = StatsComparisonSelection(
        month: DateTime(2024, 7),
        referenceMonth: DateTime(2023, 12),
        mode: StatsComparisonMode.month,
      );
      final result = compareStats(
        [
          tx('current', DateTime(2024, 7, 31, 23, 59), 100),
          tx('reference', DateTime(2023, 12, 31, 23, 59), 250),
        ],
        selection,
        isIncome: false,
        now: DateTime(2026, 10, 28),
      );
      expect(result.throughDay, isNull);
      expect(result.currentMinor, 100);
      expect(result.referenceMinor, 250);
    },
  );

  test(
    'year average includes zero months and excludes current and previous years',
    () {
      final selection = StatsComparisonSelection(
        month: DateTime(2026, 4),
        referenceMonth: DateTime(2026, 3),
        mode: StatsComparisonMode.yearAverage,
      );
      final result = compareStats(
        [
          tx('jan', DateTime(2026, 1, 5), 300),
          tx('mar', DateTime(2026, 3, 5), 600),
          tx('current', DateTime(2026, 4, 5), 400),
          tx('old', DateTime(2025, 1, 5), 99999),
          tx('later', DateTime(2026, 5, 5), 99999),
        ],
        selection,
        isIncome: false,
        now: DateTime(2026, 10, 28),
      );
      expect(result.referenceMonths, [
        DateTime(2026, 1),
        DateTime(2026, 2),
        DateTime(2026, 3),
      ]);
      expect(result.referenceMinor, 300);
      expect(result.delta, 100);
    },
  );

  test(
    'year average aligns each reference month for a partial current month',
    () {
      final selection = StatsComparisonSelection.current(
        DateTime(2026, 3, 10),
      ).copyWith(mode: StatsComparisonMode.yearAverage);
      final result = compareStats(
        [
          tx('jan', DateTime(2026, 1, 10), 100),
          tx('feb', DateTime(2026, 2, 10), 300),
          tx('late-jan', DateTime(2026, 1, 11), 90000),
        ],
        selection,
        isIncome: false,
        now: DateTime(2026, 3, 10),
      );
      expect(result.referenceMinor, 200);
      expect(result.referenceWindows.every((w) => w.end.day == 10), isTrue);
    },
  );

  test('January average is unavailable rather than division by zero', () {
    final result = compareStats(
      [],
      StatsComparisonSelection.current(
        DateTime(2026, 1, 3),
      ).copyWith(mode: StatsComparisonMode.yearAverage),
      isIncome: false,
      now: DateTime(2026, 1, 3),
    );
    expect(result.available, isFalse);
    expect(result.referenceMinor, 0);
    expect(result.percentage, isNull);
  });

  test('zero reference has a real delta but no fabricated percentage', () {
    final result = compareStats(
      [tx('a', DateTime(2026, 10, 1), 500)],
      StatsComparisonSelection.current(DateTime(2026, 10, 28)),
      isIncome: false,
      now: DateTime(2026, 10, 28),
    );
    expect(result.delta, 500);
    expect(result.percentage, isNull);
  });

  test(
    'category averages conserve the rounded total, even for one-minor-unit amounts',
    () {
      final result = compareStats(
        [
          tx('a', DateTime(2026, 1, 2), 1, category: 'a'),
          tx('b', DateTime(2026, 2, 2), 1, category: 'b'),
          tx('c', DateTime(2026, 3, 2), 1, category: 'c'),
        ],
        StatsComparisonSelection(
          month: DateTime(2026, 4),
          referenceMonth: DateTime(2026, 3),
          mode: StatsComparisonMode.yearAverage,
        ),
        isIncome: false,
        now: DateTime(2026, 10, 28),
      );
      expect(result.referenceMinor, 1);
      expect(result.changes.fold<int>(0, (v, c) => v + c.delta), result.delta);
    },
  );

  test(
    'income comparison excludes expenses, includes vanished categories, and retains large integer totals',
    () {
      final result = compareStats(
        [
          tx(
            'a',
            DateTime(2026, 9, 1),
            100000000001,
            income: true,
            category: 'old',
          ),
          tx(
            'b',
            DateTime(2026, 10, 1),
            100000000100,
            income: true,
            category: 'new',
          ),
          tx('expense', DateTime(2026, 10, 1), 88888888),
        ],
        StatsComparisonSelection.current(DateTime(2026, 10, 28)),
        isIncome: true,
        now: DateTime(2026, 10, 28),
      );
      expect(result.currentMinor, 100000000100);
      expect(result.delta, 99);
      expect(result.changes.map((e) => e.categoryId).toSet(), {'old', 'new'});
    },
  );
}
