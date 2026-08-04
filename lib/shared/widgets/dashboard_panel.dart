import 'package:flutter/material.dart';

/// Shared visual surface for the main dashboard sections.
///
/// The explicit border and restrained shadow keep panels readable against the
/// tinted dashboard background in both light and dark mode.
class DashboardPanel extends StatelessWidget {
  const DashboardPanel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: EdgeInsets.zero,
      elevation: isDark ? 0 : 3,
      shadowColor: colors.shadow.withValues(alpha: .12),
      surfaceTintColor: Colors.transparent,
      color: theme.cardTheme.color ?? colors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: colors.outlineVariant.withValues(alpha: isDark ? .55 : .8),
        ),
      ),
      child: child,
    );
  }
}
