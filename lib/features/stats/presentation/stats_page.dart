import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/selected_month_provider.dart';
import '../../dashboard/widgets/revolut_month_selector.dart';

import '../widgets/category_donut_chart.dart';
import '../widgets/cashflow_trend_chart.dart';
import '../../../l10n/app_localizations.dart';

class StatsPage extends ConsumerStatefulWidget {
  const StatsPage({super.key});

  @override
  ConsumerState<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends ConsumerState<StatsPage> {

  bool monthly = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;


    final selectedMonth = ref.watch(selectedMonthProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.stats,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [

          /// TOTAL / MONTH TOGGLE
          Row(
            children: [

              ChoiceChip(
                label: Text(t.total),
                selected: !monthly,
                onSelected: (_) {
                  setState(() {
                    monthly = false;
                  });
                },
              ),

              const SizedBox(width: 8),

              ChoiceChip(
                label: Text(t.month),
                selected: monthly,
                onSelected: (_) {
                  setState(() {
                    monthly = true;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// MONTH SELECTOR
          if (monthly) ...[
            const RevolutMonthSelector(),
            const SizedBox(height: 20),
          ],

          /// PIE CHART
          Text(
            t.expensesDistribution,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 24),

          CategoryDonutChart(
            monthly: monthly,
          ),

          const SizedBox(height: 40),

          /// CASHFLOW TREND
          const Text(
            "Trend Cashflow",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 20),

          CashflowTrendChart(
            monthly: monthly,
          ),
        ],
      ),
    );
  }
}