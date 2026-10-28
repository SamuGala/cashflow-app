import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';

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
    final statistics = navigationShell.currentIndex == 2;
    final radius = statistics
        ? const BorderRadius.vertical(top: Radius.circular(24))
        : BorderRadius.circular(22);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: statistics
            ? EdgeInsets.zero
            : const EdgeInsets.fromLTRB(16, 6, 16, 8),
        child: DecoratedBox(
          key: const ValueKey('vault-navigation-capsule'),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: radius,
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: NavigationBarTheme(
              data: Theme.of(context).navigationBarTheme.copyWith(
                height: statistics ? 64 : 72,
                iconTheme: WidgetStateProperty.resolveWith(
                  (states) => IconThemeData(
                    size: statistics ? 25 : 22,
                    color: states.contains(WidgetState.selected)
                        ? (Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF969DFF)
                              : const Color(0xFF4654EE))
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              child: NavigationBar(
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: _onTap,
                destinations: [
                  NavigationDestination(
                    icon: Icon(
                      statistics ? CupertinoIcons.house : Icons.home_outlined,
                    ),
                    selectedIcon: Icon(
                      statistics ? CupertinoIcons.house : Icons.home_rounded,
                    ),
                    label: t.home,
                  ),
                  NavigationDestination(
                    icon: Icon(
                      statistics
                          ? CupertinoIcons.list_bullet
                          : Icons.receipt_long_outlined,
                    ),
                    label: t.transactions,
                  ),
                  NavigationDestination(
                    icon: Icon(
                      statistics
                          ? Icons.bar_chart_rounded
                          : Icons.pie_chart_outline_rounded,
                    ),
                    label: t.stats,
                  ),
                  NavigationDestination(
                    icon: Icon(
                      statistics ? CupertinoIcons.gear : Icons.tune_rounded,
                    ),
                    label: t.settings,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
