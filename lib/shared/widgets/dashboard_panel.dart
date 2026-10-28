import 'package:flutter/material.dart';

/// Shared visual surface for the main dashboard sections.
///
/// Neutral surfaces shared by the overview and savings sections.
class DashboardPanel extends StatelessWidget {
  const DashboardPanel({super.key, required this.child, this.filled = true});

  final Widget child;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: EdgeInsets.zero,
      elevation: filled && !isDark ? 1 : 0,
      shadowColor: colors.shadow.withValues(alpha: .05),
      surfaceTintColor: Colors.transparent,
      color: filled
          ? theme.cardTheme.color ?? colors.surface
          : theme.scaffoldBackgroundColor,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: child,
    );
  }
}
