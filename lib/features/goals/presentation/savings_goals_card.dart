import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/currency/currency_metadata.dart';
import '../../../core/currency/currency_provider.dart';
import '../../../core/database/app_database.dart';
import '../../../core/input_formatters/capitalize_first_letter_formatter.dart';
import '../../../core/providers/balance_visibility_provider.dart';
import '../../../core/providers/time_filter_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/dashboard_panel.dart';
import '../../../shared/widgets/inline_load_error.dart';
import '../../../shared/widgets/safe_prompt_dialog.dart';
import '../providers/savings_goals_provider.dart';

class SavingsGoalsCard extends ConsumerWidget {
  const SavingsGoalsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(savingsGoalsProvider);
    final contributions = ref.watch(savingsGoalContributionsProvider);
    final timeState = ref.watch(timeFilterProvider);
    final showBalance = ref.watch(balanceVisibilityProvider);
    final currency = ref.watch(currencyProvider).value?.baseCurrency ?? 'EUR';
    final locale = Localizations.localeOf(context).toString();
    final t = AppLocalizations.of(context)!;
    String hide(String value) => showBalance ? value : '••••';
    final allocatedInSelection = contributions.value
        ?.where((row) => isInSelectedTimeWindow(row.createdAt, timeState))
        .fold<int>(0, (total, row) => total + row.amountMinor);

