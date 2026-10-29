import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/currency/currency_metadata.dart';
import '../../../core/utils/category_localization.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/vault_style.dart';
import '../domain/category.dart';
import '../domain/movement_filters.dart';
import '../domain/transaction.dart';

/// Opens the filter panel of the Movements history. [pool] is the history
/// already narrowed by period and search, used for the live count.
Future<MovementFilters?> showMovementFiltersSheet(
  BuildContext context, {
  required MovementFilters initial,
  required List<TransactionModel> pool,
  required List<Category> categories,
  required String baseCurrency,
}) {
  return showModalBottomSheet<MovementFilters>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) => MovementFiltersSheet(
      initial: initial,
      pool: pool,
      categories: categories,
      baseCurrency: baseCurrency,
    ),
  );
}

class MovementFiltersSheet extends StatefulWidget {
  const MovementFiltersSheet({
    super.key,
    required this.initial,
    required this.pool,
    required this.categories,
    required this.baseCurrency,
  });

  final MovementFilters initial;
  final List<TransactionModel> pool;
  final List<Category> categories;
  final String baseCurrency;

  @override
  State<MovementFiltersSheet> createState() => _MovementFiltersSheetState();
}

class _MovementFiltersSheetState extends State<MovementFiltersSheet> {
  late MovementFilters _filters = widget.initial;

  /// Slider ceiling: the largest amount in the pool, rounded up to a whole
  /// step so the handles land on friendly values.
  late final int _ceiling = () {
    final largest = widget.pool.fold<int>(
      0,
      (max, tx) => math.max(max, tx.amountCents),
    );
    final step = _step(largest);
    return math.max(step, ((largest + step - 1) ~/ step) * step);
  }();

  static int _step(int amount) {
    if (amount <= 10000) return 500;
    if (amount <= 100000) return 1000;
    if (amount <= 1000000) return 5000;
    return 50000;
  }

  late final Set<String> _currencies = {
    for (final tx in widget.pool) tx.originalCurrency,
  };

