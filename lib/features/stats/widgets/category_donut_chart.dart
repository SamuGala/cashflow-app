import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/providers/category_provider.dart';
import '../../../core/providers/selected_month_provider.dart';

import '../../dashboard/domain/dashboard_filter.dart';
import '../../dashboard/providers/dashboard_provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/utils/category_localization.dart';
import '../../transactions/domain/category.dart';

class CategoryDonutChart extends ConsumerStatefulWidget {
  final DashboardQuery query;

  const CategoryDonutChart({super.key, required this.query});

  @override
  ConsumerState<CategoryDonutChart> createState() => _CategoryDonutChartState();
}

class _CategoryDonutChartState extends ConsumerState<CategoryDonutChart>
    with SingleTickerProviderStateMixin {
  int? selectedIndex;

  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CategoryDonutChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.query != widget.query) {
      controller.forward(from: 0);
      selectedIndex = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final txAsync = ref.watch(transactionProvider);
    final categoriesAsync = ref.watch(categoryProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);

    final t = AppLocalizations.of(context)!;

    return txAsync.when(
      loading: () => const SizedBox(
        height: 280,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) =>
          SizedBox(height: 280, child: Center(child: Text(e.toString()))),
      data: (transactions) {
        final categories = categoriesAsync.value ?? [];

        Iterable filtered = transactions;

        if (widget.query.filter == DashboardFilter.month) {
          filtered = transactions.where(
            (tx) =>
                tx.date.month == selectedMonth.month &&
                tx.date.year == selectedMonth.year,
          );
        }

        if (widget.query.filter == DashboardFilter.period &&
            widget.query.start != null &&
            widget.query.end != null) {
          filtered = transactions.where(
            (tx) =>
                !tx.date.isBefore(widget.query.start!) &&
                !tx.date.isAfter(widget.query.end!),
          );
        }

        final expenses = filtered.where((tx) => !tx.isIncome).toList();

        if (expenses.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Center(child: Text(t.noExpenses)),
          );
        }

        final Map<String, double> map = {};

        for (final tx in expenses) {
          final amount = (tx.amountCents as num).toDouble();
          map.update(tx.categoryId, (v) => v + amount, ifAbsent: () => amount);
        }

        final data = map.entries.map((entry) {
          final category =
              categories.where((c) => c.id == entry.key).firstOrNull ??
              categories.first;

          return (category, entry.value);
        }).toList();

        final total = data.fold<double>(0, (sum, e) => sum + e.$2);

        final selected =
            (selectedIndex != null &&
                selectedIndex! >= 0 &&
                selectedIndex! < data.length)
            ? data[selectedIndex!]
            : null;

        return Column(
          children: [
            const SizedBox(height: 16),

            /// DONUT
            SizedBox(
              height: 280,
              child: AnimatedBuilder(
                animation: controller,
                builder: (_, __) {
                  return PieChart(
                    PieChartData(
                      centerSpaceRadius: 80,
                      sectionsSpace: 4,

                      pieTouchData: PieTouchData(
                        enabled: true,
                        touchCallback: (event, response) {
                          if (!event.isInterestedForInteractions ||
                              response == null ||
                              response.touchedSection == null) {
                            if (selectedIndex != null) {
                              setState(() => selectedIndex = null);
                            }
                            return;
                          }

                          final index =
                              response.touchedSection!.touchedSectionIndex;

                          if (index != selectedIndex) {
                            setState(() => selectedIndex = index);
                          }
                        },
                      ),

                      sections: data.asMap().entries.map((entry) {
                        final i = entry.key;
                        final e = entry.value;

                        final isSelected = selectedIndex == i;

                        final baseRadius = 78.0;
                        final radius = isSelected ? 96.0 : baseRadius;

                        return PieChartSectionData(
                          value: e.$2 * controller.value,
                          color: Color(e.$1.color),
                          radius: radius,
                          title: "",
                        );
                      }).toList(),
                    ),
                    swapAnimationDuration: const Duration(milliseconds: 450),
                    swapAnimationCurve: Curves.easeOutCubic,
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            /// CENTER LABEL
            Column(
              children: [
                Text(
                  selected != null
                      ? categoryName(selected.$1.name, t)
                      : t.expenses,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  selected != null
                      ? "€ ${(selected.$2 / 100).toStringAsFixed(2)}"
                      : "€ ${(total / 100).toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// LEGEND
            Column(
              children: data.asMap().entries.map((entry) {
                final i = entry.key;
                final e = entry.value;

                final percent = ((e.$2 / total) * 100).toStringAsFixed(1);
                final amount = (e.$2 / 100).toStringAsFixed(2);

                final selectedRow = selectedIndex == i;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = selectedRow ? null : i;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 4,
                    ),
                    decoration: BoxDecoration(
                      color: selectedRow
                          ? Color(e.$1.color).withOpacity(.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: selectedRow ? 18 : 14,
                          height: selectedRow ? 18 : 14,
                          decoration: BoxDecoration(
                            color: Color(e.$1.color),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: selectedRow
                                ? [
                                    BoxShadow(
                                      color: Color(e.$1.color).withOpacity(.6),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            categoryName(e.$1.name, t),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "$percent%",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "€ $amount",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
