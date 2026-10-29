import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/recurring_provider.dart';
import '../providers/category_provider.dart';
import '../domain/category.dart';

import '../../../core/utils/category_localization.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/database/app_database.dart';
import 'edit_recurring_sheet.dart';
import '../domain/recurrence_calculator.dart';
import 'package:intl/intl.dart';
import '../../../core/currency/currency_metadata.dart';
import '../../../core/currency/currency_provider.dart';
import '../../../shared/widgets/inline_load_error.dart';
import '../../../shared/widgets/vault_dialogs.dart';
import '../../../shared/widgets/vault_style.dart';

class RecurringList extends ConsumerWidget {
  const RecurringList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final recurringAsync = ref.watch(recurringProvider);
    final categoriesAsync = ref.watch(categoryProvider);
    final baseCurrency =
        ref.watch(currencyProvider).value?.baseCurrency ?? 'EUR';
    final locale = Localizations.localeOf(context).toString();
    final colors = Theme.of(context).colorScheme;

    final categories = categoriesAsync.value ?? [];

    return recurringAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: InlineLoadError(
            onRetry: () => ref.invalidate(recurringProvider),
          ),
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: .08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.autorenew_rounded,
                      color: colors.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    t.noRecurrent,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            VaultSurface(
              padding: EdgeInsets.zero,
              radius: 18,
              child: Column(
                children: [
                  for (final (index, r) in items.indexed)
                    Dismissible(
                      key: ValueKey(r.id),
                      direction: DismissDirection.horizontal,
                      background: _RecurringSwipeBackground(
                        color: colors.primary,
                        icon: Icons.tune_rounded,
                        label: t.modify,
                        start: true,
                      ),
                      secondaryBackground: _RecurringSwipeBackground(
                        color: VaultColors.expense(context),
                        icon: Icons.delete_outline_rounded,
                        label: t.delete,
                        start: false,
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          HapticFeedback.mediumImpact();

                          showModalBottomSheet(
                            context: context,
                            showDragHandle: true,
                            builder: (_) => _RecurringActions(recurring: r),
                          );

                          return false;
                        }

                        if (direction == DismissDirection.endToStart) {
                          return showVaultDeleteDialog(
                            context,
                            title: t.deleteMovement,
                            message: t.deleteMovementSure,
                          );
                        }

                        return false;
                      },
                      onDismissed: (_) async {
                        await ref
                            .read(recurringProvider.notifier)
                            .deleteRecurring(r.id);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text(t.recurrenceDeleted),
                              action: SnackBarAction(
                                label: t.undo,
                                onPressed: () => unawaited(
                                  ref
                                      .read(recurringProvider.notifier)
                                      .restoreRecurring(r),
                                ),
                              ),
                            ),
                          );
                      },
                      child: _RecurringTile(
                        recurring: r,
                        showDivider: index > 0,
                        category: categories.isNotEmpty
                            ? categories.firstWhere(
                                (c) => c.id == r.categoryId,
                                orElse: () => categories.first,
                              )
                            : null,
                        formattedAmount: formatMoney(
                          r.amountCents,
                          baseCurrency,
                          locale,
                        ),
                        onTap: () => showModalBottomSheet(
                          context: context,
                          showDragHandle: true,
                          builder: (_) => _RecurringActions(recurring: r),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 18),
              child: Text(
                t.swipeHint,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: colors.onSurfaceVariant.withValues(alpha: .8),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RecurringSwipeBackground extends StatelessWidget {
  const _RecurringSwipeBackground({
    required this.color,
    required this.icon,
    required this.label,
    required this.start,
  });

  final Color color;
  final IconData icon;
  final String label;
  final bool start;

  @override
  Widget build(BuildContext context) {
    // Icon only: the label would duplicate the confirmation buttons.
    final content = [
      Semantics(
        label: label,
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    ];
    return Container(
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: start ? Alignment.centerLeft : Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: start ? content : content.reversed.toList(),
      ),
    );
  }
}

class _RecurringTile extends StatelessWidget {
  final RecurringTransaction recurring;
  final Category? category;
  final String formattedAmount;
  final bool showDivider;
  final VoidCallback onTap;

  const _RecurringTile({
    required this.recurring,
    required this.category,
    required this.formattedAmount,
    required this.showDivider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final statusColor = recurring.active
        ? VaultColors.income(context)
        : const Color(0xFFD9822B);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            border: showDivider
                ? Border(
                    top: BorderSide(color: colors.outlineVariant, width: .5),
                  )
                : null,
          ),
          child: Row(
            children: [
              Opacity(
                opacity: recurring.active ? 1 : .55,
                child: CategoryAvatar(
                  category: category,
                  size: 42,
                  badge: Icons.autorenew_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category == null
                          ? t.otherCategory
                          : categoryName(category!.name, t),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      recurrenceSummary(
                        recurring,
                        t,
                        Localizations.localeOf(context).toString(),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${recurring.isIncome ? '+' : '-'} $formattedAmount',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: VaultColors.flow(context, recurring.isIncome),
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      recurring.active ? t.active : t.paused,
                      style: TextStyle(
                        fontSize: 11,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecurringActions extends ConsumerWidget {
  final RecurringTransaction recurring;

  const _RecurringActions({required this.recurring});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
              child: Text(
                recurrenceSummary(
                  recurring,
                  t,
                  Localizations.localeOf(context).toString(),
                ),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -.3,
                ),
              ),
            ),

            /// EDIT
            VaultActionTile(
              icon: Icons.edit_outlined,
              label: t.modify,
              onTap: () {
                Navigator.pop(context);

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    showDragHandle: true,
                    useSafeArea: true,
                    builder: (_) => EditRecurringSheet(recurring: recurring),
                  );
                });
              },
            ),
            const SizedBox(height: 8),

            /// TOGGLE ACTIVE
            VaultActionTile(
              icon: recurring.active
                  ? Icons.pause_circle_outline_rounded
                  : Icons.play_circle_outline_rounded,
              label: recurring.active ? t.pause : t.reactivate,
              color: recurring.active ? const Color(0xFFD9822B) : null,
              onTap: () async {
                final newState = !recurring.active;

                await ref
                    .read(recurringProvider.notifier)
                    .toggleActive(recurring.id, newState);

                if (!context.mounted) return;
                final messenger = ScaffoldMessenger.of(context);

                Navigator.pop(context);

                messenger
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        newState ? t.reactivateMsg : t.reactivatePauseMsg,
                      ),
                      duration: const Duration(seconds: 4),
                    ),
                  );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Localized plural unit for a recurrence frequency, e.g. "Mesi".
String recurrenceFrequencyLabel(RecurrenceFrequency frequency, Locale locale) {
  return switch ((frequency, locale.languageCode)) {
    (RecurrenceFrequency.daily, 'it') => 'Giorni',
    (RecurrenceFrequency.weekly, 'it') => 'Settimane',
    (RecurrenceFrequency.monthly, 'it') => 'Mesi',
    (RecurrenceFrequency.yearly, 'it') => 'Anni',
    (RecurrenceFrequency.daily, 'es') => 'Días',
    (RecurrenceFrequency.weekly, 'es') => 'Semanas',
    (RecurrenceFrequency.monthly, 'es') => 'Meses',
    (RecurrenceFrequency.yearly, 'es') => 'Años',
    (RecurrenceFrequency.daily, _) => 'Days',
    (RecurrenceFrequency.weekly, _) => 'Weeks',
    (RecurrenceFrequency.monthly, _) => 'Months',
    (RecurrenceFrequency.yearly, _) => 'Years',
  };
}

/// Human-readable schedule, e.g. "Ogni settimana · lunedì".
String recurrenceSummary(
  RecurringTransaction recurring,
  AppLocalizations t,
  String locale,
) {
  final interval = recurring.interval;
  final start = recurring.startDate;
  return switch (recurrenceFrequencyFromName(recurring.frequency)) {
    RecurrenceFrequency.daily => t.recurrenceEveryDays(interval),
    RecurrenceFrequency.weekly =>
      '${t.recurrenceEveryWeeks(interval)} · '
          '${DateFormat.EEEE(locale).format(DateTime(2024, 1, recurring.dayOfWeek ?? start.weekday))}',
    RecurrenceFrequency.monthly =>
      '${t.recurrenceEveryMonths(interval)} · ${recurring.dayOfMonth}',
    RecurrenceFrequency.yearly =>
      '${t.recurrenceEveryYears(interval)} · '
          '${DateFormat.MMMd(locale).format(DateTime(2024, recurring.monthOfYear ?? start.month, recurring.dayOfMonth))}',
  };
}
