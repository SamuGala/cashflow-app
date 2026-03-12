import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../stats/providers/category_expense_provider.dart';

class ExpensePieChart extends ConsumerWidget {
  const ExpensePieChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(categoryExpenseProvider);

    if (data.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            "Add at least one expense to view the graphic.",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final total = data.fold<int>(0, (sum, item) => sum + item.amount);

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: data.map((item) {
            final percentage = item.amount / total;

            return PieChartSectionData(
              value: item.amount.toDouble(),
              color: Color(item.category.color),
              title: "${(percentage * 100).toStringAsFixed(0)}%",
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
