import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../transactions/providers/transaction_provider.dart';
import '../../../core/providers/selected_month_provider.dart';

class PremiumFintechChart extends ConsumerStatefulWidget {
  final bool monthly;

  const PremiumFintechChart({super.key, required this.monthly});

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
    )..forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txAsync = ref.watch(transactionProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);

    return txAsync.when(
      loading: () => const SizedBox(
        height: 240,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox(),
      data: (transactions) {
        final filtered = widget.monthly
            ? transactions.where(
                (tx) =>
                    tx.date.month == selectedMonth.month &&
                    tx.date.year == selectedMonth.year,
              )
            : transactions;

        final Map<int, double> income = {};
        final Map<int, double> expense = {};

        for (final tx in filtered) {
          final key = widget.monthly ? tx.date.day : tx.date.month;

          if (tx.isIncome) {
            income.update(
              key,
              (v) => v + tx.amountCents / 100,
              ifAbsent: () => tx.amountCents / 100,
            );
          } else {
            expense.update(
              key,
              (v) => v + tx.amountCents / 100,
              ifAbsent: () => tx.amountCents / 100,
            );
          }
        }

        final maxX = widget.monthly ? 31 : 12;

        List<FlSpot> incomeSpots = [];
        List<FlSpot> expenseSpots = [];

        for (int i = 1; i <= maxX; i++) {
          final inc = income[i] ?? 0;
          final exp = expense[i] ?? 0;

          incomeSpots.add(FlSpot(i.toDouble(), inc));
          expenseSpots.add(FlSpot(i.toDouble(), exp));
        }

        final allValues = [
          ...incomeSpots.map((e) => e.y),
          ...expenseSpots.map((e) => e.y),
        ];

        final minY = allValues.isEmpty
            ? 0
            : allValues.reduce((a, b) => a < b ? a : b);
        final maxY = allValues.isEmpty
            ? 0
            : allValues.reduce((a, b) => a > b ? a : b);

        return Column(
          children: [
            SizedBox(
              height: 240,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (_, __) {
                    return SizedBox(
                      width: double.infinity,
                      child: LineChart(
                        LineChartData(
                          clipData: const FlClipData.all(),
                          minY: -maxY * 0.16,
                          maxY: maxY * 1.25,
                          gridData: FlGridData(
                            drawVerticalLine: false,
                            horizontalInterval: (maxY / 4).clamp(20, 200),
                            getDrawingHorizontalLine: (_) => FlLine(
                              color: Colors.grey.withOpacity(0.08),
                              strokeWidth: 1,
                            ),
                          ),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineTouchData: LineTouchData(
                            handleBuiltInTouches: true,
                            getTouchedSpotIndicator: (barData, indicators) =>
                                indicators
                                    .map(
                                      (i) => TouchedSpotIndicatorData(
                                        FlLine(
                                          color: Colors.grey.withOpacity(0.25),
                                          strokeWidth: 1,
                                        ),
                                        FlDotData(
                                          getDotPainter: (_, __, ___, ____) =>
                                              FlDotCirclePainter(
                                                radius: 4,
                                                color: Colors.white,
                                                strokeWidth: 2,
                                                strokeColor: Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                              ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipColor: (touchedSpot) => Colors.black,
                            ),
                          ),
                          lineBarsData: [
                            if (showIncome)
                              LineChartBarData(
                                spots: incomeSpots
                                    .map(
                                      (s) =>
                                          FlSpot(s.x, s.y * controller.value),
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
                                      (s) =>
                                          FlSpot(s.x, s.y * controller.value),
                                    )
                                    .toList(),
                                isCurved: true,
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
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendChip(
                  color: Colors.green,
                  label: "Income",
                  active: showIncome,
                  onTap: () => setState(() => showIncome = !showIncome),
                ),
                const SizedBox(width: 14),
                _LegendChip(
                  color: Colors.red,
                  label: "Expense",
                  active: showExpense,
                  onTap: () => setState(() => showExpense = !showExpense),
                ),
              ],
            ),
            const SizedBox(height: 10),
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
