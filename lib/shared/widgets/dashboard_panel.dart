import 'package:flutter/material.dart';

import 'vault_style.dart';

/// Shared visual surface for the main dashboard sections.
///
/// Filled panels use the Vault card of the Statistics tab; outlined panels
/// sit on the page background for secondary sections.
class DashboardPanel extends StatelessWidget {
  const DashboardPanel({super.key, required this.child, this.filled = true});

  final Widget child;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return VaultSurface(padding: EdgeInsets.zero, child: child);
    }
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: .7,
        ),
      ),
      child: child,
    );
  }
}
