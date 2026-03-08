import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/monthly_summary_provider.dart';

class CashflowTrendChart extends ConsumerWidget {
  final bool monthly;

  const CashflowTrendChart({super.key, required this.monthly});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(monthlySummaryProvider);

    final income = summary.income / 100;
    final expense = summary.expense / 100;

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            horizontalInterval: 50,
            getDrawingHorizontalLine: (value) {
              return FlLine(color: Colors.grey.shade300, strokeWidth: 1);
            },
          ),

          titlesData: const FlTitlesData(show: false),

          borderData: FlBorderData(show: false),

          lineBarsData: [
            /// ENTRATE
            LineChartBarData(
              spots: [FlSpot(0, 0), FlSpot(1, income)],

              isCurved: true,
              color: Colors.green,
              barWidth: 3,

              belowBarData: BarAreaData(
                show: true,
                color: Colors.green.withOpacity(0.15),
              ),
            ),

            /// USCITE
            LineChartBarData(
              spots: [FlSpot(0, 0), FlSpot(1, expense)],

              isCurved: true,
              color: Colors.red,
              barWidth: 3,

              belowBarData: BarAreaData(
                show: true,
                color: Colors.red.withOpacity(0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
