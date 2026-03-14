import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../transactions/providers/transaction_provider.dart';
import '../../../core/providers/selected_month_provider.dart';

class IncomeExpenseChart extends ConsumerWidget {
  final bool monthly;

  const IncomeExpenseChart({super.key, required this.monthly});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);

    return transactionsAsync.when(
      loading: () => const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox(),
      data: (transactions) {
        final filtered = monthly
            ? transactions.where(
                (tx) =>
                    tx.date.month == selectedMonth.month &&
                    tx.date.year == selectedMonth.year,
              )
            : transactions;

        final Map<int, double> income = {};
        final Map<int, double> expense = {};

        for (final tx in filtered) {
          final day = tx.date.day;

          if (tx.isIncome) {
            income.update(
              day,
              (v) => v + tx.amountCents / 100,
              ifAbsent: () => tx.amountCents / 100,
            );
          } else {
            expense.update(
              day,
              (v) => v + tx.amountCents / 100,
              ifAbsent: () => tx.amountCents / 100,
            );
          }
        }

        List<FlSpot> incomeSpots = [];
        List<FlSpot> expenseSpots = [];

        for (int i = 1; i <= 31; i++) {
          incomeSpots.add(FlSpot(i.toDouble(), income[i] ?? 0));
          expenseSpots.add(FlSpot(i.toDouble(), expense[i] ?? 0));
        }

        return SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),

              titlesData: const FlTitlesData(show: false),

              lineBarsData: [
                LineChartBarData(
                  spots: incomeSpots,
                  isCurved: true,
                  color: Colors.green,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                ),
                LineChartBarData(
                  spots: expenseSpots,
                  isCurved: true,
                  color: Colors.red,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
