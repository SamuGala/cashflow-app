import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dashboard/widgets/revolut_month_selector.dart';
import '../../../l10n/app_localizations.dart';

import '../widgets/category_donut_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/statistics_income_expense_chart.dart';
import '../widgets/premium_fintech_chart.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.stats,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// TOTAL / MONTH
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
            const SizedBox(height: 24),
          ],

          /// DONUT CHART
          SizedBox(height: monthly ? 16 : 32),

          CategoryDonutChart(monthly: monthly),

          const SizedBox(height: 40),

          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Theme.of(context).dividerColor.withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          PremiumFintechChart(monthly: monthly),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
