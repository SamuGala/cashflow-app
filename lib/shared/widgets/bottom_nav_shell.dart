import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../app/theme/app_theme.dart';
import 'vault_style.dart';

class BottomNavShell extends StatelessWidget {
  const BottomNavShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final base = Theme.of(context);
    final dark = base.brightness == Brightness.dark;
    const radius = BorderRadius.vertical(top: Radius.circular(24));
    return AnimatedTheme(
      data: AppTheme.section(
        base,
        VaultSection.forBranch(navigationShell.currentIndex),
      ),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 280),
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final palette = theme.extension<VaultSectionPalette>()!;
          return Scaffold(
            backgroundColor: palette.background,
            body: _SectionBackdrop(palette: palette, child: navigationShell),
            bottomNavigationBar: _bar(context, t, theme, palette, dark, radius),
          );
        },
      ),
    );
  }

  Widget _bar(
    BuildContext context,
    AppLocalizations t,
    ThemeData theme,
    VaultSectionPalette palette,
    bool dark,
    BorderRadius radius,
  ) {
    return SafeArea(
      top: false,
      minimum: EdgeInsets.zero,
      child: DecoratedBox(
        key: const ValueKey('vault-navigation-capsule'),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: radius,
          border: Border.all(color: theme.colorScheme.outlineVariant),
          boxShadow: VaultElevation.navigation(dark),
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: NavigationBarTheme(
            data: theme.navigationBarTheme.copyWith(
              height: 64,
              indicatorColor: palette.tonal,
              iconTheme: WidgetStateProperty.resolveWith(
                (states) => IconThemeData(
                  size: 25,
                  color: states.contains(WidgetState.selected)
                      ? palette.navigation
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              labelTextStyle: WidgetStateProperty.resolveWith(
                (states) => TextStyle(
                  fontSize: 11,
                  fontWeight: states.contains(WidgetState.selected)
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: states.contains(WidgetState.selected)
                      ? palette.navigation
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            child: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onTap,
              destinations: [
                NavigationDestination(
                  icon: Icon(CupertinoIcons.house),
                  selectedIcon: Icon(CupertinoIcons.house),
                  label: t.home,
                ),
                NavigationDestination(
                  icon: Icon(CupertinoIcons.list_bullet),
                  label: t.transactions,
                ),
                NavigationDestination(
                  icon: Icon(Icons.bar_chart_rounded),
                  label: t.stats,
                ),
                NavigationDestination(
                  icon: Icon(CupertinoIcons.gear),
                  label: t.settings,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The tab's tinted background with a soft wash of its color at the top.
class _SectionBackdrop extends StatelessWidget {
  const _SectionBackdrop({required this.palette, required this.child});

  final VaultSectionPalette palette;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: palette.background),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [palette.wash, palette.wash.withValues(alpha: 0)],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}
