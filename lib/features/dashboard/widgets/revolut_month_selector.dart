import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/selected_month_provider.dart';

class RevolutMonthSelector extends ConsumerStatefulWidget {
  const RevolutMonthSelector({super.key});

  @override
  ConsumerState<RevolutMonthSelector> createState() =>
      _RevolutMonthSelectorState();
}

class _RevolutMonthSelectorState
    extends ConsumerState<RevolutMonthSelector> {

  late PageController controller;

  int currentYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    currentYear = now.year;

    controller = PageController(
      viewportFraction: 0.22,
      initialPage: now.month - 1,
    );
  }

  @override
  Widget build(BuildContext context) {

    final selected = ref.watch(selectedMonthProvider);

    return Column(
      children: [

        /// YEAR SELECTOR
        GestureDetector(
          onTap: () async {

            final year = await showDialog<int>(
              context: context,
              builder: (context) {

                return SimpleDialog(
                  title: const Text("Seleziona anno"),
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

              currentYear = year;

              ref.read(selectedMonthProvider.notifier).setMonth(
                    DateTime(year, selected.month),
                  );
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

              ref.read(selectedMonthProvider.notifier).setMonth(
                    DateTime(currentYear, month),
                  );
            },

            itemBuilder: (context, index) {

              final month = index + 1;

              final date = DateTime(currentYear, month);

              final selectedMonth =
                  selected.month == month &&
                  selected.year == currentYear;

              return Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),

                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),

                  decoration: BoxDecoration(

                    color: selectedMonth
                        ? const Color(0xff6366F1)
                        : Colors.transparent,

                    borderRadius: BorderRadius.circular(12),

                    border: Border.all(
                      color: selectedMonth
                          ? const Color(0xff6366F1)
                          : Colors.grey.shade300,
                      width: 1.2,
                    ),
                  ),

                  child: Text(
                    DateFormat('MMM').format(date),

                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: selectedMonth
                          ? Colors.white
                          : Colors.black87,
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