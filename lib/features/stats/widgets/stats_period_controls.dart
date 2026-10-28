import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/time_filter_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../transactions/domain/transaction.dart';
import '../domain/stats_analysis.dart';

String statsPeriodLabel(
  TimeFilterState state,
  String locale,
  AppLocalizations t,
) => switch (state.filter) {
  TimeFilter.total => t.total,
  TimeFilter.month => DateFormat.yMMMM(locale).format(state.month),
  TimeFilter.period =>
    state.start == null || state.end == null
        ? t.selectPeriod
        : '${DateFormat.yMMMd(locale).format(state.start!)} – '
              '${DateFormat.yMMMd(locale).format(state.end!)}',
};

Future<DateTime?> showStatsMonthPicker(
  BuildContext context,
  DateTime selected,
  List<TransactionModel> transactions,
) {
  final now = DateTime.now();
  final minYear = transactions.fold<int>(
    math.min(now.year - 20, selected.year),
    (year, tx) => math.min(year, tx.date.year),
  );
  final maxYear = transactions.fold<int>(
    math.max(now.year + 2, selected.year),
    (year, tx) => math.max(year, tx.date.year),
  );
  return showDialog<DateTime>(
    context: context,
    builder: (_) =>
        _MonthDialog(selected: selected, minYear: minYear, maxYear: maxYear),
  );
}

class _MonthDialog extends StatefulWidget {
  final DateTime selected;
  final int minYear;
  final int maxYear;
  const _MonthDialog({
    required this.selected,
    required this.minYear,
    required this.maxYear,
  });
  @override
  State<_MonthDialog> createState() => _MonthDialogState();
}

class _MonthDialogState extends State<_MonthDialog> {
  late int year = widget.selected.year;
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    return AlertDialog(
      title: Text(t.statsMonthTitle),
      content: SizedBox(
        width: 340,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                key: const ValueKey('stats-picker-year'),
                initialValue: year,
                isExpanded: true,
                decoration: InputDecoration(labelText: t.selectYear),
                items: [
                  for (var y = widget.maxYear; y >= widget.minYear; y--)
                    DropdownMenuItem(value: y, child: Text('$y')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => year = value);
                },
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) => Wrap(
                  children: [
                    for (var m = 1; m <= 12; m++)
                      SizedBox(
                        width: constraints.maxWidth / 3,
                        child: TextButton(
                          key: ValueKey('stats-picker-month-$m'),
                          style:
                              m == widget.selected.month &&
                                  year == widget.selected.year
                              ? TextButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                )
                              : null,
                          onPressed: () =>
                              Navigator.pop(context, DateTime(year, m)),
                          child: Text(
                            DateFormat.MMM(locale).format(DateTime(year, m)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.cancel),
        ),
      ],
    );
  }
}

class StatsGlobalPeriodButton extends ConsumerWidget {
  final List<TransactionModel> transactions;
  const StatsGlobalPeriodButton({super.key, required this.transactions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(timeFilterProvider);
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    return OutlinedButton.icon(
      key: const ValueKey('stats-global-period'),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        minimumSize: const Size(0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      onPressed: () async {
        final choice = await showModalBottomSheet<TimeFilter>(
          context: context,
          showDragHandle: true,
          useSafeArea: true,
          builder: (context) => SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final filter in TimeFilter.values)
                    ListTile(
                      key: ValueKey('stats-filter-${filter.name}'),
                      title: Text([t.total, t.month, t.period][filter.index]),
                      leading: Icon(
                        [
                          Icons.all_inclusive,
                          Icons.calendar_month_outlined,
                          Icons.date_range_outlined,
                        ][filter.index],
                      ),
                      trailing: filter == state.filter
                          ? const Icon(Icons.check_rounded)
                          : null,
                      onTap: () => Navigator.pop(context, filter),
                    ),
                ],
              ),
            ),
          ),
        );
        if (choice == null || !context.mounted) return;
        if (choice == TimeFilter.total) {
          ref.read(timeFilterProvider.notifier).setFilter(choice);
        } else if (choice == TimeFilter.month) {
          final month = await showStatsMonthPicker(
            context,
            state.month,
            transactions,
          );
          if (month == null || !context.mounted) return;
          ref.read(timeFilterProvider.notifier).setMonth(month);
          ref.read(timeFilterProvider.notifier).setFilter(choice);
        } else {
          final earliest = transactions.fold(
            DateTime(2000),
            (d, tx) => tx.date.isBefore(d) ? tx.date : d,
          );
          final latest = transactions.fold(
            DateTime(DateTime.now().year + 2),
            (d, tx) => tx.date.isAfter(d) ? tx.date : d,
          );
          final start =
              state.start ?? DateTime(state.month.year, state.month.month);
          final end =
              state.end ?? DateTime(state.month.year, state.month.month + 1, 0);
          final range = await showDateRangePicker(
            context: context,
            firstDate: start.isBefore(earliest) ? start : earliest,
            lastDate: end.isAfter(latest) ? end : latest,
            initialDateRange: DateTimeRange(start: start, end: end),
          );
          if (range == null || !context.mounted) return;
          ref
              .read(timeFilterProvider.notifier)
              .setPeriod(range.start, range.end);
        }
      },
      icon: const Icon(Icons.calendar_month_outlined, size: 17),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              toBeginningOfSentenceCase(statsPeriodLabel(state, locale, t)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
        ],
      ),
    );
  }
}

