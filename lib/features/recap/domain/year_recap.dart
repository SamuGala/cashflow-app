import '../../../core/database/app_database.dart';
import '../../transactions/domain/transaction.dart';

/// One recurring expense with what it cost over the recap year.
class RecapRecurring {
  final RecurringTransaction row;
  final int occurrences;
  final int yearlyMinor;

  const RecapRecurring({
    required this.row,
    required this.occurrences,
    required this.yearlyMinor,
  });
}

/// The year in numbers, computed on device from the local archive. Amounts
/// are base-currency minor units, as stored.
class YearRecap {
  final int year;
  final int incomeMinor;
  final int spentMinor;
  final List<int> monthlySpent;

  /// Months with at least one movement, up to today for the current year.
  final List<int> activeMonths;
  final List<MapEntry<String, int>> topCategories;

  /// Distinct expense categories used in the year.
  final int categoryCount;
  final TransactionModel? biggestExpense;
  final int movementCount;

  /// Movements per weekday, Monday first.
  final List<int> weekdayCounts;
  final List<RecapRecurring> recurring;
  final List<SavingsGoalRow> goals;

  /// Months in which every budget stayed within its limit, of [budgetMonths].
  final int? budgetMonthsKept;
  final int budgetMonths;
  final DateTime? firstMovement;
  final int? previousSpentMinor;
  final int? previousIncomeMinor;

  const YearRecap({
    required this.year,
    required this.incomeMinor,
    required this.spentMinor,
    required this.monthlySpent,
    required this.activeMonths,
    required this.topCategories,
    required this.categoryCount,
    required this.biggestExpense,
    required this.movementCount,
    required this.weekdayCounts,
    required this.recurring,
    required this.goals,
    required this.budgetMonthsKept,
    required this.budgetMonths,
    required this.firstMovement,
    required this.previousSpentMinor,
    required this.previousIncomeMinor,
  });

  bool get isEmpty => movementCount == 0;
  int get netMinor => incomeMinor - spentMinor;

  /// Share of income kept, or null without income.
  int? get savedPercent =>
      incomeMinor <= 0 ? null : (netMinor * 100 / incomeMinor).round();

  bool get hasPrevious => (previousSpentMinor ?? 0) > 0;

  /// Spending change against the previous year, in percent.
  int? get spentChangePercent => !hasPrevious
      ? null
      : ((spentMinor - previousSpentMinor!) * 100 / previousSpentMinor!)
            .round();

  int? get previousSavedPercent {
    final income = previousIncomeMinor ?? 0;
    if (income <= 0) return null;
    return ((income - previousSpentMinor!) * 100 / income).round();
  }

  int? get priciestMonth => _extreme(max: true);
  int? get lightestMonth => _extreme(max: false);

  /// Needs two active months, otherwise "most" and "least" say nothing.
  int? _extreme({required bool max}) {
    if (activeMonths.length < 2) return null;
    var best = activeMonths.first;
    for (final month in activeMonths) {
      final value = monthlySpent[month - 1];
      final current = monthlySpent[best - 1];
      if (max ? value > current : value < current) best = month;
    }
    return best;
  }

  int get averageMonthlySpent =>
      activeMonths.isEmpty ? 0 : spentMinor ~/ activeMonths.length;

  int get busiestWeekday {
    var best = 0;
    for (var i = 1; i < 7; i++) {
      if (weekdayCounts[i] > weekdayCounts[best]) best = i;
    }
    return best + 1;
  }

  int get recurringYearlyMinor =>
      recurring.fold(0, (total, item) => total + item.yearlyMinor);

  int percentOfSpent(int minor) =>
      spentMinor <= 0 ? 0 : (minor * 100 / spentMinor).round();
}

/// The year a recap is offered for: last year in January, else this year.
int defaultRecapYear(DateTime now) => now.month == 1 ? now.year - 1 : now.year;

/// Home banner window: from 20 December to the end of January.
bool isRecapSeason(DateTime now) =>
    (now.month == 12 && now.day >= 20) || now.month == 1;

