import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dashboard/widgets/revolut_month_selector.dart';
import '../../dashboard/presentation/dashboard_page.dart';
import '../../dashboard/domain/dashboard_filter.dart';
import '../../dashboard/providers/dashboard_provider.dart';

import '../../../l10n/app_localizations.dart';

import '../widgets/category_donut_chart.dart';
import '../widgets/premium_fintech_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/time_filter_provider.dart';

class StatsPage extends ConsumerStatefulWidget {
  const StatsPage({super.key});

  @override
  ConsumerState<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends ConsumerState<StatsPage> {
  @override
  Widget build(BuildContext context) {
    final timeState = ref.watch(timeFilterProvider);

    final filter = timeState.filter;
    final start = timeState.start;
    final end = timeState.end;
    final month = timeState.month;
    final t = AppLocalizations.of(context)!;

    final stats = ref.watch(
      dashboardProvider(
        DashboardQuery(
          filter: DashboardFilter.values[filter.index],
          start: start,
          end: end,
        ),
      ),
    );

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
          PremiumSegmentedSelector(
            labels: [t.total, t.month, t.period],
            selectedIndex: filter.index,
            onChanged: (index) {
              ref
                  .read(timeFilterProvider.notifier)
                  .setFilter(TimeFilter.values[index]);
            },
          ),

          const SizedBox(height: 16),

          if (filter == TimeFilter.month) ...[
            RevolutMonthSelector(
              initialDate: month,
              onChanged: (date) {
                ref.read(timeFilterProvider.notifier).setMonth(date);
              },
            ),
            const SizedBox(height: 24),
          ],

          if (filter == TimeFilter.period) ...[
            PeriodSelector(
              start: start,
              end: end,
              onChanged: (s, e) {
                ref.read(timeFilterProvider.notifier).setPeriod(s, e);
              },
            ),
            const SizedBox(height: 24),
          ],

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: CategoryDonutChart(
              query: DashboardQuery(
                filter: DashboardFilter.values[filter.index],
                start: start,
                end: end,
              ),
            ),
          ),

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

          PremiumFintechChart(
            query: DashboardQuery(
              filter: DashboardFilter.values[filter.index],
              start: start,
              end: end,
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class PeriodSelector extends StatelessWidget {
  final DateTime? start;
  final DateTime? end;
  final Function(DateTime, DateTime) onChanged;

  const PeriodSelector({
    super.key,
    required this.start,
    required this.end,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final locale = Localizations.localeOf(context).toString();

    String format(DateTime? d) {
      if (d == null) return t.selectPeriod;
      return DateFormat.MMM(locale).addPattern(' yyyy').format(d);
    }

    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();

        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(now.year - 5),
          lastDate: DateTime(now.year + 1),
          initialDateRange: start != null && end != null
              ? DateTimeRange(start: start!, end: end!)
              : null,
        );

        if (picked != null) {
          onChanged(picked.start, picked.end);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.date_range),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "${format(start)} → ${format(end)}",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.expand_more),
          ],
        ),
      ),
    );
  }
}
