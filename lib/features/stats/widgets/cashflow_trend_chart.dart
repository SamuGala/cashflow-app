import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../transactions/providers/transaction_provider.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../../transactions/domain/transaction.dart';

class CashflowTrendChart extends ConsumerWidget {
  final bool monthly;

  const CashflowTrendChart({super.key, required this.monthly});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final txAsync = ref.watch(transactionProvider);

    return txAsync.when(
      loading: () => const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) =>
          SizedBox(height: 220, child: Center(child: Text(e.toString()))),
      data: (transactions) {
        List<TransactionModel> filtered = transactions;

        /// filtro mese se necessario
        if (monthly) {
          filtered = transactions.where((tx) {
            return tx.date.month == selectedMonth.month &&
                tx.date.year == selectedMonth.year;
          }).toList();
        }

        if (filtered.isEmpty) {
          return const SizedBox(height: 220);
        }

        /// ordina per data
        filtered.sort((a, b) => a.date.compareTo(b.date));

        final spots = <FlSpot>[];

        double balance = 0;

        for (int i = 0; i < filtered.length; i++) {
          final tx = filtered[i];

          final amount = tx.amountCents / 100;

          if (tx.isIncome) {
            balance += amount;
          } else {
            balance -= amount;
          }

          spots.add(FlSpot(i.toDouble(), balance));
        }

        final values = spots.map((e) => e.y).toList();
        final minY = values.reduce((a, b) => a < b ? a : b);
        final maxY = values.reduce((a, b) => a > b ? a : b);

        return SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              minY: minY - 50,
              maxY: maxY + 50,
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  barWidth: 3,
                  color: const Color(0xff6366F1),
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: const Color(0xff6366F1).withOpacity(0.15),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
