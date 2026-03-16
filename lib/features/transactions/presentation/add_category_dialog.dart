import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../providers/category_provider.dart';
import '../domain/category.dart';

final icons = [
  Icons.shopping_cart,
  Icons.home,
  Icons.fastfood,
  Icons.directions_car,
  Icons.movie,
  Icons.sports_esports,
  Icons.restaurant,
  Icons.flight,
  Icons.school,
  Icons.favorite,
  Icons.attach_money,
  Icons.local_hospital,
  Icons.pets,
  Icons.card_giftcard,
  Icons.work,
];

final colors = [
  const Color(0xFF5B8DEF), // blue
  const Color(0xFFFF6B6B), // red
  const Color(0xFF2ECC71), // green
  const Color(0xFFFF9F43), // orange
  const Color(0xFF9B59B6), // purple
  const Color(0xFF1ABC9C), // teal
  const Color(0xFF4B7BEC), // indigo
  const Color(0xFFFF6FAF), // pink
  const Color(0xFFF1C40F), // yellow
  const Color(0xFF16A085), // emerald
  const Color(0xFFD35400), // burnt orange
  const Color(0xFF34495E), // slate
  Colors.amber,
  Colors.cyan,
  Colors.deepOrange,
];

Future<Category?> showAddCategoryDialog(
  BuildContext context,
  bool isIncome, {
  Category? existing,
}) {
  return showDialog<Category>(
    context: context,
    builder: (_) => _AddCategoryDialog(isIncome: isIncome, existing: existing),
  );
}

class _AddCategoryDialog extends ConsumerStatefulWidget {
  final bool isIncome;
  final Category? existing;

  const _AddCategoryDialog({required this.isIncome, this.existing});

  @override
  ConsumerState<_AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends ConsumerState<_AddCategoryDialog> {
  final controller = TextEditingController();

  int icon = Icons.shopping_cart.codePoint;
  int color = Colors.blue.value;

  @override
  void initState() {
    super.initState();

    if (widget.existing != null) {
      controller.text = widget.existing!.name;
      icon = widget.existing!.icon;
      color = widget.existing!.color;
    }
  }

  Future<bool> _categoryExists(String name) async {
    final categories = ref.read(categoryProvider).value ?? [];

    return categories.any(
      (c) =>
          c.name.toLowerCase() == name.toLowerCase() &&
          c.id != widget.existing?.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: Text(
        widget.existing == null ? t.newCategory : "${t.category} • edit",
      ),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// CATEGORY PREVIEW
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Color(color).withOpacity(.18),
                    child: Icon(
                      IconData(icon, fontFamily: 'MaterialIcons'),
                      color: Color(color),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Text(
                      controller.text.isEmpty ? t.category : controller.text,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            /// NAME
            TextField(
              controller: controller,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(labelText: t.nameCategory),
            ),

            const SizedBox(height: 24),

            /// ICON TITLE
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Icona",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// ICON GRID
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: icons.map((i) {
                final selected = icon == i.codePoint;

                return GestureDetector(
                  onTap: () {
                    setState(() => icon = i.codePoint);
                  },

                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),

                    width: 44,
                    height: 44,

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,

                      color: selected
                          ? Color(color)
                          : isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                    ),

                    child: Icon(
                      i,
                      size: 22,
                      color: selected
                          ? Colors.white
                          : isDark
                          ? Colors.grey.shade300
                          : Colors.grey.shade700,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            /// COLOR TITLE
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Colore",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// COLOR GRID
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: colors.map((c) {
                final selected = color == c.value;

                return GestureDetector(
                  onTap: () {
                    setState(() => color = c.value);
                  },

                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),

                    width: 36,
                    height: 36,

                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,

                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: c.withOpacity(.6),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),

                    child: selected
                        ? const Icon(Icons.check, size: 18, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),

      actions: [
        /// CANCEL
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.cancel),
        ),

        /// SAVE
        FilledButton(
          onPressed: () async {
            final name = controller.text.trim();

            if (name.isEmpty) return;

            if (await _categoryExists(name)) {
              final messenger = ScaffoldMessenger.of(context);

              messenger
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(t.existingCategory),
                    duration: const Duration(seconds: 4),
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                );

              return;
            }

            if (widget.existing == null) {
              final created = await ref
                  .read(categoryProvider.notifier)
                  .addCategory(
                    name: name,
                    isIncome: widget.isIncome,
                    icon: icon,
                    color: color,
                  );

              if (mounted) {
                Navigator.pop(context, created);
              }
            } else {
              final updated = widget.existing!.copyWith(
                name: name,
                icon: icon,
                color: color,
              );

              await ref.read(categoryProvider.notifier).updateCategory(updated);

              if (mounted) {
                Navigator.pop(context, updated);
              }
            }
          },
          child: Text(t.saveCategory),
        ),
      ],
    );
  }
}
