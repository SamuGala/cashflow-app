import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/time_filter_provider.dart';

class RevolutMonthSelector extends ConsumerStatefulWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime>? onChanged;
  final String? label;
  final bool compact;

  const RevolutMonthSelector({
    super.key,
    this.initialDate,
    this.onChanged,
    this.label,
    this.compact = false,
  });

  @override
  ConsumerState<RevolutMonthSelector> createState() =>
      _RevolutMonthSelectorState();
}

class _RevolutMonthSelectorState extends ConsumerState<RevolutMonthSelector> {
  late PageController controller;

  DateTime selected = DateTime.now();
  int currentYear = DateTime.now().year;
  bool _syncingPage = false;
  int _pageSyncVersion = 0;

  void _scrollToMonth(int month) {
    if (!controller.hasClients) return;
    final version = ++_pageSyncVersion;
    _syncingPage = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      controller.jumpToPage(month - 1);
      _syncingPage = false;
      return;
    }
    controller
        .animateToPage(
          month - 1,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        )
        .whenComplete(() {
          if (mounted && version == _pageSyncVersion) _syncingPage = false;
        });
  }

  @override
  void initState() {
    super.initState();

    final base = widget.initialDate ?? DateTime.now();

    selected = base;
    currentYear = base.year;

    controller = PageController(
      viewportFraction: 0.22,
      initialPage: base.month - 1,
    );
  }

  @override
  void didUpdateWidget(covariant RevolutMonthSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newDate = widget.initialDate;

    if (newDate == null) return;

    /// se cambia il mese da fuori → sincronizza UI
    if (newDate.month != selected.month || newDate.year != selected.year) {
      setState(() {
        selected = newDate;
        currentYear = newDate.year;
      });

      /// aggiorna anche il page controller
      _scrollToMonth(newDate.month);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void updateMonth(int month) {
    final newDate = DateTime(currentYear, month);

    if (selected.month == month && selected.year == currentYear) return;

    setState(() {
      selected = newDate;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final current = ref.read(timeFilterProvider).month;

      if (current.month == newDate.month && current.year == newDate.year) {
        return;
      }

      ref.read(timeFilterProvider.notifier).setMonth(newDate);

      widget.onChanged?.call(newDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();

    if (widget.compact) {
      final colors = Theme.of(context).colorScheme;
      final monthLabel = DateFormat.yMMMM(locale).format(selected);
      void step(int delta) {
        final target = DateTime(selected.year, selected.month + delta);
        setState(() => currentYear = target.year);
        updateMonth(target.month);
      }

      return Row(
        children: [
          IconButton(
            key: const ValueKey('dashboard-previous-month'),
            tooltip: MaterialLocalizations.of(context).previousMonthTooltip,
            onPressed: () => step(-1),
            icon: Icon(
              Icons.chevron_left_rounded,
              size: 20,
              color: colors.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: TextButton(
              onPressed: () async {
                final year = await showDialog<int>(
                  context: context,
                  builder: (dialogContext) => SimpleDialog(
                    title: Text(
                      MaterialLocalizations.of(
                        context,
                      ).selectYearSemanticsLabel,
                    ),
                    children: List.generate(20, (index) {
                      final year = DateTime.now().year - index;
                      return SimpleDialogOption(
                        onPressed: () => Navigator.pop(dialogContext, year),
                        child: Text('$year'),
                      );
                    }),
                  ),
                );
                if (year == null || !mounted) return;
                setState(() => currentYear = year);
                updateMonth(selected.month);
              },
              child: Text(
                '${monthLabel[0].toUpperCase()}${monthLabel.substring(1)}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          IconButton(
            key: const ValueKey('dashboard-next-month'),
            tooltip: MaterialLocalizations.of(context).nextMonthTooltip,
            onPressed: () => step(1),
            icon: Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 6),
        ],

        /// YEAR SELECTOR
        GestureDetector(
          onTap: () async {
            final year = await showDialog<int>(
              context: context,
              builder: (context) {
                return SimpleDialog(
                  title: const Text("Select year"),
                  children: List.generate(20, (i) {
                    final y = DateTime.now().year - i;

                    return SimpleDialogOption(
                      child: Text("$y"),
                      onPressed: () => Navigator.pop(context, y),
                    );
                  }),
                );
              },
            );

            if (year != null && mounted) {
              setState(() {
                currentYear = year;
              });

              updateMonth(selected.month);
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "$currentYear",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.expand_more, size: 18),
            ],
          ),
        ),

        const SizedBox(height: 12),

        /// MONTH SCROLLER
        SizedBox(
          height: 48,
          child: PageView.builder(
            controller: controller,
            itemCount: 12,
            onPageChanged: (index) {
              final month = index + 1;

              if (!_syncingPage && selected.month != month) {
                updateMonth(month);
              }
            },
            itemBuilder: (context, index) {
              final month = index + 1;
              final date = DateTime(currentYear, month);

              final monthName = DateFormat.MMM(locale).format(date);

              final isSelected =
                  selected.month == month && selected.year == currentYear;

              return GestureDetector(
                onTap: () {
                  updateMonth(month);

                  _scrollToMonth(month);
                },
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xff6366F1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xff6366F1)
                            : Colors.grey.shade300,
                        width: 1.2,
                      ),
                    ),
                    child: Text(
                      monthName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
