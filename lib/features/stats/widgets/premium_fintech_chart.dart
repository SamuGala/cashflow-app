import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../transactions/providers/transaction_provider.dart';
import '../../../core/providers/time_filter_provider.dart';

import '../../dashboard/providers/dashboard_provider.dart';
import '../../../l10n/app_localizations.dart';

class PremiumFintechChart extends ConsumerStatefulWidget {
  final DashboardQuery query;

  const PremiumFintechChart({super.key, required this.query});

  @override
  ConsumerState<PremiumFintechChart> createState() =>
      _PremiumFintechChartState();
}

class _PremiumFintechChartState extends ConsumerState<PremiumFintechChart>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  bool showIncome = true;
  bool showExpense = true;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.forward();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final txAsync = ref.watch(transactionProvider);
    final timeState = ref.watch(timeFilterProvider);
    final selectedMonth = timeState.month;

    return txAsync.when(
      loading: () => const SizedBox(
        height: 260,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox(),
      data: (transactions) {
        Iterable filtered = transactions;

        if (widget.query.filter == TimeFilter.month) {
          final month = widget.query.start ?? DateTime.now();

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

        final Map<int, double> income = {};
        final Map<int, double> expense = {};

        final monthly = widget.query.filter == TimeFilter.month;

        for (final tx in filtered) {
          final key = monthly ? tx.date.day : tx.date.month;

          final amount = (tx.amountCents as num).toDouble() / 100;

          if (tx.isIncome) {
            income.update(key, (v) => v + amount, ifAbsent: () => amount);
          } else {
            expense.update(key, (v) => v + amount, ifAbsent: () => amount);
          }
        }

        final maxX = monthly ? 31 : 12;

        List<FlSpot> incomeSpots = [];
        List<FlSpot> expenseSpots = [];

        for (int i = 1; i <= maxX; i++) {
          incomeSpots.add(FlSpot(i.toDouble(), income[i] ?? 0));
          expenseSpots.add(FlSpot(i.toDouble(), expense[i] ?? 0));
        }

        final allValues = [
          ...incomeSpots.map((e) => e.y),
          ...expenseSpots.map((e) => e.y),
        ];

        final maxY = allValues.isEmpty
            ? 0
            : allValues.reduce((a, b) => a > b ? a : b);

        return Column(
          children: [
            SizedBox(
              height: 260,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (_, __) {
                    return LineChart(
                      LineChartData(
                        clipData: const FlClipData.all(),
                        minY: -maxY * 0.15,
                        maxY: maxY * 1.3,

                        gridData: FlGridData(
                          drawVerticalLine: false,
                          horizontalInterval: ((maxY / 4).clamp(
                            20,
                            200,
                          )).toDouble(),
                          getDrawingHorizontalLine: (_) => FlLine(
                            color: Colors.grey.withOpacity(0.08),
                            strokeWidth: 1,
                          ),
                        ),

                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),

                        lineTouchData: LineTouchData(
                          handleBuiltInTouches: true,
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (spots) {
                              return spots.map((s) {
                                return LineTooltipItem(
                                  "€ ${s.y.toStringAsFixed(2)}",
                                  const TextStyle(color: Colors.white),
                                );
                              }).toList();
                            },
                          ),
                        ),

                        lineBarsData: [
                          if (showIncome)
                            LineChartBarData(
                              spots: incomeSpots
                                  .map(
                                    (s) => FlSpot(s.x, s.y * controller.value),
                                  )
                                  .toList(),
                              isCurved: true,
                              curveSmoothness: 0.35,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green.shade400,
                                  Colors.green.shade600,
                                ],
                              ),
                              barWidth: 4,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.green.withOpacity(0.25),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),

                          if (showExpense)
                            LineChartBarData(
                              spots: expenseSpots
                                  .map(
                                    (s) => FlSpot(s.x, s.y * controller.value),
                                  )
                                  .toList(),
                              isCurved: true,
                              curveSmoothness: 0.35,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.red.shade400,
                                  Colors.red.shade600,
                                ],
                              ),
                              barWidth: 4,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.red.withOpacity(0.25),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 22),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendChip(
                  color: Colors.green,
                  label: t.incomes,
                  active: showIncome,
                  onTap: () => setState(() => showIncome = !showIncome),
                ),
                const SizedBox(width: 14),
                _LegendChip(
                  color: Colors.red,
                  label: t.expenses,
                  active: showExpense,
                  onTap: () => setState(() => showExpense = !showExpense),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _LegendChip extends StatelessWidget {
  final Color color;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _LegendChip({
    required this.color,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: active
              ? color.withOpacity(0.18)
              : Colors.grey.withOpacity(0.06),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
