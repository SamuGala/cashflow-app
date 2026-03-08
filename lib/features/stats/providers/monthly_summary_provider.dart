import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/selected_month_provider.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/domain/transaction.dart';

class MonthlySummary {
  final int income;
  final int expense;

  const MonthlySummary(this.income, this.expense);
}

final monthlySummaryProvider = Provider<MonthlySummary>((ref) {
  final transactionsAsync = ref.watch(transactionProvider);
  final month = ref.watch(selectedMonthProvider);

  final transactions = transactionsAsync.value ?? const <TransactionModel>[];

  int income = 0;
  int expense = 0;

  for (final t in transactions) {
    if (t.date.month == month.month && t.date.year == month.year) {
      if (t.isIncome) {
        income += t.amountCents;
      } else {
        expense += t.amountCents;
      }
    }
  }

  return MonthlySummary(income, expense);
});