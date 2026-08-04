import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// A compact, user-facing replacement for raw asynchronous error messages.
///
/// Technical details remain available to Flutter's error reporting and logs;
/// they must never leak into the product UI.
class InlineLoadError extends StatelessWidget {
  const InlineLoadError({required this.onRetry, super.key});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
        decoration: BoxDecoration(
          color: colors.errorContainer.withValues(alpha: .42),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.error.withValues(alpha: .16)),
        ),
        child: Row(
          children: [
            Icon(Icons.sync_problem_rounded, color: colors.error, size: 21),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                t.dataTemporarilyUnavailable,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(t.retry),
            ),
          ],
        ),
      ),
    );
  }
}
