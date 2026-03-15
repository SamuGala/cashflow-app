import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/selected_month_provider.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../domain/dashboard_filter.dart';

class DashboardStats {
  final int income;
  final int expense;

  const DashboardStats({required this.income, required this.expense});

  int get balance => income - expense;
}

class DashboardQuery {
  final DashboardFilter filter;
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
  final selectedMonth = ref.watch(selectedMonthProvider);

  final transactions = transactionsAsync.value ?? const [];

  int income = 0;
  int expense = 0;

  for (final t in transactions) {
    bool include = true;

    if (query.filter == DashboardFilter.month) {
      include =
          t.date.month == selectedMonth.month &&
          t.date.year == selectedMonth.year;
    }

    if (query.filter == DashboardFilter.period &&
        query.start != null &&
        query.end != null) {
      include = !t.date.isBefore(query.start!) && !t.date.isAfter(query.end!);
    }

    if (!include) continue;

    if (t.isIncome) {
      income += t.amountCents;
    } else {
      expense += t.amountCents;
    }
  }

  return DashboardStats(income: income, expense: expense);
});
