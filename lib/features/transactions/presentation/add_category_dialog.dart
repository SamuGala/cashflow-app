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
];

final colors = [
  Colors.blue,
  Colors.red,
  Colors.green,
  Colors.orange,
  Colors.purple,
  Colors.teal,
  Colors.indigo,
  Colors.pink,
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

    return AlertDialog(
      title: Text(
        widget.existing == null ? t.newCategory : "${t.category} • edit",
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// NAME
            TextField(
              controller: controller,
              decoration: InputDecoration(labelText: t.nameCategory),
            ),

            const SizedBox(height: 20),

            /// ICON PICKER
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

            const SizedBox(height: 8),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: icons.map((i) {
                final selected = icon == i.codePoint;

                return GestureDetector(
                  onTap: () {
                    setState(() => icon = i.codePoint);
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: selected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade200,
                    child: Icon(
                      i,
                      color: selected
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            /// COLOR PICKER
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

            const SizedBox(height: 8),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: colors.map((c) {
                final selected = color == c.value;

                return GestureDetector(
                  onTap: () {
                    setState(() => color = c.value);
                  },
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: c,
                    child: selected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(t.existingCategory)),
              );
              return;
            }

            if (widget.existing == null) {
              /// CREATE
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
              /// UPDATE
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
          child: Text(t.saveTransaction),
        ),
      ],
    );
  }
}
