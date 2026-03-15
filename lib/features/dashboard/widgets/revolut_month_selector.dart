import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/selected_month_provider.dart';

class RevolutMonthSelector extends ConsumerStatefulWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime>? onChanged;
  final String? label;

  const RevolutMonthSelector({
    super.key,
    this.initialDate,
    this.onChanged,
    this.label,
  });

  @override
  ConsumerState<RevolutMonthSelector> createState() =>
      _RevolutMonthSelectorState();
}

class _RevolutMonthSelectorState extends ConsumerState<RevolutMonthSelector> {
  late PageController controller;

  DateTime selected = DateTime.now();
  int currentYear = DateTime.now().year;

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

  void updateMonth(int month) {
    final newDate = DateTime(currentYear, month);

    /// evita update inutili
    if (selected.month == month && selected.year == currentYear) return;

    setState(() {
      selected = newDate;
    });

    /// aggiorna provider dopo il frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (widget.onChanged != null) {
        widget.onChanged!(newDate);
        return;
      }

      final current = ref.read(selectedMonthProvider);

      if (current.month == newDate.month && current.year == newDate.year) {
        return;
      }

      ref.read(selectedMonthProvider.notifier).setMonth(newDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();

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

            if (year != null) {
              setState(() {
                currentYear = year;
                selected = DateTime(year, selected.month);
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

              if (selected.month != month) {
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

                  controller.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                  );
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
