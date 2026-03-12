import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/providers/category_provider.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../../transactions/domain/category.dart';
import '../../../l10n/app_localizations.dart';

class CategoryDonutChart extends ConsumerWidget {
  final bool monthly;

  const CategoryDonutChart({super.key, required this.monthly});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionProvider);
    final categoriesAsync = ref.watch(categoryProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);

    final t = AppLocalizations.of(context)!;

    return transactionsAsync.when(
      loading: () => const SizedBox(
        height: 260,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) =>
          SizedBox(height: 260, child: Center(child: Text(e.toString()))),
      data: (transactions) {
        final categories = categoriesAsync.value ?? [];

        /// filtro mese
        final filtered = monthly
            ? transactions.where((tx) {
                return tx.date.month == selectedMonth.month &&
                    tx.date.year == selectedMonth.year;
              }).toList()
            : transactions;

        /// solo spese
        final expenses = filtered.where((tx) => !tx.isIncome).toList();

        if (expenses.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Center(child: Text(t.noExpenses)),
          );
        }

        /// aggregazione categorie
        final Map<String, int> map = {};

        for (final tx in expenses) {
          map.update(
            tx.categoryId,
            (value) => value + tx.amountCents,
            ifAbsent: () => tx.amountCents,
          );
        }

        final data = map.entries.map((entry) {
          final category =
              categories.where((c) => c.id == entry.key).firstOrNull ??
              categories.first;

          return (category, entry.value);
        }).toList();

        final total = data.fold<int>(0, (sum, e) => sum + e.$2);

        return Column(
          children: [
            SizedBox(
              height: 240,
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 65,
                  sectionsSpace: 4,
                  pieTouchData: PieTouchData(enabled: true),
                  sections: data.map((e) {
                    final percent = (e.$2 / total) * 100;

                    return PieChartSectionData(
                      value: e.$2.toDouble(),
                      color: Color(e.$1.color),
                      radius: 70,
                      title: "${percent.toStringAsFixed(0)}%",
                      titleStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    );
                  }).toList(),
                ),
                swapAnimationDuration: const Duration(milliseconds: 600),
                swapAnimationCurve: Curves.easeOutCubic,
              ),
            ),

            const SizedBox(height: 30),

            /// legenda
            Column(
              children: data.map((e) {
                final percent = ((e.$2 / total) * 100).toStringAsFixed(1);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Color(e.$1.color),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          e.$1.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        "$percent%",
                        style: TextStyle(
                          color: Colors.grey.shade600,
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
      },
    );
  }
}
