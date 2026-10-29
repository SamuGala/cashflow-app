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
import '../../../shared/widgets/inline_load_error.dart';
import '../../../shared/widgets/vault_style.dart';

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
    final byId = {for (final category in categories) category.id: category};
    String hide(String value) => showBalance ? value : '••••';
    final horizonLabel = _horizonLabel(horizon, t);
    final colors = Theme.of(context).colorScheme;
    return VaultSurface(
      child: forecast.when(
        loading: () => const LinearProgressIndicator(),
        error: (_, _) => InlineLoadError(
          onRetry: () => ref.invalidate(cashflowForecastProvider),
        ),
        data: (value) {
          final delta = value.projectedBalanceMinor - value.currentBalanceMinor;
          final deltaColor = VaultColors.flow(context, delta >= 0);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.auto_graph_rounded,
                      size: 18,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      t.forecastRecurring,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -.2,
                      ),
                    ),
                  ),
                  PopupMenuButton<ForecastHorizon>(
                    initialValue: horizon,
                    tooltip: t.forecastRecurring,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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
                                    color: colors.primary,
                                  ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            horizonLabel,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: colors.primary,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.expand_more_rounded,
                            size: 18,
                            color: colors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: deltaColor.withValues(alpha: .12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        delta >= 0
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        size: 16,
                        color: deltaColor,
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
                      color: value.projectedBalanceMinor < 0
                          ? VaultColors.expense(context)
                          : colors.primary,
                      alignEnd: true,
                    ),
                  ),
                ],
              ),
              if (value.occurrences.isEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  t.noForecastMovements,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
              if (value.occurrences.isNotEmpty) ...[
                Divider(
                  height: 28,
                  thickness: .7,
                  color: colors.outlineVariant.withValues(alpha: .6),
                ),
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
                        final category = byId[item.categoryId];
                        return SizedBox(
                          height: 40,
                          child: Row(
                            children: [
                              CategoryAvatar(category: category, size: 34),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.note ??
                                          (category == null
                                              ? item.categoryId
                                              : categoryName(category.name, t)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        height: 1.2,
                                      ),
                                    ),
                                    Text(
                                      DateFormat.MMMd(locale).format(item.date),
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 12,
                                        height: 1.2,
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${item.isIncome ? '+' : '−'}${hide(formatMoney(item.amountMinor, currency, locale))}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: VaultColors.flow(
                                    context,
                                    item.isIncome,
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
              ],
            ],
          );
        },
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
  final Color? color;
  final bool alignEnd;

  const _ForecastValue({
    required this.label,
    required this.value,
    this.color,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
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
          style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(
            value,
            maxLines: 1,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              letterSpacing: -.4,
              color: color ?? colors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