  void _update(MovementFilters next) {
    HapticFeedback.selectionClick();
    setState(() => _filters = next);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final matching = widget.pool.where(_filters.matches).length;
    final visibleCategories = widget.categories.where(
      (c) => switch (_filters.flow) {
        FlowFilter.all => true,
        FlowFilter.expense => !c.isIncome,
        FlowFilter.income => c.isIncome,
      },
    );
    final step = _step(_ceiling);
    final low = (_filters.minAmount ?? 0).clamp(0, _ceiling);
    final high = (_filters.maxAmount ?? _ceiling).clamp(low, _ceiling);
    String money(int minor) => formatMoney(minor, widget.baseCurrency, locale);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 12, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  t.filters,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.6,
                  ),
                ),
              ),
              TextButton(
                key: const ValueKey('filter-reset'),
                onPressed: _filters.isEmpty
                    ? null
                    : () => _update(MovementFilters.none),
                child: Text(t.filterReset),
              ),
            ],
          ),
        ),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              VaultSectionLabel(t.filterType),
              _Segmented<FlowFilter>(
                keyPrefix: 'filter-flow',
                value: _filters.flow,
                options: {
                  FlowFilter.all: t.filterAll,
                  FlowFilter.expense: t.expenses,
                  FlowFilter.income: t.incomes,
                },
                onChanged: (flow) {
                  // Categories of the other flow would match nothing.
                  final kept = {
                    for (final id in _filters.categoryIds)
                      if (widget.categories.any(
                        (c) =>
                            c.id == id &&
                            (flow == FlowFilter.all ||
                                c.isIncome == (flow == FlowFilter.income)),
                      ))
                        id,
                  };
                  _update(_filters.copyWith(flow: flow, categoryIds: kept));
                },
              ),
              const SizedBox(height: 24),
              VaultSectionLabel(t.filterCategories),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final category in visibleCategories)
                    _CategoryFilterChip(
                      key: ValueKey('filter-category-${category.id}'),
                      category: category,
                      label: categoryName(category.name, t),
                      selected: _filters.categoryIds.contains(category.id),
                      onTap: () {
                        final ids = {..._filters.categoryIds};
                        if (!ids.remove(category.id)) ids.add(category.id);
                        _update(_filters.copyWith(categoryIds: ids));
                      },
                    ),
                ],
              ),
              const SizedBox(height: 24),
              VaultSectionLabel(
                t.amount,
                trailing: Text(
                  '${money(low)} – ${money(high)}',
                  key: const ValueKey('filter-amount-label'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _filters.hasAmount
                        ? colors.primary
                        : colors.onSurfaceVariant,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              RangeSlider(
                key: const ValueKey('filter-amount'),
                min: 0,
                max: _ceiling.toDouble(),
                divisions: math.max(1, _ceiling ~/ step),
                values: RangeValues(low.toDouble(), high.toDouble()),
                onChanged: (range) {
                  final min = range.start.round();
                  final max = range.end.round();
                  setState(
                    () => _filters = _filters.copyWith(
                      minAmount: () => min <= 0 ? null : min,
                      maxAmount: () => max >= _ceiling ? null : max,
                    ),
                  );
                },
                onChangeEnd: (_) => HapticFeedback.selectionClick(),
              ),
              if (_currencies.length > 1) ...[
                const SizedBox(height: 16),
                VaultSectionLabel(t.filterCurrency),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final code in _currencies.toList()..sort())
                      _TextFilterChip(
                        key: ValueKey('filter-currency-$code'),
                        label: code,
                        selected: _filters.currencies.contains(code),
                        onTap: () {
                          final codes = {..._filters.currencies};
                          if (!codes.remove(code)) codes.add(code);
                          _update(_filters.copyWith(currencies: codes));
                        },
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              VaultSectionLabel(t.filterReceipt),
              _Segmented<ReceiptFilter>(
                keyPrefix: 'filter-receipt',
                value: _filters.receipt,
                options: {
                  ReceiptFilter.any: t.filterAll,
                  ReceiptFilter.withReceipt: t.filterWithReceipt,
                  ReceiptFilter.withoutReceipt: t.filterWithoutReceipt,
                },
                onChanged: (receipt) =>
                    _update(_filters.copyWith(receipt: receipt)),
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          minimum: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: FilledButton(
              key: const ValueKey('filter-apply'),
              style: FilledButton.styleFrom(minimumSize: const Size(0, 52)),
              onPressed: () => Navigator.pop(context, _filters),
              child: AnimatedSwitcher(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 180),
                child: Text(
                  t.filterShowMovements(matching),
                  key: ValueKey(matching),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Segmented<T> extends StatelessWidget {
  const _Segmented({
    required this.keyPrefix,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String keyPrefix;
  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SegmentedButton<T>(
      expandedInsets: EdgeInsets.zero,
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(
        minimumSize: const Size(0, 40),
        side: BorderSide(color: colors.outlineVariant, width: .7),
        selectedBackgroundColor: colors.primary.withValues(alpha: .12),
        selectedForegroundColor: colors.primary,
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      segments: [
        for (final (index, entry) in options.entries.indexed)
          ButtonSegment(
            value: entry.key,
            label: Text(
              entry.value,
              key: ValueKey('$keyPrefix-$index'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      selected: {value},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}

class _CategoryFilterChip extends StatelessWidget {
  const _CategoryFilterChip({
    super.key,
    required this.category,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final Category category;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tint = Color(category.color);
    return _ChipFrame(
      selected: selected,
      tint: tint,
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CategoryAvatar(category: category, size: 28),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? tint : colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextFilterChip extends StatelessWidget {
  const _TextFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return _ChipFrame(
      selected: selected,
      tint: colors.primary,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: selected ? colors.primary : colors.onSurface,
        ),
      ),
    );
  }
}

class _ChipFrame extends StatelessWidget {
  const _ChipFrame({
    required this.selected,
    required this.tint,
    required this.onTap,
    required this.padding,
    required this.child,
  });

  final bool selected;
  final Color tint;
  final VoidCallback onTap;
  final EdgeInsets padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      child: AnimatedContainer(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected
              ? Color.alphaBlend(tint.withValues(alpha: .1), colors.surface)
              : colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? tint.withValues(alpha: .55)
                : colors.outlineVariant,
            width: selected ? 1.2 : .7,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
