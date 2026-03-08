import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/transaction_provider.dart';

class ActivityHeatmap extends ConsumerWidget {
  const ActivityHeatmap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(transactionProvider);

    final tx = txAsync.value ?? [];

    final Map<int, int> activity = {};

    for (final t in tx) {
      final day = t.date.day;
      activity[day] = (activity[day] ?? 0) + 1;
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: List.generate(31, (index) {
        final day = index + 1;
        final count = activity[day] ?? 0;

        Color color;

        if (count == 0) {
          color = Colors.grey.shade200;
        } else if (count < 2) {
          color = Colors.green.shade200;
        } else if (count < 4) {
          color = Colors.green.shade400;
        } else {
          color = Colors.green.shade700;
        }

        return Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}