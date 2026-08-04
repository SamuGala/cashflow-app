import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/currency/currency_metadata.dart';
import '../../../core/currency/currency_provider.dart';
import '../../../core/providers/balance_visibility_provider.dart';
import '../../../core/utils/category_localization.dart';
import '../../transactions/providers/category_provider.dart';
import '../providers/cashflow_forecast_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/dashboard_panel.dart';
import '../../../shared/widgets/inline_load_error.dart';

class CashflowForecastCard extends ConsumerStatefulWidget {
  const CashflowForecastCard({super.key});

  @override
  ConsumerState<CashflowForecastCard> createState() =>
      _CashflowForecastCardState();
}

class _CashflowForecastCardState extends ConsumerState<CashflowForecastCard> {
  final _occurrenceController = ScrollController();

  @override
  void dispose() {
    _occurrenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final forecast = ref.watch(cashflowForecastProvider);
    final horizon = ref.watch(forecastHorizonProvider);
    final showBalance = ref.watch(balanceVisibilityProvider);
    final currency = ref.watch(currencyProvider).value?.baseCurrency ?? 'EUR';
    final locale = Localizations.localeOf(context).toString();
    final categories = ref.watch(categoryProvider).value ?? const [];
    final t = AppLocalizations.of(context)!;
    final categoryNames = {
      for (final category in categories)
        category.id: categoryName(category.name, t),
    };
    String hide(String value) => showBalance ? value : '••••';
    final horizonLabel = _horizonLabel(horizon, t);
    return DashboardPanel(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: forecast.when(
          loading: () => const LinearProgressIndicator(),
          error: (_, _) => InlineLoadError(
            onRetry: () => ref.invalidate(cashflowForecastProvider),
          ),
          data: (value) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_graph_rounded),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      t.forecastRecurring,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  PopupMenuButton<ForecastHorizon>(
                    initialValue: horizon,
                    tooltip: t.forecastRecurring,
                    onSelected: (value) {
                      if (_occurrenceController.hasClients) {
                        _occurrenceController.jumpTo(0);
                      }
                      ref
                          .read(forecastHorizonProvider.notifier)
                          .setHorizon(value);
                    },
                    itemBuilder: (_) => ForecastHorizon.values
                        .map(
                          (value) => PopupMenuItem(
                            value: value,
                            child: Row(
                              children: [
                                Expanded(child: Text(_horizonLabel(value, t))),
                                if (value == horizon)
                                  Icon(
                                    Icons.check_rounded,
                                    size: 19,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withValues(alpha: .6),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            horizonLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Icon(Icons.expand_more_rounded, size: 17),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _ForecastValue(
                      label: t.currentBalance,
                      value: hide(
                        formatMoney(
                          value.currentBalanceMinor,
                          currency,
                          locale,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 42,
                    child: Center(
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withValues(alpha: .55),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _ForecastValue(
                      label: t.forecastAfter(horizonLabel),
                      value: hide(
                        formatMoney(
                          value.projectedBalanceMinor,
                          currency,
                          locale,
                        ),
                      ),
                      highlighted: true,
                      alignEnd: true,
                    ),
                  ),
                ],
              ),
              if (value.occurrences.isEmpty) ...[
                const SizedBox(height: 10),
                Text(t.noForecastMovements),
              ],
              if (value.occurrences.isNotEmpty) ...[
                const Divider(height: 24),
                SizedBox(
                  height: math.min(value.occurrences.length, 4) * 44,
                  child: Scrollbar(
                    controller: _occurrenceController,
                    thumbVisibility: value.occurrences.length > 4,
                    radius: const Radius.circular(8),
                    child: ListView.separated(
                      controller: _occurrenceController,
                      padding: EdgeInsets.only(
                        right: value.occurrences.length > 4 ? 10 : 0,
                      ),
                      physics: value.occurrences.length > 4
                          ? const BouncingScrollPhysics()
                          : const NeverScrollableScrollPhysics(),
                      itemCount: value.occurrences.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        final item = value.occurrences[index];
                        return SizedBox(
                          height: 40,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 64,
                                child: Text(
                                  DateFormat.MMMd(locale).format(item.date),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  item.note ??
                                      categoryNames[item.categoryId] ??
                                      item.categoryId,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${item.isIncome ? '+' : '−'}${hide(formatMoney(item.amountMinor, currency, locale))}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: item.isIncome ? Colors.green : null,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _horizonLabel(
    ForecastHorizon horizon,
    AppLocalizations localizations,
  ) {
    return switch (horizon) {
      ForecastHorizon.oneMonth => localizations.oneMonth,
      ForecastHorizon.twoMonths => localizations.monthsCount(2),
      ForecastHorizon.threeMonths => localizations.monthsCount(3),
      ForecastHorizon.sixMonths => localizations.monthsCount(6),
      ForecastHorizon.oneYear => localizations.oneYear,
      ForecastHorizon.twoYears => localizations.yearsCount(2),
      ForecastHorizon.fiveYears => localizations.yearsCount(5),
    };
  }
}

class _ForecastValue extends StatelessWidget {
  final String label;
  final String value;
  final bool highlighted;
  final bool alignEnd;

  const _ForecastValue({
    required this.label,
    required this.value,
    this.highlighted = false,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: highlighted ? Theme.of(context).colorScheme.primary : null,
          ),
        ),
      ],
    );
  }
}
