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

class RecurringList extends ConsumerWidget {
  const RecurringList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final recurringAsync = ref.watch(recurringProvider);
    final categoriesAsync = ref.watch(categoryProvider);

    final categories = categoriesAsync.value ?? [];

    return recurringAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (items) {
        if (items.isEmpty) {
          return Center(child: Text(t.noRecurrent));
        }

        return ListView(
          children: items.map((r) {
            final category = categories.isNotEmpty
                ? categories.firstWhere(
                    (c) => c.id == r.categoryId,
                    orElse: () => categories.first,
                  )
                : Category(
                    id: "unknown",
                    name: "food",
                    isIncome: false,
                    icon: 0,
                    color: Colors.grey.value,
                    isDefault: false,
                  );

            return Dismissible(
              key: ValueKey(r.id),
              direction: DismissDirection.endToStart,
              background: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.centerRight,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) {
                ref.read(recurringProvider.notifier).deleteRecurring(r.id);
              },
              child: _RecurringTile(recurring: r, category: category),
            );
          }).toList(),
        );
      },
    );
  }
}

class _RecurringTile extends StatefulWidget {
  final RecurringTransaction recurring;
  final Category category;

  const _RecurringTile({required this.recurring, required this.category});

  @override
  State<_RecurringTile> createState() => _RecurringTileState();
}

class _RecurringTileState extends State<_RecurringTile> {
  double scale = 1;

  void _press() => setState(() => scale = 0.95);
  void _release() => setState(() => scale = 1);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return GestureDetector(
      onTapDown: (_) => _press(),
      onTapCancel: _release,
      onTapUp: (_) => _release(),
      onLongPress: () {
        HapticFeedback.mediumImpact();

        showModalBottomSheet(
          context: context,
          showDragHandle: true,
          builder: (_) => _RecurringActions(recurring: widget.recurring),
        );
      },
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Row(
            children: [
              /// ICON + RECURRING BADGE
              Container(
                height: 42,
                width: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color(widget.category.color).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Center(
                      child: Icon(
                        categoryIcon(widget.category.name),
                        color: Color(widget.category.color),
                      ),
                    ),
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.autorenew,
                          size: 10,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              /// CATEGORY NAME
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryName(widget.category.name, t),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "€ ${(widget.recurring.amountCents / 100).toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              /// DAY + STATUS
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${t.everyMonth} ${widget.recurring.dayOfMonth}",
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.recurring.active ? t.active : t.pause,
                    style: TextStyle(
                      fontSize: 13,
                      color: widget.recurring.active
                          ? Colors.green
                          : Colors.orange,
                      fontWeight: FontWeight.w600,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// EDIT
          ListTile(
            leading: const Icon(Icons.edit),
            title: Text(t.modify),
            onTap: () {
              Navigator.pop(context);

              WidgetsBinding.instance.addPostFrameCallback((_) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  showDragHandle: true,
                  builder: (_) => EditRecurringSheet(recurring: recurring),
                );
              });
            },
          ),

          /// TOGGLE ACTIVE
          ListTile(
            leading: Icon(
              recurring.active ? Icons.pause_circle : Icons.play_circle,
            ),
            title: Text(recurring.active ? t.pause : t.reactivate),
            onTap: () async {
              final newState = !recurring.active;

              await ref
                  .read(recurringProvider.notifier)
                  .toggleActive(recurring.id, newState);

              Navigator.pop(context);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      newState
                          ? t.reactivateMsg
                          : t.reactivatePauseMsg,
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
