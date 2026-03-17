import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/providers/category_provider.dart';
import '../../../core/providers/time_filter_provider.dart';

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
    final timeState = ref.watch(timeFilterProvider);
    final selectedMonth = timeState.month;

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

        if (widget.query.filter == TimeFilter.month) {
          final month = widget.query.start ?? selectedMonth;

          filtered = transactions.where(
            (tx) => tx.date.month == month.month && tx.date.year == month.year,
          );
        }

        if (widget.query.filter == TimeFilter.period &&
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
        }).toList()..sort((a, b) => b.$2.compareTo(a.$2));

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

            /// DONUT + CENTER LABEL
            SizedBox(
              height: 280,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: controller,
                    builder: (_, __) {
                      return PieChart(
                        PieChartData(
                          centerSpaceRadius: 80,
                          sectionsSpace: 6,
                          pieTouchData: PieTouchData(
                            enabled: true,
                            touchCallback: (event, response) {
                              if (response == null ||
                                  response.touchedSection == null)
                                return;

                              final index =
                                  response.touchedSection!.touchedSectionIndex;

                              setState(() {
                                selectedIndex = index;
                              });
                            },
                          ),
                          sections: data.asMap().entries.map((entry) {
                            final i = entry.key;
                            final e = entry.value;

                            final isSelected = selectedIndex == i;

                            const baseRadius = 64.0;
                            final radius = isSelected ? 85.0 : baseRadius;

                            final baseColor = Color(e.$1.color);

                            return PieChartSectionData(
                              value: e.$2 * controller.value,
                              radius: radius,
                              title: "",
                              gradient: LinearGradient(
                                colors: [baseColor.withOpacity(.8), baseColor],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            );
                          }).toList(),
                        ),
                        swapAnimationDuration: const Duration(
                          milliseconds: 450,
                        ),
                        swapAnimationCurve: Curves.easeOutCubic,
                      );
                    },
                  ),

                  /// CENTER LABEL (ABBASSATA)
                  /// CENTER LABEL
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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
                        const SizedBox(height: 4),
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
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),

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