Future<StatsComparisonSelection?> showStatsComparisonPicker(
  BuildContext context,
  StatsComparisonSelection selection,
  List<TransactionModel> transactions,
) => showModalBottomSheet<StatsComparisonSelection>(
  context: context,
  showDragHandle: true,
  useSafeArea: true,
  isScrollControlled: true,
  builder: (_) =>
      _ComparisonSheet(selection: selection, transactions: transactions),
);

class _ComparisonSheet extends StatefulWidget {
  final StatsComparisonSelection selection;
  final List<TransactionModel> transactions;
  const _ComparisonSheet({required this.selection, required this.transactions});
  @override
  State<_ComparisonSheet> createState() => _ComparisonSheetState();
}

class _ComparisonSheetState extends State<_ComparisonSheet> {
  late StatsComparisonSelection selection = widget.selection;
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    Widget monthButton(String label, DateTime month, bool primary) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        OutlinedButton.icon(
          key: ValueKey(
            primary ? 'stats-comparison-primary' : 'stats-comparison-reference',
          ),
          onPressed: () async {
            final value = await showStatsMonthPicker(
              context,
              month,
              widget.transactions,
            );
            if (value == null || !mounted) return;
            setState(
              () => selection = primary
                  ? selection.copyWith(month: value)
                  : selection.copyWith(referenceMonth: value),
            );
          },
          icon: const Icon(Icons.calendar_month_outlined, size: 18),
          label: Text(DateFormat.yMMMM(locale).format(month)),
        ),
      ],
    );
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .9,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.statsComparisonPeriod,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            monthButton(t.statsPrimaryMonth, selection.month, true),
            const SizedBox(height: 18),
            DropdownButtonFormField<StatsComparisonMode>(
              key: const ValueKey('stats-comparison-mode'),
              initialValue: selection.mode,
              isExpanded: true,
              decoration: InputDecoration(labelText: t.statsCompareWith),
              selectedItemBuilder: (_) =>
                  [t.statsPreviousMonth, t.statsChooseMonth, t.statsYearAverage]
                      .map(
                        (text) => Text(
                          text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                      .toList(),
              items: [
                for (final mode in StatsComparisonMode.values)
                  DropdownMenuItem(
                    value: mode,
                    child: Text(
                      [
                        t.statsPreviousMonth,
                        t.statsChooseMonth,
                        t.statsYearAverage,
                      ][mode.index],
                    ),
                  ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => selection = selection.copyWith(mode: value));
                }
              },
            ),
            if (selection.mode == StatsComparisonMode.month) ...[
              const SizedBox(height: 18),
              monthButton(
                t.statsReferenceMonth,
                selection.referenceMonth,
                false,
              ),
            ],
            if (selection.mode == StatsComparisonMode.yearAverage)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  selection.month.month == 1
                      ? t.statsNoEarlierMonths
                      : t.statsAverageBasis(selection.month.month - 1),
                ),
              ),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              key: const ValueKey('stats-align-days'),
              contentPadding: EdgeInsets.zero,
              title: Text(t.statsElapsedDays),
              subtitle: Text(t.statsElapsedHint),
              value: selection.alignElapsedDays,
              onChanged: (value) => setState(
                () => selection = selection.copyWith(alignElapsedDays: value),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const ValueKey('stats-apply-comparison'),
                onPressed: () => Navigator.pop(context, selection),
                child: Text(t.confirm),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
