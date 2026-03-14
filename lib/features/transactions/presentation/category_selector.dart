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

          onDismissed: (_) {
            if (!category.isDefault) {
              ref.read(categoryProvider.notifier).deleteCategory(category.id);
            }
          },

          child: ListTile(
            leading: Icon(
              IconData(category.icon, fontFamily: 'MaterialIcons'),
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
                    final edited = await showAddCategoryDialog(
                      context,
                      isIncome,
                      existing: category,
                    );

                    if (edited != null) {
                      await ref
                          .read(categoryProvider.notifier)
                          .addCategory(
                            name: edited.name,
                            isIncome: edited.isIncome,
                            icon: edited.icon,
                            color: edited.color,
                          );
                    }
                  },
          ),
        );
      },
    );
  }
}