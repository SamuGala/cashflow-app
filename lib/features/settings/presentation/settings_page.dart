import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../presentation/providers/theme_provider.dart';
import '../presentation/providers/locale_provider.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../../l10n/app_localizations.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.settings,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// THEME
          Text(
            t.theme,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          SegmentedButton<AppThemeMode>(
            segments: [
              ButtonSegment(
                value: AppThemeMode.light,
                label: Text(t.light),
              ),
              ButtonSegment(
                value: AppThemeMode.dark,
                label: Text(t.dark),
              ),
            ],
            selected: {theme},
            onSelectionChanged: (value) {
              ref.read(themeProvider.notifier).setTheme(value.first);
            },
          ),

          const SizedBox(height: 24),

          /// LANGUAGE
          Text(
            t.language,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          DropdownButton<String>(
            value: locale.languageCode,
            items: const [
              DropdownMenuItem(value: "it", child: Text("Italiano")),
              DropdownMenuItem(value: "en", child: Text("English")),
              DropdownMenuItem(value: "es", child: Text("Español")),
            ],
            onChanged: (value) {
              if (value != null) {
                ref.read(localeProvider.notifier).setLocale(value);
              }
            },
          ),

          const SizedBox(height: 24),

          /// DATA RESET
          Text(
            t.data,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          ElevatedButton.icon(
            icon: const Icon(Icons.delete_forever),
            label: Text(t.cancelAll),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (dialogContext) {
                  return AlertDialog(
                    title: Text(t.confirm),
                    content: Text(t.deleteAllQ),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(dialogContext, false),
                        child: Text(t.cancel),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(dialogContext, true),
                        child: Text(t.delete),
                      ),
                    ],
                  );
                },
              );

              if (confirm == true) {
                await ref
                    .read(transactionProvider.notifier)
                    .deleteAllData();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Deleted")),
                  );
                }
              }
            },
          ),

          const SizedBox(height: 260),

          /// FOOTER
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              "Cashflow v1.0.0\n© SG All rights reserved",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}