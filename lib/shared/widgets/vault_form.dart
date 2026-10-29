import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/utils/category_localization.dart';
import '../../features/transactions/domain/category.dart';
import '../../l10n/app_localizations.dart';
import 'vault_style.dart';

/// Income / expense pill switch of the entry forms.
class VaultFlowSwitch extends StatelessWidget {
  const VaultFlowSwitch({
    super.key,
    required this.isIncome,
    required this.onChanged,
  });

  final bool isIncome;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: .7),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          for (final income in [true, false])
            Expanded(
              child: Semantics(
                button: true,
                selected: isIncome == income,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    color: isIncome == income
                        ? colors.surface
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isIncome == income
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .05),
                              blurRadius: 6,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: InkWell(
                    key: ValueKey(
                      'flow-switch-${income ? 'income' : 'expense'}',
                    ),
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      if (isIncome == income) return;
                      HapticFeedback.selectionClick();
                      onChanged(income);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            income
                                ? Icons.south_west_rounded
                                : Icons.north_east_rounded,
                            size: 16,
                            color: isIncome == income
                                ? VaultColors.flow(context, income)
                                : colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              income ? t.income : t.expense,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isIncome == income
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isIncome == income
                                    ? VaultColors.flow(context, income)
                                    : colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Tappable form row: tinted icon, optional caption and value.
class VaultFieldTile extends StatelessWidget {
  const VaultFieldTile({
    super.key,
    required this.icon,
    required this.child,
    this.label,
    this.onTap,
    this.trailing,
    this.iconColor,
    this.padding = const EdgeInsets.fromLTRB(12, 10, 12, 10),
  });

  final IconData icon;
  final Widget child;
  final String? label;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? iconColor;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tint = iconColor ?? colors.primary;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outlineVariant, width: .7),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 18, color: tint),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (label != null)
                      Text(
                        label!,
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    DefaultTextStyle.merge(
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                      child: child,
                    ),
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else if (onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.onSurfaceVariant,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Category choice chip tinted with the category's saved color.
class VaultCategoryChip extends StatelessWidget {
  const VaultCategoryChip({
    super.key,
    required this.category,
    required this.selected,
    required this.onPressed,
  });

  final Category category;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final tint = Color(category.color);
    return ActionChip(
      avatar: Icon(
        category.isDefault
            ? categoryIcon(category.name)
            : customCategoryIcon(category.icon),
        size: 18,
        color: tint,
      ),
      label: Text(categoryName(category.name, t)),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        color: colors.onSurface,
      ),
      backgroundColor: selected ? tint.withValues(alpha: .14) : colors.surface,
      side: BorderSide(
        color: selected ? tint.withValues(alpha: .7) : colors.outlineVariant,
        width: selected ? 1.2 : .7,
      ),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      onPressed: onPressed,
    );
  }
}

/// Neutral chip used for "other categories".
class VaultMoreChip extends StatelessWidget {
  const VaultMoreChip({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ActionChip(
      avatar: Icon(Icons.grid_view_rounded, size: 17, color: colors.primary),
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: colors.primary,
      ),
      backgroundColor: colors.primary.withValues(alpha: .06),
      side: BorderSide(color: colors.primary.withValues(alpha: .2), width: .7),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      onPressed: onPressed,
    );
  }
}

/// Full-width bottom-sheet list of categories with colored avatars.
class VaultCategoryList extends StatelessWidget {
  const VaultCategoryList({
    super.key,
    required this.categories,
    required this.onSelected,
    this.selectedId,
    this.footer,
    this.title,
  });

  final List<Category> categories;
  final ValueChanged<Category> onSelected;
  final String? selectedId;
  final Widget? footer;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
            child: Text(
              title ?? t.category,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -.3,
              ),
            ),
          ),
          VaultSurface(
            padding: EdgeInsets.zero,
            radius: 18,
            child: Column(
              children: [
                for (final (index, c) in categories.indexed)
                  InkWell(
                    onTap: () => onSelected(c),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: index == 0
                            ? null
                            : Border(
                                top: BorderSide(
                                  color: colors.outlineVariant,
                                  width: .5,
                                ),
                              ),
                      ),
                      child: Row(
                        children: [
                          CategoryAvatar(category: c, size: 36),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              categoryName(c.name, t),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: selectedId == c.id
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (selectedId == c.id)
                            Icon(
                              Icons.check_circle_rounded,
                              color: colors.primary,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (footer != null) ...[const SizedBox(height: 10), footer!],
        ],
      ),
    );
  }
}

/// Compact outlined dropdown used inside option cards.
class VaultPillDropdown<T> extends StatelessWidget {
  const VaultPillDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final Map<T, String> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.outlineVariant, width: .7),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isDense: true,
          borderRadius: BorderRadius.circular(14),
          icon: const Icon(Icons.expand_more_rounded, size: 18),
          padding: const EdgeInsets.symmetric(vertical: 6),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
          items: [
            for (final entry in items.entries)
              DropdownMenuItem(value: entry.key, child: Text(entry.value)),
          ],
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ),
    );
  }
}

/// Label / value row inside option cards.
class VaultOptionRow extends StatelessWidget {
  const VaultOptionRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: colors.onSurfaceVariant),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            if (trailing != null)
              trailing!
            else
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: colors.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}
