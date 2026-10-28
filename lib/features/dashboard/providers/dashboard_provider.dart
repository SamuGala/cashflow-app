import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/time_filter_provider.dart';
import '../../transactions/providers/transaction_provider.dart';

class DashboardStats {
  final int income;
  final int expense;

  const DashboardStats({required this.income, required this.expense});

  int get balance => income - expense;
}

class DashboardQuery {
  final TimeFilter filter;
  final DateTime? start;
  final DateTime? end;

  const DashboardQuery({required this.filter, this.start, this.end});

  @override
  bool operator ==(Object other) {
    return other is DashboardQuery &&
        other.filter == filter &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode => Object.hash(filter, start, end);
}

final dashboardProvider = Provider.family<DashboardStats, DashboardQuery>((
  ref,
  query,
) {
  final transactionsAsync = ref.watch(transactionProvider);
  final timeState = ref.watch(timeFilterProvider);

  final transactions = transactionsAsync.value ?? [];

  int income = 0;
  int expense = 0;
  final filterState = TimeFilterState(
    filter: query.filter,
    month: query.filter == TimeFilter.month
        ? query.start ?? timeState.month
        : timeState.month,
    start: query.start,
    end: query.end,
  );

  for (final t in transactions) {
    final include = isInSelectedTimeWindow(t.date, filterState);

    if (!include) continue;

    if (t.isIncome) {
      income += t.amountCents;
    } else {
      expense += t.amountCents;
    }
  }

  return DashboardStats(income: income, expense: expense);
});