    return DashboardPanel(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.tertiaryContainer.withValues(alpha: .65),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.savings_outlined, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t.savingsGoals,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    showDragHandle: true,
                    builder: (_) => const SavingsGoalsSheet(),
                  ),
                  child: Text(t.manage),
                ),
              ],
            ),
            if (allocatedInSelection != null && allocatedInSelection != 0) ...[
              const SizedBox(height: 10),
              Text(
                t.allocatedInSelection(
                  hide(formatMoney(allocatedInSelection, currency, locale)),
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            goals.when(
              loading: () => const Padding(
                padding: EdgeInsets.only(top: 10),
                child: LinearProgressIndicator(),
              ),
              error: (_, _) => InlineLoadError(
                onRetry: () => ref.invalidate(savingsGoalsProvider),
              ),
              data: (items) => items.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(t.createGoalHint),
                    )
                  : Column(
                      children: items.take(2).map((goal) {
                        final ratio = goal.targetAmountMinor == 0
                            ? 0.0
                            : (goal.savedAmountMinor / goal.targetAmountMinor)
                                  .clamp(0.0, 1.0);
                        return Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      goal.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${hide(formatMoney(goal.savedAmountMinor, currency, locale))} / '
                                    '${hide(formatMoney(goal.targetAmountMinor, currency, locale))}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: LinearProgressIndicator(
                                  value: ratio,
                                  minHeight: 8,
                                ),
                              ),
                            ],
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

class SavingsGoalsSheet extends ConsumerWidget {
  const SavingsGoalsSheet({super.key});

  void _showFailure(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(t.savingsUpdateFailed)));
  }

  Future<double?> _amountDialog(
    BuildContext context, {
    required String title,
    required String currency,
    int? maximumMinor,
  }) async {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final result = await showDialog<String>(
      context: context,
      builder: (_) => SafePromptDialog(
        title: title,
        label: t.amountInCurrency(currency),
        cancelLabel: t.cancel,
        confirmLabel: t.save,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: (value) {
          final amount = double.tryParse(value.replaceAll(',', '.'));
          if (amount == null || amount <= 0) return t.enterPositiveAmount;
          if (maximumMinor != null &&
              majorToMinor(amount, currency) > maximumMinor) {
            return t.maximumAmount(formatMoney(maximumMinor, currency, locale));
          }
          return null;
        },
      ),
    );
    return double.tryParse(result?.replaceAll(',', '.') ?? '');
  }

  Future<void> _addGoal(BuildContext context, WidgetRef ref) async {
    final t = AppLocalizations.of(context)!;
    final name = await showDialog<String>(
      context: context,
      builder: (_) => SafePromptDialog(
        title: t.newGoal,
        label: t.goalName,
        cancelLabel: t.cancel,
        confirmLabel: t.continueAction,
        textCapitalization: TextCapitalization.sentences,
        inputFormatters: const [CapitalizeFirstLetterFormatter()],
        validator: (value) => value.isEmpty ? t.goalName : null,
      ),
    );
    if (name == null || name.isEmpty || !context.mounted) return;
    final currency = ref.read(currencyProvider).value?.baseCurrency ?? 'EUR';
    final amount = await _amountDialog(
      context,
      title: t.goalTarget(name),
      currency: currency,
    );
    if (amount == null || amount <= 0) return;
    try {
      await ref
          .read(savingsGoalsProvider.notifier)
          .addGoal(
            name: name,
            targetAmountMinor: majorToMinor(amount, currency),
          );
    } catch (_) {
      if (context.mounted) _showFailure(context);
    }
  }

  Future<void> _reserve(
    BuildContext context,
    WidgetRef ref,
    SavingsGoalRow goal,
    String currency,
  ) async {
    final t = AppLocalizations.of(context)!;
    final remaining = goal.targetAmountMinor - goal.savedAmountMinor;
    if (remaining <= 0) return;
    final amount = await _amountDialog(
      context,
      title: t.addSavings,
      currency: currency,
      maximumMinor: remaining,
    );
    if (amount == null || amount <= 0) return;
    try {
      await ref
          .read(savingsGoalsProvider.notifier)
          .contribute(goal.id, majorToMinor(amount, currency));
    } catch (_) {
      if (context.mounted) _showFailure(context);
    }
  }

  Future<void> _release(
    BuildContext context,
    WidgetRef ref,
    SavingsGoalRow goal,
    String currency,
  ) async {
    final t = AppLocalizations.of(context)!;
    if (goal.savedAmountMinor <= 0) return;
    final amount = await _amountDialog(
      context,
      title: t.releaseSavings,
      currency: currency,
      maximumMinor: goal.savedAmountMinor,
    );
    if (amount == null || amount <= 0) return;
    try {
      await ref
          .read(savingsGoalsProvider.notifier)
          .release(goal.id, majorToMinor(amount, currency));
    } catch (_) {
      if (context.mounted) _showFailure(context);
    }
  }

  Future<void> _deleteGoal(
    BuildContext context,
    WidgetRef ref,
    SavingsGoalRow goal,
  ) async {
    final t = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.deleteGoal),
        content: Text(t.deleteGoalReleasesFunds),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(t.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final removal = await ref
        .read(savingsGoalsProvider.notifier)
        .remove(goal.id);
    if (!context.mounted) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(t.goalDeleted),
          action: SnackBarAction(
            label: t.undo,
            onPressed: () => unawaited(
              ref.read(savingsGoalsProvider.notifier).restore(removal),
            ),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final goals = ref.watch(savingsGoalsProvider);
    final currency = ref.watch(currencyProvider).value?.baseCurrency ?? 'EUR';
    final locale = Localizations.localeOf(context).toString();
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: .86,
        child: Column(
          children: [
            ListTile(
              title: Text(
                t.savingsGoals,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: Text(t.savingsReservedHint),
              trailing: FilledButton.icon(
                onPressed: () => _addGoal(context, ref),
                icon: const Icon(Icons.add),
                label: Text(t.newGoal),
              ),
            ),
            Expanded(
              child: goals.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator.adaptive()),
                error: (_, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: InlineLoadError(
                      onRetry: () => ref.invalidate(savingsGoalsProvider),
                    ),
                  ),
                ),
                data: (items) => items.isEmpty
                    ? Center(child: Text(t.noGoals))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final goal = items[index];
                          final ratio = goal.targetAmountMinor <= 0
                              ? 0.0
                              : (goal.savedAmountMinor / goal.targetAmountMinor)
                                    .clamp(0.0, 1.0);
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Color(
                                          goal.color,
                                        ).withValues(alpha: .14),
                                        child: Icon(
                                          goal.completed
                                              ? Icons.check_rounded
                                              : Icons.savings_outlined,
                                          color: Color(goal.color),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              goal.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            Text(
                                              '${formatMoney(goal.savedAmountMinor, currency, locale)} / '
                                              '${formatMoney(goal.targetAmountMinor, currency, locale)}',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: t.delete,
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: () =>
                                            _deleteGoal(context, ref, goal),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  LinearProgressIndicator(
                                    value: ratio,
                                    minHeight: 8,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: FilledButton.tonalIcon(
                                          onPressed:
                                              goal.savedAmountMinor >=
                                                  goal.targetAmountMinor
                                              ? null
                                              : () => _reserve(
                                                  context,
                                                  ref,
                                                  goal,
                                                  currency,
                                                ),
                                          icon: const Icon(
                                            Icons.savings_outlined,
                                          ),
                                          label: Text(t.reserveFunds),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: goal.savedAmountMinor <= 0
                                              ? null
                                              : () => _release(
                                                  context,
                                                  ref,
                                                  goal,
                                                  currency,
                                                ),
                                          icon: const Icon(
                                            Icons.outbox_outlined,
                                          ),
                                          label: Text(t.releaseFunds),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
