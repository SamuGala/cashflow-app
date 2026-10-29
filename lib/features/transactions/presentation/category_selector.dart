import 'package:pocket_vault/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/category_provider.dart';
import '../domain/category.dart';
import 'add_category_dialog.dart';
import '../../../core/utils/category_localization.dart';
import '../../../shared/widgets/vault_dialogs.dart';
import '../../../shared/widgets/vault_form.dart';
import '../../../shared/widgets/vault_style.dart';

Future<Category?> showCategorySelector(
  BuildContext context,
  bool isIncome, {
  String? selectedId,
}) {
  return showModalBottomSheet<Category>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * .8,
    ),
    builder: (_) =>
        _CategorySelector(isIncome: isIncome, selectedId: selectedId),
  );
}

class _CategorySelector extends ConsumerWidget {
  final bool isIncome;
  final String? selectedId;

  const _CategorySelector({required this.isIncome, this.selectedId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryProvider);
    final t = AppLocalizations.of(context)!;

    final categories = (categoriesAsync.value ?? [])
        .where((c) => c.isIncome == isIncome)
        .toList();

    final colors = Theme.of(context).colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: categories.length + 2,
      itemBuilder: (_, position) {
        if (position == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
            child: Text(
              t.category,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -.3,
              ),
            ),
          );
        }
        final index = position - 1;
        if (index == categories.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 10),
            child: VaultFieldTile(
              icon: Icons.add_rounded,
              onTap: () async {
                final category = await showAddCategoryDialog(context, isIncome);

                if (context.mounted && category != null) {
                  Navigator.pop(context, category);
                }
              },
              child: Text(t.newCategory),
            ),
          );
        }

        final category = categories[index];
        final first = index == 0;
        final last = index == categories.length - 1;
        final radius = BorderRadius.vertical(
          top: first ? const Radius.circular(18) : Radius.zero,
          bottom: last ? const Radius.circular(18) : Radius.zero,
        );

        return Dismissible(
          key: ValueKey(category.id),

          /// DEFAULT CATEGORIES NON ELIMINABILI
          direction: category.isDefault
              ? DismissDirection.none
              : DismissDirection.endToStart,

          background: Container(
            decoration: BoxDecoration(
              color: VaultColors.expense(context),
              borderRadius: radius,
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
            ),
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

            return await showVaultDeleteDialog(
                  context,
                  title: t.deleteCategory,
                  message: t.deleteCategoryConfirm,
                ) ??
                false;
          },

          onDismissed: (_) {
            if (!category.isDefault) {
              ref.read(categoryProvider.notifier).deleteCategory(category.id);
            }
          },

          child: Material(
            color: colors.surface,
            borderRadius: radius,
            child: ListTile(
              shape: RoundedRectangleBorder(borderRadius: radius),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14),
              leading: CategoryAvatar(category: category, size: 36),
              trailing: selectedId == category.id
                  ? Icon(Icons.check_circle_rounded, color: colors.primary)
                  : null,

              /// MOSTRA TRADUZIONE CATEGORIA
              title: Text(
                categoryName(category.name, t),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),

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
          ),
        );
      },
    );
  }
}
