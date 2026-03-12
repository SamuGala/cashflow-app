import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/category_provider.dart';
import '../domain/category.dart';
import 'widgets/category_tile.dart';
import 'add_category_dialog.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/category_localization.dart';

Future<Category?> showCategorySelector(BuildContext context, bool isIncome) {
  return showModalBottomSheet<Category>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      final t = AppLocalizations.of(context)!;

      return Consumer(
        builder: (context, ref, _) {
          final categoriesAsync = ref.watch(categoryProvider);

          final categories = (categoriesAsync.value ?? [])
              .whereType<Category>()
              .where((c) => c.isIncome == isIncome)
              .toList();

          return ListView.builder(
            itemCount: categories.length + 1,
            itemBuilder: (_, index) {
              /// ADD CATEGORY
              if (index == categories.length) {
                return ListTile(
                  leading: const Icon(Icons.add),
                  title: Text(t.newCategory),
                  onTap: () async {
                    final category = await showAddCategoryDialog(
                      sheetContext,
                      isIncome,
                    );

                    if (category != null && sheetContext.mounted) {
                      Navigator.pop(sheetContext, category);
                    }
                  },
                );
              }

              final category = categories[index];

              return Dismissible(
                key: ValueKey(category.id),
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
                  ref
                      .read(categoryProvider.notifier)
                      .deleteCategory(category.id);
                },
                child: CategoryTile(
                  category: category,
                  onTap: () {
                    Navigator.pop(sheetContext, category);
                  },
                ),
              );
            },
          );
        },
      );
    },
  );
}
