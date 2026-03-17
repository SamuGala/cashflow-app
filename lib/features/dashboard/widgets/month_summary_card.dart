import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/dashboard_provider.dart';
import '../../../core/providers/time_filter_provider.dart';
import '../../../l10n/app_localizations.dart';

class MonthSummaryCard extends ConsumerWidget {
  const MonthSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(
  dashboardProvider(
    DashboardQuery(
      filter: TimeFilter.month,
    ),
  ),
);

    final t = AppLocalizations.of(context)!;

    final locale = Localizations.localeOf(context).toString();
    final currency = NumberFormat.currency(locale: locale, symbol: '€');

    final saved = stats.income - stats.expense;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(t.month, style: const TextStyle(fontWeight: FontWeight.w700)),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t.income),
              Text(currency.format(stats.income / 100)),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t.expense),
              Text(currency.format(stats.expense / 100)),
            ],
          ),

          const Divider(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(t.balance), Text(currency.format(saved / 100))],
          ),
        ],
      ),
    );
  }
}
