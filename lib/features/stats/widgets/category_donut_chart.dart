import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../providers/category_expense_provider.dart';

class CategoryDonutChart extends ConsumerWidget {
  final bool monthly;

  const CategoryDonutChart({super.key, required this.monthly});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(categoryExpenseProvider);
    final t = AppLocalizations.of(context)!;

    if (data.isEmpty) {
      return Center(child: Text(t.noExpenses));
    }

    final total = data.fold<int>(0, (p, e) => p + e.amount);

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 55,
              sectionsSpace: 3,
              sections: data.map((e) {
                final percent = (e.amount / total) * 100;

                return PieChartSectionData(
                  value: e.amount.toDouble(),
                  color: Color(e.category.color),
                  radius: 60,
                  title: "${percent.toStringAsFixed(0)}%",
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 24),

        Column(
          children: data.map((e) {
            final percent = ((e.amount / total) * 100).toStringAsFixed(1);
            final value = (e.amount / 100).toStringAsFixed(2);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Color(e.category.color),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      e.category.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    "€$value   $percent%",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
