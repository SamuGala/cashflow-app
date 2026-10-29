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
import '../../../shared/widgets/inline_load_error.dart';
import '../../../shared/widgets/safe_prompt_dialog.dart';
import '../../../shared/widgets/vault_dialogs.dart';
import '../../../shared/widgets/vault_style.dart';
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

    final colors = Theme.of(context).colorScheme;
    final savings = VaultColors.savings(context);
    return VaultSurface(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: savings.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.savings_outlined, size: 18, color: savings),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  t.savingsGoals,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -.2,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  useRootNavigator: true,
                  showDragHandle: true,
                  builder: (_) => const SavingsGoalsSheet(),
                ),
                child: Text(
                  t.manage,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            // Keeps the rows clear of the floating actions on the Home tab.
            padding: const EdgeInsets.only(right: _floatingActionLane),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (allocatedInSelection != null &&
                    allocatedInSelection != 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    key: const ValueKey('goal-period-allocation'),
                    t.allocatedInSelection(
                      hide(formatMoney(allocatedInSelection, currency, locale)),
                    ),
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 12.5,
                    ),
                  ),
                ],
                goals.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: LinearProgressIndicator(),
                  ),
                  error: (_, _) => InlineLoadError(
                    onRetry: () => ref.invalidate(savingsGoalsProvider),
                  ),
                  data: (items) => items.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            t.createGoalHint,
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            for (final goal in items.take(2))
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: _GoalProgressRow(
                                  goal: goal,
                                  amounts:
                                      '${hide(formatMoney(goal.savedAmountMinor, currency, locale))} / '
                                      '${hide(formatMoney(goal.targetAmountMinor, currency, locale))}',
                                ),
                              ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const double _floatingActionLane = 68;

double _goalRatio(SavingsGoalRow goal) => goal.targetAmountMinor <= 0
    ? 0.0
    : (goal.savedAmountMinor / goal.targetAmountMinor).clamp(0.0, 1.0);

class _GoalProgressRow extends StatelessWidget {
  const _GoalProgressRow({required this.goal, required this.amounts});

  final SavingsGoalRow goal;
  final String amounts;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tint = Color(goal.color);
    final ratio = _goalRatio(goal);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                goal.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(ratio * 100).round()}%',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: tint,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _GoalBar(ratio: ratio, color: tint),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            amounts,
            key: ValueKey('goal-total-${goal.id}'),
            style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

class _GoalBar extends StatelessWidget {
  const _GoalBar({required this.ratio, required this.color, this.height = 6});

  final double ratio;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: ColoredBox(
          color: dark ? const Color(0xFF2C3848) : const Color(0xFFEAEFF5),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: ratio),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (_, value, _) => FractionallySizedBox(
                widthFactor: value,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(height),
                  ),
                ),
              ),
            ),
          ),
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
    final confirmed = await showVaultDeleteDialog(
      context,
      title: t.deleteGoal,
      message: t.deleteGoalReleasesFunds,
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
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: .86,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.savingsGoals,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t.savingsReservedHint,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onPressed: () => _addGoal(context, ref),
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: Text(t.newGoal),
                  ),
                ],
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
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: VaultColors.savings(
                                    context,
                                  ).withValues(alpha: .1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.savings_outlined,
                                  color: VaultColors.savings(context),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                t.noGoals,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final goal = items[index];
                          final tint = Color(goal.color);
                          final ratio = _goalRatio(goal);
                          return VaultSurface(
                            padding: const EdgeInsets.fromLTRB(16, 12, 8, 16),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: tint.withValues(alpha: .13),
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                      child: Icon(
                                        goal.completed
                                            ? Icons.check_rounded
                                            : Icons.savings_outlined,
                                        size: 21,
                                        color: tint,
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
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${formatMoney(goal.savedAmountMinor, currency, locale)} / '
                                            '${formatMoney(goal.targetAmountMinor, currency, locale)}',
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              color: colors.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${(ratio * 100).round()}%',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: tint,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: t.delete,
                                      icon: const Icon(Icons.delete_outline),
                                      color: colors.onSurfaceVariant,
                                      onPressed: () =>
                                          _deleteGoal(context, ref, goal),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _GoalBar(
                                    ratio: ratio,
                                    color: tint,
                                    height: 8,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: FilledButton.tonalIcon(
                                          style: FilledButton.styleFrom(
                                            minimumSize: const Size(0, 44),
                                            backgroundColor: tint.withValues(
                                              alpha: .12,
                                            ),
                                            foregroundColor: tint,
                                          ),
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
                                            Icons.add_rounded,
                                            size: 19,
                                          ),
                                          label: Text(t.reserveFunds),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          style: OutlinedButton.styleFrom(
                                            minimumSize: const Size(0, 44),
                                            side: BorderSide(
                                              color: colors.outlineVariant,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
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
                                            size: 19,
                                          ),
                                          label: Text(t.releaseFunds),
                                        ),
                                      ),
                                    ],
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
        ),
      ),
    );
  }
}
