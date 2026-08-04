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
    String hide(String value) => showBalance ? value : '••••';
    final title = switch (timeState.filter) {
      TimeFilter.total => t.availableAllTime,
      TimeFilter.month => t.availableThisMonth,
      TimeFilter.period => t.availableForPeriod,
    };
    return DashboardPanel(
      child: Padding(
        padding: const EdgeInsets.all(18),
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
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withValues(alpha: .6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton.filledTonal(
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
              const SizedBox(height: 8),
              Text(
                hide(
                  formatMoney(value.availableToSpendMinor, currency, locale),
                ),
                style: TextStyle(
                  fontSize: 29,
                  fontWeight: FontWeight.w800,
                  color: value.availableToSpendMinor < 0
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _BudgetMetric(
                      label: t.incomes,
                      value: hide(
                        formatMoney(value.incomeMinor, currency, locale),
                      ),
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _BudgetMetric(
                      label: t.expenses,
                      value: hide(
                        formatMoney(value.expenseMinor, currency, locale),
                      ),
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _BudgetMetric(
                      label: t.reservedSavings,
                      value: hide(
                        formatMoney(
                          value.reservedSavingsMinor,
                          currency,
                          locale,
                        ),
                      ),
                      color: Colors.indigo,
                    ),
                  ),
                ],
              ),
              if (value.upcomingRecurringExpensesMinor > 0) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded, size: 17),
                    const SizedBox(width: 7),
                    Expanded(child: Text(t.scheduledUpcoming)),
                    Text(
                      hide(
                        formatMoney(
                          value.upcomingRecurringExpensesMinor,
                          currency,
                          locale,
                        ),
                      ),
                      style: const TextStyle(fontWeight: FontWeight.w700),
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
                OutlinedButton.icon(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    showDragHandle: true,
                    builder: (_) => const BudgetManagerSheet(),
                  ),
                  icon: const Icon(Icons.add_chart_rounded),
                  label: Text(t.setOptionalLimit),
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
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
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
                    leading: CircleAvatar(
                      backgroundColor: Color(
                        category.color,
                      ).withValues(alpha: .15),
                      child: Icon(
                        category.isDefault
                            ? categoryIcon(category.name)
                            : customCategoryIcon(category.icon),
                        color: Color(category.color),
                      ),
                    ),
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