YearRecap buildYearRecap({
  required int year,
  required Iterable<TransactionModel> transactions,
  required Iterable<RecurringTransaction> recurring,
  required Iterable<SavingsGoalRow> goals,
  required Iterable<BudgetRow> budgets,
  required DateTime now,
}) {
  var income = 0;
  var spent = 0;
  var previousIncome = 0;
  var previousSpent = 0;
  final monthly = List.filled(12, 0);
  final active = <int>{};
  final byCategory = <String, int>{};
  final weekdays = List.filled(7, 0);
  TransactionModel? biggest;
  DateTime? first;
  var count = 0;
  final spentByMonthCategory = <(int, String), int>{};
  final generatedBySource = <String, (int, int)>{};

  for (final tx in transactions) {
    if (tx.date.year == year - 1) {
      if (tx.isIncome) {
        previousIncome += tx.amountCents;
      } else {
        previousSpent += tx.amountCents;
      }
      continue;
    }
    if (tx.date.year != year || tx.date.isAfter(now)) continue;
    count++;
    active.add(tx.date.month);
    weekdays[tx.date.weekday - 1]++;
    if (first == null || tx.date.isBefore(first)) first = tx.date;
    if (tx.isIncome) {
      income += tx.amountCents;
      continue;
    }
    spent += tx.amountCents;
    monthly[tx.date.month - 1] += tx.amountCents;
    byCategory[tx.categoryId] =
        (byCategory[tx.categoryId] ?? 0) + tx.amountCents;
    final key = (tx.date.month, tx.categoryId);
    spentByMonthCategory[key] =
        (spentByMonthCategory[key] ?? 0) + tx.amountCents;
    final source = tx.recurringSourceId;
    if (source != null) {
      final (times, total) = generatedBySource[source] ?? (0, 0);
      generatedBySource[source] = (times + 1, total + tx.amountCents);
    }
    // Recurring charges are expected; the "biggest" is a one-off.
    if (tx.recurringSourceId == null &&
        (biggest == null || tx.amountCents > biggest.amountCents)) {
      biggest = tx;
    }
  }

  final categories = byCategory.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  // What recurrences really charged: the movements they generated.
  final rows = {for (final row in recurring) row.id: row};
  final recurringItems = <RecapRecurring>[];
  for (final entry in generatedBySource.entries) {
    final row = rows[entry.key];
    if (row == null || row.isIncome) continue;
    recurringItems.add(
      RecapRecurring(
        row: row,
        occurrences: entry.value.$1,
        yearlyMinor: entry.value.$2,
      ),
    );
  }
  recurringItems.sort((a, b) => b.yearlyMinor.compareTo(a.yearlyMinor));

  // A month counts once it is over (or is the current one) and had budgets.
  var budgetMonths = 0;
  var budgetMonthsKept = 0;
  final activeBudgets = budgets.where((b) => b.active && b.amountMinor > 0);
  for (var month = 1; month <= 12; month++) {
    final start = DateTime(year, month);
    if (start.isAfter(now)) break;
    final monthEnd = DateTime(year, month + 1, 0);
    final applying = activeBudgets.where(
      (b) => !DateTime(b.createdAt.year, b.createdAt.month).isAfter(monthEnd),
    );
    if (applying.isEmpty) continue;
    budgetMonths++;
    final kept = applying.every(
      (b) =>
          (spentByMonthCategory[(month, b.categoryId)] ?? 0) <= b.amountMinor,
    );
    if (kept) budgetMonthsKept++;
  }

  return YearRecap(
    year: year,
    incomeMinor: income,
    spentMinor: spent,
    monthlySpent: monthly,
    activeMonths: active.toList()..sort(),
    topCategories: categories.take(5).toList(),
    categoryCount: categories.length,
    biggestExpense: biggest,
    movementCount: count,
    weekdayCounts: weekdays,
    recurring: recurringItems,
    goals: [...goals.where((g) => g.targetAmountMinor > 0)]
      ..sort((a, b) => b.savedAmountMinor.compareTo(a.savedAmountMinor)),
    budgetMonthsKept: budgetMonths == 0 ? null : budgetMonthsKept,
    budgetMonths: budgetMonths,
    firstMovement: first,
    previousSpentMinor: previousSpent == 0 ? null : previousSpent,
    previousIncomeMinor: previousIncome == 0 ? null : previousIncome,
  );
}
