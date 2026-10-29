import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/currency/currency_metadata.dart';
import '../../../core/currency/currency_provider.dart';
import '../../../core/providers/balance_visibility_provider.dart';
import '../../../core/providers/time_filter_provider.dart';
import '../../transactions/providers/category_provider.dart';
import '../../../core/utils/category_localization.dart';
import '../providers/budget_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/dashboard_panel.dart';
import '../../../shared/widgets/inline_load_error.dart';
import '../../../shared/widgets/safe_prompt_dialog.dart';
import '../../../shared/widgets/vault_style.dart';

class BudgetCard extends ConsumerWidget {
  const BudgetCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(budgetOverviewProvider);
    final currency = ref.watch(currencyProvider).value?.baseCurrency ?? 'EUR';
    final locale = Localizations.localeOf(context).toString();
    final t = AppLocalizations.of(context)!;
    final timeState = ref.watch(timeFilterProvider);
    final showBalance = ref.watch(balanceVisibilityProvider);
    final categories = ref.watch(categoryProvider).value ?? const [];
    final categoryById = {for (final item in categories) item.id: item};
    final colors = Theme.of(context).colorScheme;
    final incomeColor = VaultColors.income(context);
    final expenseColor = VaultColors.expense(context);
    String hide(String value) => showBalance ? value : '••••';
    final title = switch (timeState.filter) {
      TimeFilter.total => t.availableAllTime,
      TimeFilter.month => t.availableThisMonth,
      TimeFilter.period => t.availableForPeriod,
    };
    return DashboardPanel(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: overview.when(
          loading: () => const LinearProgressIndicator(),
          error: (_, _) => InlineLoadError(
            onRetry: () => ref.invalidate(budgetOverviewProvider),
          ),
          data: (value) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  IconButton.filledTonal(
                    iconSize: 18,
                    visualDensity: VisualDensity.compact,
                    tooltip: showBalance ? t.hideAmounts : t.showAmounts,
                    onPressed: () {
                      ref.read(balanceVisibilityProvider.notifier).toggle();
                    },
                    icon: Icon(
                      showBalance ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  hide(
                    formatMoney(value.availableToSpendMinor, currency, locale),
                  ),
                  style: TextStyle(
                    fontSize: 40,
                    letterSpacing: -1.8,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: value.availableToSpendMinor < 0
                        ? Theme.of(context).colorScheme.error
                        : colors.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _BudgetMetric(
                        key: const ValueKey('budget-metric-income'),
                        label: t.incomes,
                        color: incomeColor,
                        value: hide(
                          formatMoney(value.incomeMinor, currency, locale),
                        ),
                      ),
                    ),
                    const VerticalDivider(width: 20),
                    Expanded(
                      child: _BudgetMetric(
                        key: const ValueKey('budget-metric-expense'),
                        label: t.expenses,
                        color: expenseColor,
                        value: hide(
                          formatMoney(value.expenseMinor, currency, locale),
                        ),
                      ),
                    ),
                    const VerticalDivider(width: 20),
                    Expanded(
                      child: _BudgetMetric(
                        key: const ValueKey('budget-metric-savings'),
                        label: t.reservedSavings,
                        color: VaultColors.savings(context),
                        value: hide(
                          formatMoney(
                            value.reservedSavingsMinor,
                            currency,
                            locale,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (value.upcomingRecurringIncomeMinor > 0 ||
                  value.upcomingRecurringExpensesMinor > 0) ...[
                const Divider(height: 36),
                Row(
                  key: const ValueKey('upcoming-transactions-summary'),
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 17,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        t.scheduledUpcoming,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (value.upcomingRecurringIncomeMinor > 0)
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                hide(
                                  '+${formatMoney(value.upcomingRecurringIncomeMinor, currency, locale)}',
                                ),
                                key: const ValueKey('upcoming-income-total'),
                                semanticsLabel: showBalance
                                    ? '${t.incomes}: ${formatMoney(value.upcomingRecurringIncomeMinor, currency, locale)}'
                                    : '${t.incomes}: ••••',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                  fontWeight: FontWeight.w600,
                                  color: incomeColor,
                                ),
                              ),
                            ),
                          if (value.upcomingRecurringIncomeMinor > 0 &&
                              value.upcomingRecurringExpensesMinor > 0)
                            const SizedBox(height: 5),
                          if (value.upcomingRecurringExpensesMinor > 0)
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                hide(
                                  '-${formatMoney(value.upcomingRecurringExpensesMinor, currency, locale)}',
                                ),
                                key: const ValueKey('upcoming-expense-total'),
                                semanticsLabel: showBalance
                                    ? '${t.expenses}: ${formatMoney(value.upcomingRecurringExpensesMinor, currency, locale)}'
                                    : '${t.expenses}: ••••',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                  fontWeight: FontWeight.w600,
                                  color: expenseColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              if (value.budgets.isNotEmpty) ...[
                const Divider(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        t.categoryLimits,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      tooltip: t.budgets,
                      visualDensity: VisualDensity.compact,
                      onPressed: () => showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        showDragHandle: true,
                        builder: (_) => const BudgetManagerSheet(),
                      ),
                      icon: const Icon(Icons.tune_rounded, size: 21),
                    ),
                  ],
                ),
                ...value.budgets
                    .take(3)
                    .map(
                      (progress) => Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Builder(
                          builder: (context) {
                            final category =
                                categoryById[progress.budget.categoryId];
                            final label = category == null
                                ? progress.budget.categoryId
                                : categoryName(category.name, t);
                            final over = progress.remainingMinor < 0;
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        label,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${hide(formatMoney(progress.spentMinor, currency, locale))} / '
                                      '${hide(formatMoney(progress.limitMinor, currency, locale))}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: progress.ratio.clamp(0, 1),
                                    minHeight: 8,
                                    color: over
                                        ? Theme.of(context).colorScheme.error
                                        : null,
                                  ),
                                ),
                                if (over) ...[
                                  const SizedBox(height: 5),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      t.budgetExceededBy(
                                        hide(
                                          formatMoney(
                                            -progress.remainingMinor,
                                            currency,
                                            locale,
                                          ),
                                        ),
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.error,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ),
                    ),
              ] else ...[
                const SizedBox(height: 14),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: colors.primaryContainer.withValues(
                      alpha: .28,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    showDragHandle: true,
                    builder: (_) => const BudgetManagerSheet(),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add_chart_rounded, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t.setOptionalLimit,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.north_east_rounded, size: 15),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BudgetMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _BudgetMetric({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            maxLines: 1,
            style: TextStyle(
              fontFeatures: const [FontFeature.tabularFigures()],
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class BudgetManagerSheet extends ConsumerWidget {
  const BudgetManagerSheet({super.key});

  Future<void> _editBudget(
    BuildContext context,
    WidgetRef ref,
    String categoryId,
    String categoryName,
    int? currentAmount,
  ) async {
    final currency = ref.read(currencyProvider).value?.baseCurrency ?? 'EUR';
    final t = AppLocalizations.of(context)!;
    final result = await showDialog<String>(
      context: context,
      builder: (_) => SafePromptDialog(
        title: t.budgetForCategory(categoryName),
        label: t.amountInCurrency(currency),
        cancelLabel: t.cancel,
        confirmLabel: t.save,
        initialValue: currentAmount == null
            ? ''
            : amountInputText(currentAmount, currency),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: (value) {
          final amount = double.tryParse(value.replaceAll(',', '.'));
          return amount == null || amount <= 0 ? t.enterPositiveAmount : null;
        },
      ),
    );
    final amount = double.tryParse(result?.replaceAll(',', '.') ?? '');
    if (amount == null || amount <= 0) return;
    await ref
        .read(budgetProvider.notifier)
        .setMonthlyBudget(
          categoryId: categoryId,
          amountMinor: majorToMinor(amount, currency),
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final currency = ref.watch(currencyProvider).value?.baseCurrency ?? 'EUR';
    final locale = Localizations.localeOf(context).toString();
    final categories = ref.watch(categoryProvider).value ?? const [];
    final budgets = ref.watch(budgetProvider).value ?? const [];
    final byCategory = {
      for (final budget in budgets) budget.categoryId: budget,
    };
    final expenseCategories = categories.where(
      (category) => !category.isIncome,
    );
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: .82,
        child: Column(
          children: [
            ListTile(
              title: Text(
                t.budgets,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: Text(t.optionalMonthlyBudgets),
            ),
            Expanded(
              child: ListView(
                children: expenseCategories.map((category) {
                  final budget = byCategory[category.id];
                  return ListTile(
                    leading: CategoryAvatar(category: category),
                    title: Text(categoryName(category.name, t)),
                    subtitle: Text(
                      budget == null
                          ? t.noBudget
                          : formatMoney(budget.amountMinor, currency, locale),
                    ),
                    trailing: budget == null
                        ? const Icon(Icons.add_circle_outline)
                        : IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              await ref
                                  .read(budgetProvider.notifier)
                                  .removeBudget(budget.id);
                              if (!context.mounted) return;
                              messenger
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    content: Text(t.budgetDeleted),
                                    action: SnackBarAction(
                                      label: t.undo,
                                      onPressed: () => unawaited(
                                        ref
                                            .read(budgetProvider.notifier)
                                            .restoreBudget(budget),
                                      ),
                                    ),
                                  ),
                                );
                            },
                          ),
                    onTap: () => _editBudget(
                      context,
                      ref,
                      category.id,
                      categoryName(category.name, t),
                      budget?.amountMinor,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
