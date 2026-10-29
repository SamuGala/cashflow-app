import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'vault_style.dart';

/// Destructive confirmation shared by movements, recurrences and categories.
Future<bool?> showVaultDeleteDialog(
  BuildContext context, {
  required String title,
  required String message,
}) {
  final t = AppLocalizations.of(context)!;
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final colors = Theme.of(dialogContext).colorScheme;
      final danger = VaultColors.expense(dialogContext);
      return AlertDialog(
        icon: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: danger.withValues(alpha: .1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.delete_outline_rounded, color: danger, size: 24),
        ),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    side: BorderSide(color: colors.outlineVariant),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: Text(t.cancel),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: danger,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: Text(t.delete),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}

/// Rounded action row used inside small bottom sheets.
class VaultActionTile extends StatelessWidget {
  const VaultActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tint = color ?? colors.primary;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 20, color: tint),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: color ?? colors.onSurface,
                  ),
                ),
              ),
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
