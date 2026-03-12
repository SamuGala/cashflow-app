import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/database_provider.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../../transactions/providers/transaction_provider.dart';

class DashboardStats {
  final int income;
  final int expense;

  const DashboardStats({required this.income, required this.expense});

  int get balance => income - expense;
}

final dashboardProvider = Provider.family<DashboardStats, bool>((ref, monthly) {
  final transactionsAsync = ref.watch(transactionProvider);
  final selectedMonth = ref.watch(selectedMonthProvider);

  final transactions = transactionsAsync.value ?? const [];

  int income = 0;
  int expense = 0;

  for (final t in transactions) {
    final sameMonth =
        t.date.month == selectedMonth.month &&
        t.date.year == selectedMonth.year;

    if (monthly && !sameMonth) continue;

    if (t.isIncome) {
      income += t.amountCents;
    } else {
      expense += t.amountCents;
    }
  }

  return DashboardStats(income: income, expense: expense);
});
