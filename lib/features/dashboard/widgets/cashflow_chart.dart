import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../stats/providers/monthly_summary_provider.dart';

class CashflowChart extends ConsumerWidget {
  const CashflowChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final summary = ref.watch(monthlySummaryProvider);

    final income = summary.income / 100;
    final expense = summary.expense / 100;

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(show: false),
          gridData: const FlGridData(show: false),

          barGroups: [

            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: income,
                  color: Colors.green,
                  width: 22,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            ),

            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: expense,
                  color: Colors.red,
                  width: 22,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            ),
          ],
        ),
        swapAnimationDuration:
            const Duration(milliseconds: 400),
      ),
    );
  }
}