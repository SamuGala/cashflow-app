import 'package:pocket_vault/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/category_provider.dart';
import '../domain/category.dart';
import 'add_category_dialog.dart';
import '../../../core/utils/category_localization.dart';

Future<Category?> showCategorySelector(BuildContext context, bool isIncome) {
  return showModalBottomSheet<Category>(
    context: context,
    showDragHandle: true,
    builder: (_) => _CategorySelector(isIncome: isIncome),
  );
}

class _CategorySelector extends ConsumerWidget {
  final bool isIncome;

  const _CategorySelector({required this.isIncome});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryProvider);
    final t = AppLocalizations.of(context)!;

    final categories = (categoriesAsync.value ?? [])
        .where((c) => c.isIncome == isIncome)
        .toList();

    return ListView.builder(
      itemCount: categories.length + 1,
      itemBuilder: (_, index) {
        if (index == categories.length) {
          return ListTile(
            leading: const Icon(Icons.add),
            title: Text(t.newCategory),
            onTap: () async {
              final category = await showAddCategoryDialog(context, isIncome);

              if (context.mounted && category != null) {
                Navigator.pop(context, category);
              }
            },
          );
        }

        final category = categories[index];

        return Dismissible(
          key: ValueKey(category.id),

          /// DEFAULT CATEGORIES NON ELIMINABILI
          direction: category.isDefault
              ? DismissDirection.none
              : DismissDirection.endToStart,

          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),

          confirmDismiss: (_) async {
            final canDelete = await ref
                .read(categoryProvider.notifier)
                .canDeleteCategory(category.id);
            if (!context.mounted) return false;
            if (!canDelete) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Categoria utilizzata: sposta prima movimenti, ricorrenze, '
                    'o budget collegati.',
                  ),
                ),
              );
              return false;
            }

            return await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: Text(t.deleteCategory),
                    content: Text(t.deleteCategoryConfirm),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: Text(t.cancel),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: Text(t.delete),
                      ),
                    ],
                  ),
                ) ??
                false;
          },

          onDismissed: (_) {
            if (!category.isDefault) {
              ref.read(categoryProvider.notifier).deleteCategory(category.id);
            }
          },

          child: ListTile(
            leading: Icon(
              category.isDefault
                  ? categoryIcon(category.name)
                  : customCategoryIcon(category.icon),
              color: Color(category.color),
            ),

            /// MOSTRA TRADUZIONE CATEGORIA
            title: Text(categoryName(category.name, t)),

            /// SELECT CATEGORY
            onTap: () => Navigator.pop(context, category),

            /// EDIT SOLO SE NON DEFAULT
            onLongPress: category.isDefault
                ? null
                : () async {
                    await showAddCategoryDialog(
                      context,
                      isIncome,
                      existing: category,
                    );
                  },
          ),
        );
      },
    );
  }
}
