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
    const radius = BorderRadius.vertical(top: Radius.circular(24));
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: EdgeInsets.zero,
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
                height: 64,
                iconTheme: WidgetStateProperty.resolveWith(
                  (states) => IconThemeData(
                    size: 25,
                    color: states.contains(WidgetState.selected)
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
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
      ),
    );
  }
}
